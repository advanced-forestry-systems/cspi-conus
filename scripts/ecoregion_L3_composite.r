## v3.0.0 prototype revision: EPA Level III ecoregions instead of state grouping.
##
## State-level grouping was a coarse first cut. EPA Level III ecoregions are the
## standard for ecological analyses at the CONUS scale (84 regions, ecologically
## defined by climate/vegetation/geology/physiography). The shapefile already
## exists at /users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp.

suppressPackageStartupMessages({ library(data.table); library(terra); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5_L3")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots loaded:", nrow(plt), "\n")

## Spatial-join to EPA Level III
eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
cat("EPA Level III polygons:", length(eco), "\n")
cat("attribute fields:", paste(names(eco), collapse = ", "), "\n")

plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
eco_proj <- project(eco, crs(pts))
eco_attr <- terra::extract(eco_proj, pts)
plt_xy[, eco_L3_id := eco_attr[, 2]]  # second column is typically the region key

# Try to grab a useful name field too
name_col <- names(eco_attr)[grep("name|NA_L3|L3_KEY|US_L3", names(eco_attr), ignore.case = TRUE)][1]
if (!is.na(name_col)) plt_xy[, eco_L3_name := eco_attr[[name_col]]]

cat("plots with eco_L3:", sum(!is.na(plt_xy$eco_L3_id)), "of", nrow(plt_xy), "\n")
cat("\nTop 15 ecoregions by plot count:\n")
print(plt_xy[!is.na(eco_L3_id), .N, by = .(eco_L3_id, eco_L3_name)][order(-N)][1:15])

## z-score parameters fixed at v0.9 cycle
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt_xy[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt_xy[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt_xy[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt_xy[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

sub <- plt_xy[!is.na(eco_L3_id) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]
n_per_eco <- sub[, .N, by = eco_L3_id]
keep_ecos <- n_per_eco[N >= 100, eco_L3_id]
cat("\necoregions with n >= 100:", length(keep_ecos), "of", nrow(n_per_eco), "\n")

## ===== Per-ecoregion PCA weights =====
cat("\n=== L3 PCA weights ===\n")
weights <- list()
for (e in keep_ecos) {
  d <- sub[eco_L3_id == e]
  pc <- prcomp(d[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
  w <- pc$rotation[, 1]
  if (mean(w) < 0) w <- -w
  w_norm <- w * 3 / sum(abs(w))
  weights[[as.character(e)]] <- data.table(
    eco_L3_id = e,
    eco_L3_name = d$eco_L3_name[1],
    n = nrow(d),
    w_esi = round(w_norm["z_esi"], 3),
    w_bgi = round(w_norm["z_bgi"], 3),
    w_asym = round(w_norm["z_asym"], 3),
    var_pc1 = round(pc$sdev[1]^2 / sum(pc$sdev^2), 3))
}
weights_dt <- rbindlist(weights)
fwrite(weights_dt, file.path(OUT, "M1L3_pca_weights.csv"))
cat("Weights computed for", nrow(weights_dt), "ecoregions\n")
cat("Mean w_ESI:", round(mean(weights_dt$w_esi), 2),
    "  w_BGI:", round(mean(weights_dt$w_bgi), 2),
    "  w_Asym:", round(mean(weights_dt$w_asym), 2), "\n")

## ===== L3-weighted composite =====
sub <- merge(sub, weights_dt[, .(eco_L3_id, w_esi, w_bgi, w_asym)],
             by = "eco_L3_id", all.x = TRUE)
sub[, c3_L3 := (w_esi * z_esi + w_bgi * z_bgi + w_asym * z_asym) / 3]
cat("\nCor(c3_equal, c3_L3):", round(cor(sub$c3_equal, sub$c3_L3, use = "p"), 3), "\n")

## ===== SITECLCD prediction: pooled =====
cat("\n=== SITECLCD prediction (pooled): equal vs L3-weighted ===\n")
sub_clcd <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
set.seed(2026)
fit_e <- ranger(SITECLCD ~ c3_equal, data = sub_clcd[, .(SITECLCD, c3_equal)],
                num.trees = 500, num.threads = 8, classification = FALSE)
fit_L3 <- ranger(SITECLCD ~ c3_L3, data = sub_clcd[, .(SITECLCD, c3_L3)],
                 num.trees = 500, num.threads = 8, classification = FALSE)
fit_b <- ranger(SITECLCD ~ c3_equal + c3_L3,
                data = sub_clcd[, .(SITECLCD, c3_equal, c3_L3)],
                num.trees = 500, num.threads = 8, classification = FALSE)
cat(sprintf("  c3_equal alone     : %.4f (RMSE %.3f)\n", fit_e$r.squared, sqrt(fit_e$prediction.error)))
cat(sprintf("  c3_L3 alone        : %.4f (RMSE %.3f)\n", fit_L3$r.squared, sqrt(fit_L3$prediction.error)))
cat(sprintf("  both together      : %.4f (RMSE %.3f)\n", fit_b$r.squared, sqrt(fit_b$prediction.error)))
cat(sprintf("  delta from L3      : %+.4f\n", fit_L3$r.squared - fit_e$r.squared))

fwrite(data.table(
  predictor = c("c3_equal", "c3_L3", "c3_equal + c3_L3"),
  OOB_R2 = round(c(fit_e$r.squared, fit_L3$r.squared, fit_b$r.squared), 4),
  OOB_RMSE = round(c(sqrt(fit_e$prediction.error), sqrt(fit_L3$prediction.error), sqrt(fit_b$prediction.error)), 3),
  n = nrow(sub_clcd)),
  file.path(OUT, "M2L3_siteclcd_prediction.csv"))

## Per-ecoregion delta (top 10 by sample size)
cat("\n=== Per-ecoregion deltas (top 10 by n) ===\n")
top_eco <- n_per_eco[N >= 500][order(-N)][1:10, eco_L3_id]
per_eco <- list()
for (e in top_eco) {
  d <- sub_clcd[eco_L3_id == e]
  if (nrow(d) < 200) next
  fe <- ranger(SITECLCD ~ c3_equal, data = d[, .(SITECLCD, c3_equal)],
               num.trees = 300, num.threads = 8, classification = FALSE)
  fL3 <- ranger(SITECLCD ~ c3_L3, data = d[, .(SITECLCD, c3_L3)],
                num.trees = 300, num.threads = 8, classification = FALSE)
  per_eco[[as.character(e)]] <- data.table(
    eco_L3_id = e,
    eco_L3_name = d$eco_L3_name[1],
    n = nrow(d),
    R2_equal = round(fe$r.squared, 4),
    R2_L3 = round(fL3$r.squared, 4),
    delta = round(fL3$r.squared - fe$r.squared, 4))
  cat(sprintf("  %-40s n=%5d  R2_eq=%.3f  R2_L3=%.3f  delta=%+.3f\n",
              substr(paste0(d$eco_L3_name[1]), 1, 40),
              nrow(d), fe$r.squared, fL3$r.squared, fL3$r.squared - fe$r.squared))
}
fwrite(rbindlist(per_eco), file.path(OUT, "M3L3_per_ecoregion_r2.csv"))

cat("\n=== L3 ecoregion analysis done. Outputs in", OUT, "===\n")
