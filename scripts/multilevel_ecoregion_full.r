## v3.0.0 hierarchical ecoregion composite.
##
## Approach: extract L1, L2, L3 codes per FIA plot from NA_Eco_L3_WGS84.shp
## (already has all three levels in its attribute table). Compute PCA weights
## per region at each level. Build a shrinkage-weighted composite where each
## plot's effective weights are a blend of its L3, L2, and L1 region weights,
## blended by an n-based shrinkage factor.
##
## Hierarchical shrinkage formula (empirical Bayes intuition):
##   shrink_L3 = n_L3 / (n_L3 + tau_3)
##   shrink_L2 = n_L2 / (n_L2 + tau_2)
##   w_eff = shrink_L3 * w_L3 + (1 - shrink_L3) * (
##             shrink_L2 * w_L2 + (1 - shrink_L2) * w_L1)
## with tau_3 = 200, tau_2 = 500 as initial shrinkage targets.
## Small L3 regions get pulled toward L2 / L1; large L3 regions express their
## own weights nearly intact.

suppressPackageStartupMessages({ library(data.table); library(terra); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5_ML")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots:", nrow(plt), "\n")

## ===== Step 1: spatial join, save all three levels =====
eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
cat("eco features:", length(eco), "\n")

plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(eco))
attr <- terra::extract(eco, pts)
plt_xy[, `:=`(
  L1 = attr$NA_L1CODE,
  L2 = attr$NA_L2CODE,
  L3 = attr$NA_L3CODE,
  L1_name = attr$NA_L1NAME,
  L2_name = attr$NA_L2NAME,
  L3_name = attr$NA_L3NAME)]
cat("plots with L3:", sum(!is.na(plt_xy$L3)), "\n")
cat("unique L1:", length(unique(plt_xy$L1[!is.na(plt_xy$L1)])),
    "L2:", length(unique(plt_xy$L2[!is.na(plt_xy$L2)])),
    "L3:", length(unique(plt_xy$L3[!is.na(plt_xy$L3)])), "\n")

