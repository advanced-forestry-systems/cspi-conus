## Multi-level hierarchical composite — derived analytically from L3 codes.
## EPA Level III codes have format "X.Y.Z" where X = Level I, X.Y = Level II.
## We can derive L1 and L2 codes by parsing the L3 string, avoiding a second
## spatial extract. Reuses M5L3 ecoregion_L3_composite.r output where possible,
## else recomputes from the multidim_v2 plt + L3 PCA weights we already have.

suppressPackageStartupMessages({ library(data.table); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
L3_DIR <- file.path(V7_DIR, "multidim_v5_L3")
OUT    <- file.path(V7_DIR, "multidim_v5_ML2")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## Reload the L3 plot table from the L3 run output
## The ecoregion_L3_composite.r didn't save plot-level L3 codes, so we re-do
## ONLY the L3 spatial extract.

library(terra)
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]

cat("Loading shapefile and projecting...\n")
eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(eco))

## Exact point-in-polygon L3 assignment. An earlier version used a 0.05 degree
## raster lookup, which misassigned plots near region edges and dropped coastal
## plots; unmatched plots now fall back to the nearest land polygon within 5 km.
assign_L3 <- function(eco, pts, max_dist = 5000) {
  ex <- as.data.table(terra::extract(eco[, c("NA_L3CODE", "NA_L3NAME")], pts))
  ex <- ex[!is.na(NA_L3CODE)][, .SD[1], by = id.y]   # first match on shared edges
  out <- ex[data.table(id.y = seq_len(length(pts))), on = "id.y"]
  miss <- which(is.na(out$NA_L3CODE))
  if (length(miss)) {
    land <- eco[eco$NA_L3CODE != "0.0.0"]
    nn <- as.data.table(terra::nearest(pts[miss], land))
    ok <- nn$distance <= max_dist
    out[miss[ok], `:=`(NA_L3CODE = land$NA_L3CODE[nn$to_id[ok]],
                       NA_L3NAME = land$NA_L3NAME[nn$to_id[ok]])]
    cat("nearest-polygon fallback assigned", sum(ok), "of", length(miss), "unmatched plots\n")
  }
  out
}
cat("Assigning L3 by point-in-polygon...\n")
l3 <- assign_L3(eco, pts)
plt_xy[, `:=`(L3_full = l3$NA_L3CODE, L3_name = l3$NA_L3NAME)]
plt_xy[L3_full == "0.0.0", L3_full := NA_character_]
cat("plots with L3 code:", sum(!is.na(plt_xy$L3_full)), "\n")

## Derive L1 and L2 codes from the L3 string format "X.Y.Z"
plt_xy[, L1_full := sub("\\..*", "", L3_full)]              # X
plt_xy[, L2_full := sub("^([0-9]+\\.[0-9]+)\\..*", "\\1", L3_full)]  # X.Y
cat("derived L1 count:", length(unique(plt_xy$L1_full[!is.na(plt_xy$L1_full)])),
    " L2:", length(unique(plt_xy$L2_full[!is.na(plt_xy$L2_full)])), "\n")

