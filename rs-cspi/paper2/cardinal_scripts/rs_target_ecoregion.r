#!/usr/bin/env Rscript
# Track 4: per-L1 ecoregion residual stratification for every RS target, and a
# head-to-head table against the v3.0.0 Asym v9 ecoregion bias profile.
# Residual sign convention matches the manuscript: mean(obs - pred) per region.

suppressPackageStartupMessages({ library(data.table); library(sf) })
sf_use_s2(FALSE)
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
ECO  <- "/fs/scratch/PUOM0008/crsfaaron/v10q_aux/us_eco_l3.shp"

eco <- st_make_valid(st_read(ECO, quiet = TRUE))
# EPA L3 shapefile carries L1 names in NA_L1NAME (and L1CODE)
l1col <- intersect(c("NA_L1NAME","L1_KEY","NA_L1CODE"), names(eco))[1]
cat("L1 column:", l1col, "\n")

assign_l1 <- function(dt) {
  pts <- st_as_sf(dt, coords = c("LON","LAT"), crs = 4326)
  pts <- st_transform(pts, st_crs(eco))
  j <- st_join(pts, eco[, l1col], join = st_intersects)
  dt[, L1 := j[[l1col]]]
  dt
}

targets <- list(
  npp_obs   = "PIX22_npp_predictions.csv",
  gpp_obs   = "PIX22_gpp_obs_predictions.csv",
  ch_m      = "PIX22_ch_m_predictions.csv",
  agbd_obs  = "PIX22_agbd_predictions.csv",
  cms_agb16 = "PIX22_cms_agb16_predictions.csv",
  cms_agbchg= "PIX22_cms_agbchg_predictions.csv"
)

all_l1 <- list()
for (tg in names(targets)) {
  fp <- file.path(WORK, targets[[tg]])
  if (!file.exists(fp)) { cat("skip (not found):", tg, "\n"); next }
  dt <- fread(fp)
  # normalise column names: pre-existing NPP file uses npp_obs/npp_pred
  ocol <- intersect(c("obs","npp_obs"), names(dt))[1]
  pcol <- intersect(c("pred","npp_pred"), names(dt))[1]
  setnames(dt, c(ocol, pcol), c("obs","pred"))
  dt <- assign_l1(dt)
  dt[, resid := obs - pred]
  per <- dt[!is.na(L1), .(n = .N, mean_resid = round(mean(resid),2),
                          sd_resid = round(sd(resid),1)), by = L1]
  per[, target := tg]; setorder(per, -n)
  all_l1[[tg]] <- per
  cat("\n==== per-L1 residual:", tg, "====\n"); print(per)
}
out <- rbindlist(all_l1)
fwrite(out, file.path(WORK, "PIX40_perL1_residual_all_targets.csv"))

# wide table: mean residual per L1 by target, for the head-to-head
wide <- dcast(out, L1 ~ target, value.var = "mean_resid")
ncnt <- out[target == out$target[1], .(L1, n)]
wide <- merge(wide, out[, .(n = sum(n)), by = L1], by = "L1", all.x = TRUE)
setorder(wide, -n)
fwrite(wide, file.path(WORK, "PIX41_perL1_residual_wide.csv"))
cat("\n=== WIDE per-L1 residual (mean obs-pred) by target ===\n"); print(wide)
cat("\n=== DONE Track 4 ===\n")
