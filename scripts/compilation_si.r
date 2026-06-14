## Step 1: Unified compilation SI as the clean SICOND comparator.
##
## Aaron's ALL_SI_m.csv compiles SI per FIA plot using a single common
## processing chain on the NA_SITREE height-age records. This is already
## a methodology-clean SI (no per-region FIA equation artifact). Use it as
## an immediate comparator before the true GADA refit.

suppressPackageStartupMessages({ library(data.table) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## Load joined table from multidim_v3
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots:", nrow(plt), "\n")

## Load unified compilation
si_comp <- fread("/users/PUOM0008/crsfaaron/SiteIndex/ALL_SI_m.csv")
cat("compilation rows:", nrow(si_comp), "\n")
cat("compilation cols head:", paste(head(names(si_comp), 8), collapse = ", "), "\n")

## Join by LAT/LON key, rounded
si_comp[, key := paste0(round(LAT, 4), "_", round(LON, 4))]
si_comp_uni <- si_comp[, .(SI_unified = mean(SI, na.rm = TRUE),
                           n_trees    = .N),
                       by = key]
cat("unique compilation keys:", nrow(si_comp_uni), "\n")

plt <- merge(plt, si_comp_uni, by = "key", all.x = TRUE)
n_with_si <- sum(!is.na(plt$SI_unified))
cat("plots with unified SI joined:", n_with_si, "of", nrow(plt), "\n")

## SICOND raw conversion
plt[, SICOND_m := SICOND * 0.3048]

## ===== Correlations =====
cat("\n=== F1: SI_unified correlations with all five measures + SICOND ===\n")
cor_unified <- plt[!is.na(SI_unified), .(
  measure = c("ESI_v7_predicted", "BGI", "Asym", "NPP", "SICOND_raw", "CSPI_3c"),
  r_with_SI_unified = round(c(
    cor(SI_unified, esi   , use = "p"),
    cor(SI_unified, bgi_v , use = "p"),
    cor(SI_unified, asym_v, use = "p"),
    cor(SI_unified, npp_v , use = "p"),
    cor(SI_unified, SICOND_m, use = "p"),
    {
      mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
      sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
      z_esi  <- pmax(pmin((plt$esi    - mu$esi ) / sd$esi , 3), -3)
      z_bgi  <- pmax(pmin((plt$bgi_v  - mu$bgi ) / sd$bgi , 3), -3)
      z_asym <- pmax(pmin((plt$asym_v - mu$asym) / sd$asym, 3), -3)
      cspi3  <- (z_esi + z_bgi + z_asym) / 3
      cor(plt$SI_unified, cspi3, use = "p")
    }
  ), 3),
  n = sum(!is.na(SI_unified) & !is.na(esi))
)]
print(cor_unified)
fwrite(cor_unified, file.path(OUT, "F1_SI_unified_correlations.csv"))

## ===== ESI vs SI_unified scatter diagnostic =====
cat("\n=== F2: ESI v7 (predicted) vs SI_unified (compiled, observed) ===\n")
sub <- plt[!is.na(SI_unified) & !is.na(esi)]
r_esi_uni <- round(cor(sub$SI_unified, sub$esi), 3)
rmse_esi_uni <- round(sqrt(mean((sub$esi - sub$SI_unified)^2)), 2)
bias <- round(mean(sub$esi - sub$SI_unified), 2)
cat("ESI v7 vs SI_unified: r =", r_esi_uni, "RMSE =", rmse_esi_uni,
    "bias =", bias, "n =", nrow(sub), "\n")
fwrite(data.table(comparison = "ESI_v7_vs_SI_unified",
                  r = r_esi_uni, rmse_m = rmse_esi_uni,
                  bias_m = bias, n = nrow(sub)),
       file.path(OUT, "F2_esi_vs_si_unified.csv"))

## ===== Headline comparison table =====
cat("\n=== F3: Five-site-index measures side by side ===\n")
## Compute pairwise SI vs SI correlations:
##   SICOND_raw (FIA per-region)
##   SI_unified (compilation, common processing — best available without GADA refit)
##   ESI_v7    (random-forest prediction of the compilation SI from climate)
sis <- plt[!is.na(SICOND_m) & !is.na(SI_unified) & !is.na(esi)]
mat <- matrix(NA, 3, 3, dimnames = list(
  c("SICOND_raw","SI_unified","ESI_v7"),
  c("SICOND_raw","SI_unified","ESI_v7")))
mat[,] <- round(cor(sis[, .(SICOND_m, SI_unified, esi)]), 3)
print(mat)
fwrite(as.data.table(mat, keep.rownames = "row"),
       file.path(OUT, "F3_three_si_measures.csv"))

cat("\n=== F4: Each SI measure vs BGI ===\n")
f4 <- data.table(
  si_measure = c("SICOND_raw", "SI_unified", "ESI_v7_predicted"),
  r_with_BGI = round(c(
    cor(sis$SICOND_m,  sis$bgi_v, use = "p"),
    cor(sis$SI_unified, sis$bgi_v, use = "p"),
    cor(sis$esi,        sis$bgi_v, use = "p")
  ), 3),
  r_with_ESI_v7 = round(c(
    cor(sis$SICOND_m,  sis$esi, use = "p"),
    cor(sis$SI_unified, sis$esi, use = "p"),
    cor(sis$esi,        sis$esi, use = "p")
  ), 3),
  n = nrow(sis)
)
print(f4)
fwrite(f4, file.path(OUT, "F4_si_vs_bgi.csv"))

## Save the joined plot table for downstream §3.5.3 use
fwrite(plt[, .(key, LAT, LON, SI_unified, n_trees,
               SICOND_m, esi, bgi_v, asym_v, npp_v, SITECLCD, STDAGE)],
       file.path(OUT, "F5_plt_with_si_unified.csv"))

cat("\n=== Compilation SI done. Outputs in", OUT, "===\n")