## z-scores
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt_xy[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt_xy[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt_xy[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt_xy[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

sub <- plt_xy[!is.na(L3_full) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]
cat("complete-case n:", nrow(sub), "\n")

calc_w <- function(d, gcol, min_n = 100) {
  np <- d[, .N, by = gcol]
  ks <- np[N >= min_n][[gcol]]
  if (length(ks) == 0) return(data.table())
  L <- list()
  for (g in ks) {
    dg <- d[get(gcol) == g]
    pc <- prcomp(dg[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
    w <- pc$rotation[, 1]
    if (mean(w) < 0) w <- -w
    w <- w * 3 / sum(abs(w))
    L[[as.character(g)]] <- data.table(
      gid = g, n = nrow(dg),
      w_esi = w["z_esi"], w_bgi = w["z_bgi"], w_asym = w["z_asym"], any_negative = any(w < 0))
  }
  rbindlist(L)
}

w1 <- calc_w(sub, "L1_full", 50)
w2 <- calc_w(sub, "L2_full", 50)
w3 <- calc_w(sub, "L3_full", 100)
cat("L1 regions:", nrow(w1), "  L2:", nrow(w2), "  L3:", nrow(w3), "\n")
fwrite(w1, file.path(OUT, "MLM_L1_weights.csv"))
w1[, any_negative := NULL]  # flag kept in the CSV only
fwrite(w2, file.path(OUT, "MLM_L2_weights.csv"))
w2[, any_negative := NULL]  # flag kept in the CSV only
fwrite(w3, file.path(OUT, "MLM_L3_weights.csv"))
w3[, any_negative := NULL]  # flag kept in the CSV only

# Join
setnames(w1, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L1_full","n_L1","w_esi_L1","w_bgi_L1","w_asym_L1"))
setnames(w2, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L2_full","n_L2","w_esi_L2","w_bgi_L2","w_asym_L2"))
setnames(w3, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L3_full","n_L3","w_esi_L3","w_bgi_L3","w_asym_L3"))
sub <- merge(sub, w1, by = "L1_full", all.x = TRUE)
sub <- merge(sub, w2, by = "L2_full", all.x = TRUE)
sub <- merge(sub, w3, by = "L3_full", all.x = TRUE)

# Hierarchical shrinkage
tau3 <- 200; tau2 <- 500
sub[, s3 := ifelse(is.na(n_L3), 0, n_L3 / (n_L3 + tau3))]
sub[, s2 := ifelse(is.na(n_L2), 0, n_L2 / (n_L2 + tau2))]
for (cmp in c("esi","bgi","asym")) for (lev in c("L1","L2","L3")) {
  col <- paste0("w_", cmp, "_", lev)
  if (col %in% names(sub)) sub[is.na(get(col)), (col) := 1]
}
for (cmp in c("esi","bgi","asym")) {
  sub[, paste0("w_", cmp, "_h") :=
    s3 * get(paste0("w_", cmp, "_L3")) +
    (1 - s3) * (s2 * get(paste0("w_", cmp, "_L2")) +
                (1 - s2) * get(paste0("w_", cmp, "_L1")))]
}

sub[, c3_L1 := (w_esi_L1*z_esi + w_bgi_L1*z_bgi + w_asym_L1*z_asym) / 3]
sub[, c3_L2 := (w_esi_L2*z_esi + w_bgi_L2*z_bgi + w_asym_L2*z_asym) / 3]
sub[, c3_L3 := (w_esi_L3*z_esi + w_bgi_L3*z_bgi + w_asym_L3*z_asym) / 3]
sub[, c3_h  := (w_esi_h *z_esi + w_bgi_h *z_bgi + w_asym_h *z_asym) / 3]

cat("\n=== Composite correlations ===\n")
print(round(cor(sub[, .(c3_equal, c3_L1, c3_L2, c3_L3, c3_h)], use = "p"), 3))

# SITECLCD prediction
sc <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
cat("\nSITECLCD n:", nrow(sc), "\n")
set.seed(2026)
fit <- function(f) ranger(f, data = sc, num.trees = 500, num.threads = 8, classification = FALSE)
m <- list(
  equal = fit(SITECLCD ~ c3_equal),
  L1    = fit(SITECLCD ~ c3_L1),
  L2    = fit(SITECLCD ~ c3_L2),
  L3    = fit(SITECLCD ~ c3_L3),
  hier  = fit(SITECLCD ~ c3_h),
  eq_h  = fit(SITECLCD ~ c3_equal + c3_h),
  eq_L3 = fit(SITECLCD ~ c3_equal + c3_L3),
  all4  = fit(SITECLCD ~ c3_equal + c3_L1 + c3_L2 + c3_L3))
r <- data.table(
  model = names(m),
  OOB_R2 = round(sapply(m, function(x) x$r.squared), 4),
  OOB_RMSE = round(sqrt(sapply(m, function(x) x$prediction.error)), 3))
print(r)
fwrite(r, file.path(OUT, "MLM_siteclcd_R2.csv"))

cat("\n=== Multi-level analytical derivation done. Outputs in", OUT, "===\n")