## ===== Step 2: z-scores and equal-weight composite =====
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt_xy[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt_xy[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt_xy[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt_xy[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

sub <- plt_xy[!is.na(L3) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]

## ===== Step 3: per-level PCA weights =====
calc_weights <- function(df, group_col, min_n = 50) {
  df[, n_eco := .N, by = group_col]
  groups <- unique(df[n_eco >= min_n][[group_col]])
  out <- list()
  for (g in groups) {
    d <- df[get(group_col) == g]
    pc <- prcomp(d[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
    w <- pc$rotation[, 1]
    if (mean(w) < 0) w <- -w
    w_norm <- w * 3 / sum(abs(w))
    out[[as.character(g)]] <- data.table(
      group = g, n = nrow(d),
      w_esi = w_norm["z_esi"],
      w_bgi = w_norm["z_bgi"],
      w_asym = w_norm["z_asym"])
  }
  rbindlist(out)
}

cat("\n=== Per-L1 weights ===\n")
w_L1 <- calc_weights(sub, "L1", 50)
setnames(w_L1, c("group","n","w_esi","w_bgi","w_asym"),
              c("L1","n_L1","w_esi_L1","w_bgi_L1","w_asym_L1"))
print(w_L1)
fwrite(w_L1, file.path(OUT, "ML1_pca_weights.csv"))

cat("\n=== Per-L2 weights ===\n")
w_L2 <- calc_weights(sub, "L2", 50)
setnames(w_L2, c("group","n","w_esi","w_bgi","w_asym"),
              c("L2","n_L2","w_esi_L2","w_bgi_L2","w_asym_L2"))
cat("L2 weight rows:", nrow(w_L2), "\n")
fwrite(w_L2, file.path(OUT, "ML2_pca_weights.csv"))

cat("\n=== Per-L3 weights ===\n")
w_L3 <- calc_weights(sub, "L3", 50)
setnames(w_L3, c("group","n","w_esi","w_bgi","w_asym"),
              c("L3","n_L3","w_esi_L3","w_bgi_L3","w_asym_L3"))
cat("L3 weight rows:", nrow(w_L3), "\n")
fwrite(w_L3, file.path(OUT, "ML3_pca_weights.csv"))

## ===== Step 4: join weights to plots =====
sub <- merge(sub, w_L1, by = "L1", all.x = TRUE)
sub <- merge(sub, w_L2, by = "L2", all.x = TRUE)
sub <- merge(sub, w_L3, by = "L3", all.x = TRUE)

## ===== Step 5: hierarchical shrinkage =====
tau_3 <- 200; tau_2 <- 500
sub[, shrink_L3 := n_L3 / (n_L3 + tau_3)]
sub[, shrink_L2 := n_L2 / (n_L2 + tau_2)]
# Where L3 weight is missing, use L2 or L1
sub[is.na(w_esi_L3), `:=`(w_esi_L3 = 1, w_bgi_L3 = 1, w_asym_L3 = 1, shrink_L3 = 0)]
sub[is.na(w_esi_L2), `:=`(w_esi_L2 = 1, w_bgi_L2 = 1, w_asym_L2 = 1, shrink_L2 = 0)]
sub[is.na(w_esi_L1), `:=`(w_esi_L1 = 1, w_bgi_L1 = 1, w_asym_L1 = 1)]

# Hierarchical effective weights
for (cmp in c("esi", "bgi", "asym")) {
  w_L3_col <- paste0("w_", cmp, "_L3")
  w_L2_col <- paste0("w_", cmp, "_L2")
  w_L1_col <- paste0("w_", cmp, "_L1")
  w_eff_col <- paste0("w_", cmp, "_hier")
  sub[, (w_eff_col) := shrink_L3 * get(w_L3_col) +
                      (1 - shrink_L3) * (shrink_L2 * get(w_L2_col) +
                                          (1 - shrink_L2) * get(w_L1_col))]
}

## ===== Step 6: build composites at each level =====
sub[, c3_L1   := (w_esi_L1   * z_esi + w_bgi_L1   * z_bgi + w_asym_L1   * z_asym) / 3]
sub[, c3_L2   := (w_esi_L2   * z_esi + w_bgi_L2   * z_bgi + w_asym_L2   * z_asym) / 3]
sub[, c3_L3   := (w_esi_L3   * z_esi + w_bgi_L3   * z_bgi + w_asym_L3   * z_asym) / 3]
sub[, c3_hier := (w_esi_hier * z_esi + w_bgi_hier * z_bgi + w_asym_hier * z_asym) / 3]

cat("\n=== Composite correlations ===\n")
print(round(cor(sub[, .(c3_equal, c3_L1, c3_L2, c3_L3, c3_hier)], use = "p"), 3))

## ===== Step 7: SITECLCD prediction =====
cat("\n=== SITECLCD prediction: all five composites ===\n")
sub_clcd <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
cat("n:", nrow(sub_clcd), "\n")
set.seed(2026)

fit_one <- function(formula) {
  ranger(formula, data = sub_clcd, num.trees = 500, num.threads = 8,
         classification = FALSE, importance = "none")
}

m_eq    <- fit_one(SITECLCD ~ c3_equal)
m_L1    <- fit_one(SITECLCD ~ c3_L1)
m_L2    <- fit_one(SITECLCD ~ c3_L2)
m_L3    <- fit_one(SITECLCD ~ c3_L3)
m_hier  <- fit_one(SITECLCD ~ c3_hier)
m_all   <- fit_one(SITECLCD ~ c3_equal + c3_L1 + c3_L2 + c3_L3)
m_eqhier <- fit_one(SITECLCD ~ c3_equal + c3_hier)

r <- data.table(
  predictor = c("c3_equal alone", "c3_L1 alone", "c3_L2 alone", "c3_L3 alone",
                "c3_hier alone", "equal + L1 + L2 + L3", "equal + hier"),
  OOB_R2 = round(c(m_eq$r.squared, m_L1$r.squared, m_L2$r.squared, m_L3$r.squared,
                   m_hier$r.squared, m_all$r.squared, m_eqhier$r.squared), 4),
  OOB_RMSE = round(sqrt(c(m_eq$prediction.error, m_L1$prediction.error,
                          m_L2$prediction.error, m_L3$prediction.error,
                          m_hier$prediction.error, m_all$prediction.error,
                          m_eqhier$prediction.error)), 3))
print(r)
fwrite(r, file.path(OUT, "ML4_siteclcd_prediction.csv"))

## Save the joined table
fwrite(sub[, .(key, L1, L2, L3, L1_name, L2_name, L3_name,
               z_esi, z_bgi, z_asym, c3_equal, c3_L1, c3_L2, c3_L3, c3_hier,
               shrink_L3, shrink_L2, SITECLCD, STDAGE)],
       file.path(OUT, "ML5_plt_with_hierarchical.csv"))

cat("\n=== Multi-level hierarchical composite done. Outputs in", OUT, "===\n")
