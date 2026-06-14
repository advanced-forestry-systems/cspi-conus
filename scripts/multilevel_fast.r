## Multi-level ecoregion composite — FAST version.
## EPA Level III codes have format X.Y.Z where X = Level I, X.Y = Level II.
## We can derive L1, L2 from L3 without re-running the slow spatial join.
## Reuses the saved L3 plot table from multidim_v5_L3.

suppressPackageStartupMessages({ library(data.table); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5_ML")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## We didn't save plot-level L3 keys in M5L3, but we saved per-ecoregion weights.
## Reload by re-joining: use the plt + the M1L3 weights table, but we also need
## the L3 code per plot. Since the L3 spatial extract has already been done,
## we just need the L3 codes saved per plot.
## Quickest path: re-extract from a much simpler structure — use the FIA STATECD
## and a state-to-eco_L1 lookup as approximation. But that's coarse.
##
## Simpler: re-do the spatial extract but ONLY save the codes (no rasterization,
## no merging - just the codes), parallelize with terra::extract on a chunked
## point set. Should be ~3-5 min.

library(terra)
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]

eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(eco))
cat("Starting spatial extract on", length(pts), "points against", length(eco), "polygons\n")
cat("Note: this is the slow step (~10-15 min)\n")
attr <- terra::extract(eco, pts)
cat("Spatial extract complete.\n")

plt_xy[, `:=`(L3_full = attr$NA_L3CODE,
              L2_full = attr$NA_L2CODE,
              L1_full = attr$NA_L1CODE,
              L3_name = attr$NA_L3NAME,
              L2_name = attr$NA_L2NAME,
              L1_name = attr$NA_L1NAME)]

cat("plots with L3:", sum(!is.na(plt_xy$L3_full)), "\n")
cat("unique L1:", length(unique(plt_xy$L1_full[!is.na(plt_xy$L1_full)])),
    " L2:", length(unique(plt_xy$L2_full[!is.na(plt_xy$L2_full)])),
    " L3:", length(unique(plt_xy$L3_full[!is.na(plt_xy$L3_full)])), "\n")

## z-scores
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt_xy[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt_xy[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt_xy[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt_xy[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

sub <- plt_xy[!is.na(L3_full) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]
cat("complete-case n:", nrow(sub), "\n")

## ===== per-level PCA weights =====
make_weights <- function(df, gcol, min_n = 100) {
  n_per <- df[, .N, by = gcol]
  keep <- n_per[N >= min_n][[gcol]]
  out <- list()
  for (g in keep) {
    d <- df[get(gcol) == g]
    pc <- prcomp(d[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
    w <- pc$rotation[, 1]; if (mean(w) < 0) w <- -w
    w <- w * 3 / sum(abs(w))
    out[[as.character(g)]] <- data.table(
      group_id = g, n = nrow(d),
      w_esi = w["z_esi"], w_bgi = w["z_bgi"], w_asym = w["z_asym"])
  }
  rbindlist(out)
}

w1 <- make_weights(sub, "L1_full", 50)
w2 <- make_weights(sub, "L2_full", 50)
w3 <- make_weights(sub, "L3_full", 100)
cat("L1 regions:", nrow(w1), " L2:", nrow(w2), " L3:", nrow(w3), "\n")
fwrite(w1, file.path(OUT, "ML_L1_weights.csv"))
fwrite(w2, file.path(OUT, "ML_L2_weights.csv"))
fwrite(w3, file.path(OUT, "ML_L3_weights.csv"))

## Join + shrinkage composite
setnames(w1, c("group_id","n","w_esi","w_bgi","w_asym"),
              c("L1_full","n_L1","w_esi_L1","w_bgi_L1","w_asym_L1"))
setnames(w2, c("group_id","n","w_esi","w_bgi","w_asym"),
              c("L2_full","n_L2","w_esi_L2","w_bgi_L2","w_asym_L2"))
setnames(w3, c("group_id","n","w_esi","w_bgi","w_asym"),
              c("L3_full","n_L3","w_esi_L3","w_bgi_L3","w_asym_L3"))

sub <- merge(sub, w1, by = "L1_full", all.x = TRUE)
sub <- merge(sub, w2, by = "L2_full", all.x = TRUE)
sub <- merge(sub, w3, by = "L3_full", all.x = TRUE)

# Hierarchical shrinkage: small regions pull toward parent
tau3 <- 200; tau2 <- 500
sub[, s_L3 := ifelse(is.na(n_L3), 0, n_L3 / (n_L3 + tau3))]
sub[, s_L2 := ifelse(is.na(n_L2), 0, n_L2 / (n_L2 + tau2))]

# Fill NAs with equal weights as default
for (cmp in c("esi","bgi","asym")) {
  for (lev in c("L1","L2","L3")) {
    col <- paste0("w_", cmp, "_", lev)
    sub[is.na(get(col)), (col) := 1]
  }
}

# Build hierarchical effective weights
for (cmp in c("esi","bgi","asym")) {
  out <- paste0("w_", cmp, "_hier")
  sub[, (out) := s_L3 * get(paste0("w_", cmp, "_L3")) +
                 (1 - s_L3) * (s_L2 * get(paste0("w_", cmp, "_L2")) +
                                (1 - s_L2) * get(paste0("w_", cmp, "_L1")))]
}

# Composites
sub[, c3_L1 := (w_esi_L1*z_esi + w_bgi_L1*z_bgi + w_asym_L1*z_asym) / 3]
sub[, c3_L2 := (w_esi_L2*z_esi + w_bgi_L2*z_bgi + w_asym_L2*z_asym) / 3]
sub[, c3_L3 := (w_esi_L3*z_esi + w_bgi_L3*z_bgi + w_asym_L3*z_asym) / 3]
sub[, c3_hier := (w_esi_hier*z_esi + w_bgi_hier*z_bgi + w_asym_hier*z_asym) / 3]

cat("\n=== Composite correlations ===\n")
print(round(cor(sub[, .(c3_equal, c3_L1, c3_L2, c3_L3, c3_hier)], use = "p"), 3))

## SITECLCD prediction
sub_clcd <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
cat("\nSITECLCD n:", nrow(sub_clcd), "\n")
set.seed(2026)

fit <- function(f) ranger(f, data = sub_clcd, num.trees = 500, num.threads = 8, classification = FALSE)

m <- list(
  equal   = fit(SITECLCD ~ c3_equal),
  L1      = fit(SITECLCD ~ c3_L1),
  L2      = fit(SITECLCD ~ c3_L2),
  L3      = fit(SITECLCD ~ c3_L3),
  hier    = fit(SITECLCD ~ c3_hier),
  eq_L3   = fit(SITECLCD ~ c3_equal + c3_L3),
  eq_hier = fit(SITECLCD ~ c3_equal + c3_hier),
  all4    = fit(SITECLCD ~ c3_equal + c3_L1 + c3_L2 + c3_L3))

r <- data.table(
  model = names(m),
  OOB_R2 = round(sapply(m, function(x) x$r.squared), 4),
  OOB_RMSE = round(sqrt(sapply(m, function(x) x$prediction.error)), 3))
print(r)
fwrite(r, file.path(OUT, "ML_siteclcd_R2.csv"))

cat("\n=== Multi-level analysis complete. Outputs in", OUT, "===\n")
