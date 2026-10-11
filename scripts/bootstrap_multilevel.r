## Bootstrap 95% CIs on the multilevel R² values + tau sensitivity grid.
## Stress test #1 and #4 from STRESS_TEST_v0_10g.md.
##
## Revision (2026-10): the earlier version read ranger's OOB R² from a model fit
## on a bootstrap resample. Duplicated rows then sit both in-bag and OOB, which
## leaks and biases R² upward (the published "equal" CI [0.807, 0.816] excluded
## its own point estimate of 0.802). This version:
##   (a) resamples plots, fits on the in-bag rows, and scores R² on the
##       out-of-bootstrap rows only (no row in the test set appears in training);
##   (b) re-estimates the L1/L2/L3 PCA weights inside every replicate, so the
##       CI carries weight-estimation uncertainty;
##   (c) uses the same resample for every model, so paired deltas vs. the equal
##       composite get their own CIs.
## L3 assignment is now exact point-in-polygon (with a 5 km nearest-polygon
## fallback for coastal plots) instead of a 0.05 degree raster lookup.

suppressPackageStartupMessages({ library(data.table); library(ranger); library(terra) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5_ML2")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
B      <- 500
NTREE  <- 200
TAU3   <- 200; TAU2 <- 500

## ===== Exact L3 assignment =====
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

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(eco))
l3 <- assign_L3(eco, pts)
plt_xy[, L3_full := l3$NA_L3CODE]
plt_xy[L3_full == "0.0.0", L3_full := NA_character_]
plt_xy[, L1_full := sub("\\..*", "", L3_full)]
plt_xy[, L2_full := sub("^([0-9]+\\.[0-9]+)\\..*", "\\1", L3_full)]

mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt_xy[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt_xy[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt_xy[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt_xy[, c3_equal := (z_esi + z_bgi + z_asym) / 3]

sub <- plt_xy[!is.na(L3_full) & !is.na(z_esi) & !is.na(z_bgi) & !is.na(z_asym)]

calc_w <- function(d, gcol, min_n = 100) {
  np <- d[, .N, by = gcol]
  ks <- np[N >= min_n][[gcol]]
  L <- list()
  for (g in ks) {
    dg <- d[get(gcol) == g]
    pc <- prcomp(dg[, .(z_esi, z_bgi, z_asym)], center = TRUE, scale. = FALSE)
    w <- pc$rotation[, 1]; if (mean(w) < 0) w <- -w
    w <- w * 3 / sum(abs(w))
    L[[as.character(g)]] <- data.table(gid = g, n = nrow(dg),
      w_esi = w["z_esi"], w_bgi = w["z_bgi"], w_asym = w["z_asym"])
  }
  rbindlist(L)
}

## Estimate weights on `train`, apply them to `target`; returns target with
## c3_L1, c3_L2, c3_L3 and c3_hier columns at the given tau values.
build_composites <- function(train, target, tau3 = TAU3, tau2 = TAU2) {
  target <- copy(target)
  for (lev in c("L1", "L2", "L3")) {
    w <- calc_w(train, paste0(lev, "_full"), if (lev == "L3") 100 else 50)
    if (!nrow(w)) w <- data.table(gid = character(), n = integer(),
                                  w_esi = numeric(), w_bgi = numeric(), w_asym = numeric())
    setnames(w, c("gid","n","w_esi","w_bgi","w_asym"),
             c(paste0(lev, "_full"), paste0("n_", lev),
               paste0(c("w_esi_","w_bgi_","w_asym_"), lev)))
    target <- merge(target, w, by = paste0(lev, "_full"), all.x = TRUE)
  }
  target[, s3 := fifelse(is.na(n_L3), 0, n_L3 / (n_L3 + tau3))]
  target[, s2 := fifelse(is.na(n_L2), 0, n_L2 / (n_L2 + tau2))]
  for (cmp in c("esi","bgi","asym")) for (lev in c("L1","L2","L3")) {
    col <- paste0("w_", cmp, "_", lev)
    target[is.na(get(col)), (col) := 1]
  }
  for (cmp in c("esi","bgi","asym")) {
    target[, paste0("w_", cmp, "_h") :=
      s3 * get(paste0("w_", cmp, "_L3")) +
      (1 - s3) * (s2 * get(paste0("w_", cmp, "_L2")) +
                  (1 - s2) * get(paste0("w_", cmp, "_L1")))]
  }
  target[, c3_L1   := (w_esi_L1*z_esi + w_bgi_L1*z_bgi + w_asym_L1*z_asym) / 3]
  target[, c3_L2   := (w_esi_L2*z_esi + w_bgi_L2*z_bgi + w_asym_L2*z_asym) / 3]
  target[, c3_L3   := (w_esi_L3*z_esi + w_bgi_L3*z_bgi + w_asym_L3*z_asym) / 3]
  target[, c3_hier := (w_esi_h *z_esi + w_bgi_h *z_bgi + w_asym_h *z_asym) / 3]
  target
}

models <- list(
  equal     = SITECLCD ~ c3_equal,
  L3        = SITECLCD ~ c3_L3,
  hier      = SITECLCD ~ c3_hier,
  eq_L3     = SITECLCD ~ c3_equal + c3_L3,
  eq_hier   = SITECLCD ~ c3_equal + c3_hier,
  all_four  = SITECLCD ~ c3_equal + c3_L1 + c3_L2 + c3_L3)

test_R2 <- function(fit, test) {
  pred <- predict(fit, data = test, num.threads = 8)$predictions
  1 - sum((test$SITECLCD - pred)^2) / sum((test$SITECLCD - mean(test$SITECLCD))^2)
}

sub[, row_id := .I]
is_clcd <- function(d) d[!is.na(SITECLCD) & SITECLCD %in% 1:7]
set.seed(2026)

## ===== Stress test 1: out-of-bootstrap R², paired across models =====
cat("--- Out-of-bootstrap R² (B = ", B, ", ", NTREE, " trees) ---\n", sep = "")
boot_mat <- matrix(NA_real_, B, length(models), dimnames = list(NULL, names(models)))
for (b in seq_len(B)) {
  idx   <- sample.int(nrow(sub), replace = TRUE)
  inbag <- sub[idx]
  oob   <- sub[!row_id %in% idx]
  train <- is_clcd(build_composites(inbag, inbag))
  test  <- is_clcd(build_composites(inbag, oob))
  for (mn in names(models)) {
    fit <- ranger(models[[mn]], data = train, num.trees = NTREE,
                  num.threads = 8, classification = FALSE)
    boot_mat[b, mn] <- test_R2(fit, test)
  }
  if (b %% 25 == 0) cat("  replicate", b, "of", B, "\n")
}

q <- function(x, p) unname(quantile(x, p, na.rm = TRUE))
bres <- rbindlist(lapply(names(models), function(mn) {
  x <- boot_mat[, mn]
  data.table(model = mn,
             R2_mean = round(mean(x, na.rm = TRUE), 4),
             R2_lo95 = round(q(x, 0.025), 4),
             R2_hi95 = round(q(x, 0.975), 4),
             SE      = round(sd(x, na.rm = TRUE), 5),
             B       = sum(!is.na(x)))
}))
cat("\n=== Out-of-bootstrap CIs ===\n"); print(bres)
fwrite(bres, file.path(OUT, "STRESS1_bootstrap_CIs.csv"))

dres <- rbindlist(lapply(setdiff(names(models), "equal"), function(mn) {
  d <- boot_mat[, mn] - boot_mat[, "equal"]
  data.table(model = mn, vs = "equal",
             dR2_mean = round(mean(d, na.rm = TRUE), 4),
             dR2_lo95 = round(q(d, 0.025), 4),
             dR2_hi95 = round(q(d, 0.975), 4),
             share_positive = round(mean(d > 0, na.rm = TRUE), 3))
}))
cat("\n=== Paired deltas vs equal ===\n"); print(dres)
fwrite(dres, file.path(OUT, "STRESS1b_paired_deltas.csv"))

## ===== Stress test 4: tau sensitivity grid (full-data ranger OOB, no resampling) =====
cat("\n--- Tau hyperparameter sensitivity ---\n")
tau3_grid <- c(50, 100, 200, 500, 1000)
tau2_grid <- c(200, 500, 1000, 2000)
tau_results <- list()
for (t3 in tau3_grid) for (t2 in tau2_grid) {
  sc2 <- is_clcd(build_composites(sub, sub, tau3 = t3, tau2 = t2))
  m <- ranger(SITECLCD ~ c3_equal + c3_hier, data = sc2,
              num.trees = NTREE, num.threads = 8, classification = FALSE)
  tau_results[[paste0(t3, "_", t2)]] <- data.table(
    tau3 = t3, tau2 = t2, OOB_R2 = round(m$r.squared, 4))
  cat(sprintf("  tau3=%4d  tau2=%4d  OOB R² = %.4f\n", t3, t2, m$r.squared))
}
tres <- rbindlist(tau_results)
fwrite(tres, file.path(OUT, "STRESS4_tau_sensitivity.csv"))

cat("\n=== Stress tests done. Outputs in", OUT, "===\n")
