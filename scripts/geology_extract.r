## Extract geologic predictors (gSSURGO parent material) at FIA plot mukeys.
## Uses the same factor-aware mukey extraction as ssurgo_join_fix.r.
## Queries SDA copmgrp table for parent material per mukey.

suppressPackageStartupMessages({
  library(data.table); library(terra); library(soilDB)
})

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v6_geol")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## Re-extract mukey per FIA plot via rasterize approach (same as multilevel)
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
mukey_r <- rast("/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/environmental_data/gssurgo/mukey_raster.tif")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(mukey_r))
mk <- terra::extract(mukey_r, pts, ID = FALSE)[, 1]
plt_xy[, mukey := as.integer(as.character(mk))]
uniq <- unique(plt_xy$mukey[!is.na(plt_xy$mukey)])
cat("unique mukeys:", length(uniq), "\n")

## Query SDA for parent material per mukey from copmgrp
## Retry failed SDA calls with backoff and log mukeys that never succeed
## (previously failed chunks were dropped after a single attempt).
sda_retry <- function(q, tries = 4) {
  for (k in seq_len(tries)) {
    res <- tryCatch(SDA_query(q), error = function(e) e)
    if (!inherits(res, c("error", "try-error"))) return(list(ok = TRUE, res = res))
    Sys.sleep(2^k)
  }
  list(ok = FALSE, res = NULL)
}
chunk_size <- 800
rows <- list()
failed <- integer()
for (i in seq(1, length(uniq), by = chunk_size)) {
  mks <- uniq[i:min(i + chunk_size - 1, length(uniq))]
  q <- paste0(
    "SELECT mu.mukey, c.cokey, c.compname, c.comppct_r, ",
    "       cpm.pmgroupname, cpm.rvindicator ",
    "FROM mapunit mu ",
    "INNER JOIN component c ON c.mukey = mu.mukey ",
    "INNER JOIN copmgrp cpm ON cpm.cokey = c.cokey ",
    "WHERE mu.mukey IN (", paste(mks, collapse = ","), ") ",
    "  AND cpm.pmgroupname IS NOT NULL")
  r <- sda_retry(q)
  if (!r$ok) failed <- c(failed, mks)
  res <- r$res
  if (!is.null(res) && nrow(res)) {
    rows[[length(rows) + 1]] <- setDT(res)
    if (i %% 4000 == 1) cat("chunk", i, "rows:", nrow(res), "\n")
  }
  Sys.sleep(0.5)
}
sda <- rbindlist(rows, fill = TRUE)
cat("total SDA rows:", nrow(sda), " mukeys in failed chunks:", length(failed), "\n")
fwrite(data.table(mukey = failed), file.path(OUT, "PM0_failed_mukeys.csv"))

## Pick the dominant parent material per mukey
sda[, comppct_r := as.numeric(comppct_r)]
sda_dom <- sda[order(mukey, -comppct_r),
               .(pm_dom = first(pmgroupname),
                 comppct_dom = first(comppct_r),
                 n_pm = uniqueN(pmgroupname)),
               by = mukey]
fwrite(sda_dom, file.path(OUT, "PM1_pm_per_mukey.csv"))
cat("mukeys with PM:", nrow(sda_dom), "\n")

## Categorize parent material into broad groups
sda_dom[, pm_category := fcase(
  grepl("glacial|till|drift|moraine|outwash", pm_dom, ignore.case = TRUE), "Glacial",
  grepl("alluvi|fluvial|stream|river", pm_dom, ignore.case = TRUE),       "Alluvial",
  grepl("eolian|loess|aeolian", pm_dom, ignore.case = TRUE),               "Eolian",
  grepl("residuum|residual|bedrock|in.place", pm_dom, ignore.case = TRUE), "Residuum",
  grepl("colluv|slope", pm_dom, ignore.case = TRUE),                       "Colluvium",
  grepl("lacustrine|lake", pm_dom, ignore.case = TRUE),                    "Lacustrine",
  grepl("marine|coastal plain", pm_dom, ignore.case = TRUE),               "Marine",
  grepl("volcanic|ash|pyroclast|lahar|cinder", pm_dom, ignore.case = TRUE),"Volcanic",
  grepl("organic|peat|muck", pm_dom, ignore.case = TRUE),                  "Organic",
  default = "Other"
)]
cat("\nParent material category distribution:\n")
print(sda_dom[, .N, by = pm_category][order(-N)])

