## v3.0.0 prototype: ecoregion-aware composite weights.
##
## The v2.0.0 composite uses equal weights across the three components (ESI v7,
## BGI, Asym). The per-state correlation analysis in multidim_v3 C4 shows
## substantial state-to-state structure (r_esi_bgi from +0.013 in NC to +0.526
## in ID; r_bgi_asym from -0.802 in OK to +0.908 in MN). This suggests a single
## national weighting leaves real signal on the table.
##
## Approach:
##   1. Group states into 8 broad ecoregions covering CONUS
##   2. Compute first-PC weights on the three z-scored components within each ecoregion
##   3. Build a region-weighted composite (different weights per region)
##   4. Test: does the region-weighted composite better predict FIA SITECLCD than
##      the equal-weight v2 composite?
##
## Login-node R, no SLURM. ~5-10 min total runtime.

suppressPackageStartupMessages({ library(data.table); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots loaded:", nrow(plt), "\n")

## Reconstruct STATECD if not present
if (!"STATECD" %in% names(plt)) {
  FIA_DIR <- "/users/PUOM0008/crsfaaron/FIA"
  cstates <- list.files(FIA_DIR, "_PLOT\\.csv$", full.names = FALSE)
  cstates <- gsub("_PLOT.csv", "", cstates)
  conus_states <- setdiff(cstates, c("AK","HI","PR","VI"))
  L <- list()
  for (st in conus_states) {
    f <- file.path(FIA_DIR, paste0(st, "_PLOT.csv"))
    if (!file.exists(f)) next
    d <- fread(f, select = c("STATECD","LAT","LON"))
    if (nrow(d)) L[[st]] <- d
  }
  pmin <- rbindlist(L)
  pmin[, key := paste0(round(LAT, 4), "_", round(LON, 4))]
  pmin <- unique(pmin, by = "key")
  plt <- merge(plt, pmin[, .(key, STATECD)], by = "key", all.x = TRUE)
}
cat("plots with STATECD:", sum(!is.na(plt$STATECD)), "\n")

## Define 8 broad CONUS ecoregions by STATECD groupings
ecoregion_map <- list(
  PacificCoastal = c(53, 41, 6),                          # WA, OR, CA
  InteriorNW     = c(16, 30, 56),                         # ID, MT, WY
  SouthwestAridMtn = c(4, 8, 32, 35, 49),                 # AZ, CO, NV, NM, UT
  CentralPlains  = c(20, 27, 29, 31, 38, 46),             # KS, MN, MO, NE, ND, SD
  LakeStates     = c(17, 18, 19, 26, 39, 55),             # IL, IN, IA, MI, OH, WI
  Appalachian    = c(21, 24, 37, 42, 47, 51, 54),         # KY, MD, NC, PA, TN, VA, WV
  Northeast      = c(9, 23, 25, 33, 34, 36, 44, 50),      # CT, ME, MA, NH, NJ, NY, RI, VT
  SouthCoastalGulf = c(1, 5, 10, 12, 13, 22, 28, 40, 45, 48)  # AL, AR, DE, FL, GA, LA, MS, OK, SC, TX
)

state_to_eco <- setNames(rep(NA_character_, 60), as.character(1:60))
for (eco in names(ecoregion_map)) {
  for (sc in ecoregion_map[[eco]]) {
    state_to_eco[as.character(sc)] <- eco
  }
}
plt[, ecoregion := state_to_eco[as.character(STATECD)]]
cat("\nPlots per ecoregion:\n")
print(plt[!is.na(ecoregion), .N, by = ecoregion][order(-N)])

## Z-score parameters (fixed at v0.9 cycle for cross-version stability)
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

## ===== Step 1: per-ecoregion PCA weights =====
cat("\n=== PCA weights per ecoregion ===\n")
sub <- plt[!is.na(ecoregion) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]
eco_weights <- list()
for (eco in names(ecoregion_map)) {
  d <- sub[ecoregion == eco]
  if (nrow(d) < 100) next
  pc <- prcomp(d[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
  # PC1 loadings -- normalize to sum-of-abs = 3 so they're comparable to equal weights of 1
  w <- pc$rotation[, 1]
  if (mean(w) < 0) w <- -w  # ensure positive mean direction
  w_norm <- w * 3 / sum(abs(w))
  eco_weights[[eco]] <- data.table(
    ecoregion = eco,
    w_esi  = round(w_norm["z_esi"],  3),
    w_bgi  = round(w_norm["z_bgi"],  3),
    w_asym = round(w_norm["z_asym"], 3),
    var_pc1 = round(pc$sdev[1]^2 / sum(pc$sdev^2), 3),
    n      = nrow(d))
  cat(sprintf("%-20s n=%6d   w(ESI,BGI,Asym) = (%5.2f, %5.2f, %5.2f)  PC1 var = %.2f\n",
              eco, nrow(d),
              w_norm["z_esi"], w_norm["z_bgi"], w_norm["z_asym"],
              pc$sdev[1]^2 / sum(pc$sdev^2)))
}
weights_dt <- rbindlist(eco_weights)
fwrite(weights_dt, file.path(OUT, "M1_ecoregion_pca_weights.csv"))

## ===== Step 2: region-weighted composite =====
cat("\n=== Building region-weighted composite ===\n")
sub <- merge(sub, weights_dt[, .(ecoregion, w_esi, w_bgi, w_asym)],
             by = "ecoregion", all.x = TRUE)
sub[, c3_eco := (w_esi * z_esi + w_bgi * z_bgi + w_asym * z_asym) / 3]

# Correlation between equal-weight and ecoregion-weighted composites
cat("Cor(c3_equal, c3_eco):", round(cor(sub$c3_equal, sub$c3_eco, use = "p"), 3), "\n")

## ===== Step 3: does eco-weighted composite predict SITECLCD better? =====
cat("\n=== SITECLCD prediction: equal vs eco-weighted ===\n")
sub_clcd <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
cat("n:", nrow(sub_clcd), "\n")

set.seed(2026)
fit_equal <- ranger(SITECLCD ~ c3_equal,
                    data = sub_clcd[, .(SITECLCD, c3_equal)],
                    num.trees = 500, num.threads = 8,
                    classification = FALSE)
fit_eco   <- ranger(SITECLCD ~ c3_eco,
                    data = sub_clcd[, .(SITECLCD, c3_eco)],
                    num.trees = 500, num.threads = 8,
                    classification = FALSE)
fit_both  <- ranger(SITECLCD ~ c3_equal + c3_eco,
                    data = sub_clcd[, .(SITECLCD, c3_equal, c3_eco)],
                    num.trees = 500, num.threads = 8,
                    classification = FALSE)

cat("\nOOB R² predicting SITECLCD:\n")
cat(sprintf("  c3_equal alone     : %.4f\n", fit_equal$r.squared))
cat(sprintf("  c3_eco alone       : %.4f\n", fit_eco$r.squared))
cat(sprintf("  c3_equal + c3_eco  : %.4f\n", fit_both$r.squared))
cat(sprintf("  delta from eco     : %+.4f\n", fit_eco$r.squared - fit_equal$r.squared))

results <- data.table(
  predictor = c("c3_equal", "c3_eco", "c3_equal + c3_eco"),
  OOB_R2    = round(c(fit_equal$r.squared, fit_eco$r.squared, fit_both$r.squared), 4),
  OOB_RMSE  = round(c(sqrt(fit_equal$prediction.error),
                      sqrt(fit_eco$prediction.error),
                      sqrt(fit_both$prediction.error)), 3),
  n         = nrow(sub_clcd))
fwrite(results, file.path(OUT, "M2_siteclcd_prediction.csv"))

## ===== Step 4: per-ecoregion SITECLCD prediction =====
cat("\n=== Per-ecoregion SITECLCD prediction with the ecoregion's own weights ===\n")
per_eco_r2 <- list()
for (eco in names(ecoregion_map)) {
  d <- sub_clcd[ecoregion == eco]
  if (nrow(d) < 200) next
  fe <- ranger(SITECLCD ~ c3_equal,
               data = d[, .(SITECLCD, c3_equal)],
               num.trees = 300, num.threads = 8, classification = FALSE)
  feco <- ranger(SITECLCD ~ c3_eco,
                 data = d[, .(SITECLCD, c3_eco)],
                 num.trees = 300, num.threads = 8, classification = FALSE)
  per_eco_r2[[eco]] <- data.table(
    ecoregion = eco,
    n = nrow(d),
    R2_equal = round(fe$r.squared, 4),
    R2_eco   = round(feco$r.squared, 4),
    delta    = round(feco$r.squared - fe$r.squared, 4))
  cat(sprintf("  %-20s n=%5d  R2_equal=%.3f  R2_eco=%.3f  delta=%+.3f\n",
              eco, nrow(d), fe$r.squared, feco$r.squared, feco$r.squared - fe$r.squared))
}
pe <- rbindlist(per_eco_r2)
fwrite(pe, file.path(OUT, "M3_per_ecoregion_siteclcd_r2.csv"))

## Save full plot table with ecoregion + both composites
fwrite(sub[, .(key, ecoregion, STATECD, z_esi, z_bgi, z_asym,
               c3_equal, c3_eco, w_esi, w_bgi, w_asym, SITECLCD, STDAGE)],
       file.path(OUT, "M4_plt_with_ecoregion_composite.csv"))

cat("\n=== Ecoregion-aware composite prototype done. Outputs in", OUT, "===\n")
