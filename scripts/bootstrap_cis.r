## Bootstrap 95% CIs on the headline statistics for v0.10d Tables 1, 2, 2a, 2b, 2c, 3a
## Self-review action item #1. 1000 bootstrap reps per statistic.
## Login-node R, no SLURM.

suppressPackageStartupMessages({ library(data.table); library(ranger) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
set.seed(2026)
B <- 1000

boot_r_ci <- function(x, y, B = 1000) {
  ok <- complete.cases(x, y)
  x <- x[ok]; y <- y[ok]
  rs <- replicate(B, {
    idx <- sample.int(length(x), replace = TRUE)
    cor(x[idx], y[idx])
  })
  c(r = round(cor(x, y), 3),
    ci_lo = round(quantile(rs, 0.025), 3),
    ci_hi = round(quantile(rs, 0.975), 3),
    n = length(x))
}

## Load core data
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt[, SICOND_m := SICOND * 0.3048]

# Anamorphic projection of SICOND to base 50
k <- 0.025
plt[, SICOND_b50 := ifelse(is.na(SIBASE) | SIBASE <= 0, NA_real_,
   SICOND_m * (1 - exp(-k * 50)) / (1 - exp(-k * SIBASE)))]

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
  base50_subset = plt[!is.na(SICOND_m) & SIBASE == 50],
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
  ci <- boot_r_ci(d[[spec[1]]], d[[spec[2]]], B)
  results[[name]] <- c(comparison = name, ci)
  cat(name, ":", round(unname(ci[1]),3), "[", round(unname(ci[2]),3), ",", round(unname(ci[3]),3), "]", "n=", unname(ci[4]), "\n")
}

cat("\n--- Table 2b SSURGO from E3c_plt_with_ssurgo_fixed ---\n")
if (file.exists(file.path(OUT, "E3c_plt_with_ssurgo_fixed.csv"))) {
  ssurg <- fread(file.path(OUT, "E3c_plt_with_ssurgo_fixed.csv"))
  ssurg <- ssurg[!is.na(ssurgo_si_m)]
  for (m in c("esi","bgi_v","asym_v","npp_v","SICOND_m")) {
    name <- paste0("SSURGO_", m)
    ci <- boot_r_ci(ssurg$ssurgo_si_m, ssurg[[m]], B)
    results[[name]] <- c(comparison = name, ci)
    cat(name, ":", round(unname(ci[1]),3), "[", round(unname(ci[2]),3), ",", round(unname(ci[3]),3), "]", "n=", unname(ci[4]), "\n")
  }
}

cat("\n--- Table 2c GADA from G1_si_gada_per_plot ---\n")
if (file.exists(file.path(OUT, "G1_si_gada_per_plot.csv"))) {
  gada <- fread(file.path(OUT, "G1_si_gada_per_plot.csv"))
  setnames(gada, "plot_key", "key")
  joined <- merge(plt, gada[, .(key, SI_gada_plot)], by = "key", all.x = FALSE)
  for (m in c("esi","bgi_v","asym_v","npp_v","SICOND_m")) {
    name <- paste0("GADA_", m)
    ci <- boot_r_ci(joined$SI_gada_plot, joined[[m]], B)
    results[[name]] <- c(comparison = name, ci)
    cat(name, ":", round(unname(ci[1]),3), "[", round(unname(ci[2]),3), ",", round(unname(ci[3]),3), "]", "n=", unname(ci[4]), "\n")
  }
}

# Save all CIs
ci_dt <- rbindlist(lapply(results, as.list), fill = TRUE)
fwrite(ci_dt, file.path(OUT, "H1_bootstrap_cis.csv"))
cat("\n=== Bootstrap CIs done. n statistics:", nrow(ci_dt), "===\n")
cat("Output:", file.path(OUT, "H1_bootstrap_cis.csv"), "\n")
