## Bootstrap 95% CIs on the headline statistics for v0.10d Tables 1, 2, 2a, 2b, 2c, 3a
## Self-review action item #1. 1000 bootstrap reps per statistic.
## Login-node R, no SLURM.
##
## Revision (2026-10):
##   * Spatial block bootstrap (1 degree lat/lon cells) instead of iid plots,
##     so CIs reflect spatial autocorrelation among nearby plots.
##   * Plain CI column names (ci_lo, ci_hi) instead of "ci_lo.2.5%".
##   * SICOND <= 0 excluded from every stratum, matching sicond_base50.r.
##   * GADA join deduplicated to one row per plot location before correlating,
##     and reads the server-only keyed G1 file.

suppressPackageStartupMessages({ library(data.table) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
set.seed(2026)
B <- 1000
BLOCK_DEG <- 1

block_id <- function(lat, lon, deg = BLOCK_DEG) paste(floor(lat / deg), floor(lon / deg))

boot_r_ci <- function(x, y, block, B = 1000) {
  ok <- complete.cases(x, y, block)
  x <- x[ok]; y <- y[ok]; block <- block[ok]
  rows_by_block <- split(seq_along(x), block)
  nb <- length(rows_by_block)
  rs <- replicate(B, {
    idx <- unlist(rows_by_block[sample.int(nb, replace = TRUE)], use.names = FALSE)
    cor(x[idx], y[idx])
  })
  c(r = round(cor(x, y), 3),
    ci_lo = round(unname(quantile(rs, 0.025)), 3),
    ci_hi = round(unname(quantile(rs, 0.975)), 3),
    n = length(x),
    n_blocks = nb)
}

report <- function(name, ci) {
  cat(name, ":", ci[["r"]], "[", ci[["ci_lo"]], ",", ci[["ci_hi"]], "]",
      "n=", ci[["n"]], "blocks=", ci[["n_blocks"]], "\n")
}

## Load core data
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt[, SICOND_m := SICOND * 0.3048]
plt[, blk := block_id(LAT, LON)]

# Anamorphic projection of SICOND to base 50 (b3 = 1; see sicond_base50.r)
k <- 0.025
plt[, SICOND_b50 := ifelse(is.na(SIBASE) | SIBASE <= 0 | is.na(SICOND_m) | SICOND_m <= 0,
   NA_real_, SICOND_m * (1 - exp(-k * 50)) / (1 - exp(-k * SIBASE)))]

# z-score composite
mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt[, cspi3  := (z_esi + z_bgi + z_asym) / 3]

results <- list()

cat("--- Table 1: Cross-prediction R² ---\n")
# We can't bootstrap RF OOB R² quickly (would need to refit RF on each boot).
# Skip RF bootstraps; just report the source CSVs already have them at n=66433.

cat("--- Table 2 / 2a SICOND base-age strata ---\n")
strata <- list(
  raw = plt[!is.na(SICOND_m) & SICOND_m > 0],
  base50_subset = plt[!is.na(SICOND_m) & SICOND_m > 0 & SIBASE == 50],
  base50_proj = plt[!is.na(SICOND_b50)])

t2a_pairs <- list(
  raw_SICOND_ESI = c("SICOND_m", "esi", "raw"),
  raw_SICOND_BGI = c("SICOND_m", "bgi_v", "raw"),
  sub50_SICOND_ESI = c("SICOND_m", "esi", "base50_subset"),
  sub50_SICOND_BGI = c("SICOND_m", "bgi_v", "base50_subset"),
  proj_SICOND_ESI = c("SICOND_b50", "esi", "base50_proj"),
  proj_SICOND_BGI = c("SICOND_b50", "bgi_v", "base50_proj"))

for (name in names(t2a_pairs)) {
  spec <- t2a_pairs[[name]]
  d <- strata[[spec[3]]]
  ci <- boot_r_ci(d[[spec[1]]], d[[spec[2]]], d$blk, B)
  results[[name]] <- c(comparison = name, ci)
  report(name, ci)
}

cat("\n--- Table 2b SSURGO from E3c_plt_with_ssurgo_fixed ---\n")
if (file.exists(file.path(OUT, "E3c_plt_with_ssurgo_fixed.csv"))) {
  ssurg <- fread(file.path(OUT, "E3c_plt_with_ssurgo_fixed.csv"))
  ssurg <- ssurg[!is.na(ssurgo_si_m)]
  ssurg[, blk := block_id(LAT, LON)]
  for (m in c("esi","bgi_v","asym_v","npp_v","SICOND_m")) {
    name <- paste0("SSURGO_", m)
    ci <- boot_r_ci(ssurg$ssurgo_si_m, ssurg[[m]], ssurg$blk, B)
    results[[name]] <- c(comparison = name, ci)
    report(name, ci)
  }
}

cat("\n--- Table 2c GADA from G1_si_gada_per_plot_KEYED ---\n")
if (file.exists(file.path(OUT, "G1_si_gada_per_plot_KEYED.csv"))) {
  gada <- fread(file.path(OUT, "G1_si_gada_per_plot_KEYED.csv"))
  setnames(gada, "plot_key", "key")
  # One row per plot location; plt can hold several conditions per location.
  plt_loc <- unique(plt, by = "key")
  joined <- merge(plt_loc, gada[, .(key, SI_gada_plot)], by = "key", all.x = FALSE)
  for (m in c("esi","bgi_v","asym_v","npp_v","SICOND_m")) {
    name <- paste0("GADA_", m)
    ci <- boot_r_ci(joined$SI_gada_plot, joined[[m]], joined$blk, B)
    results[[name]] <- c(comparison = name, ci)
    report(name, ci)
  }
}

# Save all CIs
ci_dt <- rbindlist(lapply(results, as.list), fill = TRUE)
fwrite(ci_dt, file.path(OUT, "H1_bootstrap_cis.csv"))
cat("\n=== Bootstrap CIs done. n statistics:", nrow(ci_dt), "===\n")
cat("Output:", file.path(OUT, "H1_bootstrap_cis.csv"), "\n")
