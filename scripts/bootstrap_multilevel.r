## Bootstrap 95% CIs on the multilevel R² values + tau sensitivity grid.
## Stress test #1 and #4 from STRESS_TEST_v0_10g.md.

suppressPackageStartupMessages({ library(data.table); library(ranger); library(terra) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v5_ML2")
B <- 500

## Re-load (we don't have the plt table from the previous run saved with all
## composites, so quick reconstruction)
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
eco <- vect("/users/PUOM0008/crsfaaron/SiteIndex/NA_Eco_L3_WGS84.shp")
r_template <- rast(ext(eco), resolution = 0.05, crs = crs(eco))
eco$NA_L3_INT <- as.integer(as.factor(eco$NA_L3CODE))
r_eco <- rasterize(eco, r_template, field = "NA_L3_INT")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(eco))
plt_xy[, L3_int := terra::extract(r_eco, pts, ID = FALSE)[, 1]]
code_lookup <- data.table(L3_int = eco$NA_L3_INT, L3_full = eco$NA_L3CODE)
code_lookup <- unique(code_lookup, by = "L3_int")
plt_xy <- merge(plt_xy, code_lookup, by = "L3_int", all.x = TRUE)
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

w1 <- calc_w(sub, "L1_full", 50)
w2 <- calc_w(sub, "L2_full", 50)
w3 <- calc_w(sub, "L3_full", 100)
setnames(w1, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L1_full","n_L1","w_esi_L1","w_bgi_L1","w_asym_L1"))
setnames(w2, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L2_full","n_L2","w_esi_L2","w_bgi_L2","w_asym_L2"))
setnames(w3, c("gid","n","w_esi","w_bgi","w_asym"),
              c("L3_full","n_L3","w_esi_L3","w_bgi_L3","w_asym_L3"))
sub <- merge(sub, w1, by = "L1_full", all.x = TRUE)
sub <- merge(sub, w2, by = "L2_full", all.x = TRUE)
sub <- merge(sub, w3, by = "L3_full", all.x = TRUE)

# Fill NA weights with 1 (equal)
for (cmp in c("esi","bgi","asym")) for (lev in c("L1","L2","L3")) {
  col <- paste0("w_", cmp, "_", lev)
  sub[is.na(get(col)), (col) := 1]
}

sub[, c3_L1 := (w_esi_L1*z_esi + w_bgi_L1*z_bgi + w_asym_L1*z_asym) / 3]
sub[, c3_L2 := (w_esi_L2*z_esi + w_bgi_L2*z_bgi + w_asym_L2*z_asym) / 3]
sub[, c3_L3 := (w_esi_L3*z_esi + w_bgi_L3*z_bgi + w_asym_L3*z_asym) / 3]

# Hierarchical composite at the published tau values
sub[, s3_pub := ifelse(is.na(n_L3), 0, n_L3 / (n_L3 + 200))]
sub[, s2_pub := ifelse(is.na(n_L2), 0, n_L2 / (n_L2 + 500))]
for (cmp in c("esi","bgi","asym")) {
  sub[, paste0("w_", cmp, "_hpub") :=
    s3_pub * get(paste0("w_", cmp, "_L3")) +
    (1 - s3_pub) * (s2_pub * get(paste0("w_", cmp, "_L2")) +
                     (1 - s2_pub) * get(paste0("w_", cmp, "_L1")))]
}
sub[, c3_hier_pub := (w_esi_hpub*z_esi + w_bgi_hpub*z_bgi + w_asym_hpub*z_asym) / 3]

sc <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
set.seed(2026)

## ===== Stress test 1: Bootstrap CIs on each model's R² =====
cat("--- Bootstrap CIs on OOB R² (B = ", B, ") ---\n", sep = "")
fit_R2 <- function(d, formula) {
  ranger(formula, data = d, num.trees = 200, num.threads = 8,
         classification = FALSE)$r.squared
}
models <- list(
  equal     = SITECLCD ~ c3_equal,
  L3        = SITECLCD ~ c3_L3,
  hier      = SITECLCD ~ c3_hier_pub,
  eq_L3     = SITECLCD ~ c3_equal + c3_L3,
  eq_hier   = SITECLCD ~ c3_equal + c3_hier_pub,
  all_four  = SITECLCD ~ c3_equal + c3_L1 + c3_L2 + c3_L3)

boot_results <- list()
for (mn in names(models)) {
  cat("model:", mn, "...\n")
  boots <- replicate(B, {
    idx <- sample.int(nrow(sc), replace = TRUE)
    fit_R2(sc[idx], models[[mn]])
  })
  boot_results[[mn]] <- data.table(
    model = mn,
    R2_mean = round(mean(boots), 4),
    R2_lo95 = round(quantile(boots, 0.025), 4),
    R2_hi95 = round(quantile(boots, 0.975), 4),
    SE      = round(sd(boots), 5),
    B       = B)
}
bres <- rbindlist(boot_results)
cat("\n=== Bootstrap CIs ===\n")
print(bres)
fwrite(bres, file.path(OUT, "STRESS1_bootstrap_CIs.csv"))

## ===== Stress test 4: tau sensitivity grid =====
cat("\n--- Tau hyperparameter sensitivity ---\n")
tau3_grid <- c(50, 100, 200, 500, 1000)
tau2_grid <- c(200, 500, 1000, 2000)
tau_results <- list()
for (t3 in tau3_grid) for (t2 in tau2_grid) {
  s3 <- ifelse(is.na(sub$n_L3), 0, sub$n_L3 / (sub$n_L3 + t3))
  s2 <- ifelse(is.na(sub$n_L2), 0, sub$n_L2 / (sub$n_L2 + t2))
  for (cmp in c("esi","bgi","asym")) {
    sub[, paste0("w_", cmp, "_h_x") :=
      s3 * get(paste0("w_", cmp, "_L3")) +
      (1 - s3) * (s2 * get(paste0("w_", cmp, "_L2")) +
                   (1 - s2) * get(paste0("w_", cmp, "_L1")))]
  }
  sub[, c3_h_x := (w_esi_h_x*z_esi + w_bgi_h_x*z_bgi + w_asym_h_x*z_asym) / 3]
  sc2 <- sub[!is.na(SITECLCD) & SITECLCD %in% 1:7]
  m <- ranger(SITECLCD ~ c3_equal + c3_h_x, data = sc2,
              num.trees = 200, num.threads = 8, classification = FALSE)
  tau_results[[paste0(t3, "_", t2)]] <- data.table(
    tau3 = t3, tau2 = t2,
    OOB_R2 = round(m$r.squared, 4))
  cat(sprintf("  tau3=%4d  tau2=%4d  OOB R² = %.4f\n", t3, t2, m$r.squared))
}
tres <- rbindlist(tau_results)
fwrite(tres, file.path(OUT, "STRESS4_tau_sensitivity.csv"))

cat("\n=== Stress tests done. Outputs in", OUT, "===\n")