## Join to plot table
plt_xy[, mukey := as.integer(mukey)]
sda_dom[, mukey := as.integer(mukey)]
plt_xy <- merge(plt_xy, sda_dom[, .(mukey, pm_dom, pm_category, comppct_dom)],
                by = "mukey", all.x = TRUE)
plt_xy[, SICOND_m := SICOND * 0.3048]
cat("\nplots with PM:", sum(!is.na(plt_xy$pm_category)), "of", nrow(plt_xy), "\n")
cat("plot-level PM distribution:\n")
print(plt_xy[!is.na(pm_category), .N, by = pm_category][order(-N)])

## Stratify productivity by parent material (§3.12 style)
pm_summary <- plt_xy[!is.na(pm_category) & !is.na(esi) & !is.na(bgi_v),
  .(n         = .N,
    mean_esi  = round(mean(esi,    na.rm = TRUE), 1),
    mean_bgi  = round(mean(bgi_v,  na.rm = TRUE), 2),
    mean_asym = round(mean(asym_v, na.rm = TRUE), 1),
    mean_npp  = round(mean(npp_v,  na.rm = TRUE), 0),
    r_esi_bgi = round(cor(esi, bgi_v, use = "p"), 3)
  ), by = pm_category][order(-n)]
print(pm_summary)
fwrite(pm_summary, file.path(OUT, "PM2_productivity_by_PM_category.csv"))

## SITECLCD by parent material
clcd_pm <- plt_xy[!is.na(pm_category) & !is.na(SITECLCD) & SITECLCD %in% 1:7,
  .(n = .N,
    mean_SITECLCD = round(mean(SITECLCD), 2)
  ), by = pm_category][order(-n)]
print(clcd_pm)
fwrite(clcd_pm, file.path(OUT, "PM3_SITECLCD_by_PM.csv"))

## RF: does adding PM as predictor improve SITECLCD recovery over equal composite?
library(ranger)
sub <- plt_xy[!is.na(pm_category) & !is.na(SITECLCD) & SITECLCD %in% 1:7 &
              !is.na(esi) & !is.na(bgi_v) & !is.na(asym_v)]
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
sub[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
sub[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
sub[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
sub[, c3_equal := (z_esi + z_bgi + z_asym) / 3]
sub[, pm_factor := factor(pm_category)]

set.seed(2026)
m_eq    <- ranger(SITECLCD ~ c3_equal,
                  data = sub[, .(SITECLCD, c3_equal)],
                  num.trees = 300, num.threads = 8, classification = FALSE)
m_eq_pm <- ranger(SITECLCD ~ c3_equal + pm_factor,
                  data = sub[, .(SITECLCD, c3_equal, pm_factor)],
                  num.trees = 300, num.threads = 8, classification = FALSE)
m_pm    <- ranger(SITECLCD ~ pm_factor,
                  data = sub[, .(SITECLCD, pm_factor)],
                  num.trees = 300, num.threads = 8, classification = FALSE)

results <- data.table(
  model = c("c3_equal alone", "pm_category alone", "c3_equal + pm_category"),
  OOB_R2 = round(c(m_eq$r.squared, m_pm$r.squared, m_eq_pm$r.squared), 4),
  OOB_RMSE = round(sqrt(c(m_eq$prediction.error, m_pm$prediction.error, m_eq_pm$prediction.error)), 3),
  n = nrow(sub))
print(results)
fwrite(results, file.path(OUT, "PM4_SITECLCD_RF_with_geology.csv"))

cat("\n=== Geology extraction done. Outputs in", OUT, "===\n")
