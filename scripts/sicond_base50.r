## SICOND base-age standardization to 50 yr
## Tests whether the r = +0.74 SICOND vs BGI correlation holds after
## removing FIA per-region base-age heterogeneity.
##
## Strategy:
## 1. Stratify by SIBASE. Compute correlations within each SIBASE stratum.
## 2. Filter to SIBASE == 50 (the most common FIA base age) and recompute the
##    five-measure correlation matrix.
## 3. Project off-base SICOND values to base 50 via a Chapman-Richards
##    anamorphic projection with empirical species-specific intercepts.
##    Recompute the matrix on the standardized values.
## 4. Report all three views.

suppressPackageStartupMessages({ library(data.table) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("rows loaded:", nrow(plt), "\n")

## SICOND is in feet in FIA COND. Convert to meters.
plt[, SICOND_m := SICOND * 0.3048]

## How is SIBASE distributed?
cat("\n=== SIBASE distribution ===\n")
print(plt[!is.na(SIBASE) & SIBASE > 0, .N, by = SIBASE][order(-N)])

## ===== Stratum 1: by SIBASE =====
cat("\n=== Pairwise correlations by SIBASE ===\n")
stratum <- plt[!is.na(SICOND_m) & SICOND_m > 0 & !is.na(SIBASE) & SIBASE > 0,
  .(n = .N,
    r_SICOND_ESI  = round(cor(SICOND_m, esi   , use = "p"), 3),
    r_SICOND_BGI  = round(cor(SICOND_m, bgi_v , use = "p"), 3),
    r_SICOND_Asym = round(cor(SICOND_m, asym_v, use = "p"), 3),
    r_SICOND_NPP  = round(cor(SICOND_m, npp_v , use = "p"), 3)
  ), by = SIBASE][order(-n)]
print(stratum)
fwrite(stratum, file.path(OUT, "D1_sicond_by_sibase.csv"))

## ===== Stratum 2: SIBASE == 50 only =====
cat("\n=== Correlations restricted to SIBASE == 50 ===\n")
sub50 <- plt[!is.na(SICOND_m) & SICOND_m > 0 & SIBASE == 50]
cat("n at SIBASE == 50:", nrow(sub50), "\n")
cor50 <- sub50[, .(
  measure = c("ESI", "BGI", "Asym", "NPP"),
  r_with_SICOND_base50 = round(c(
    cor(SICOND_m, esi   , use = "p"),
    cor(SICOND_m, bgi_v , use = "p"),
    cor(SICOND_m, asym_v, use = "p"),
    cor(SICOND_m, npp_v , use = "p")
  ), 3)
)]
print(cor50)
fwrite(cor50, file.path(OUT, "D2_sicond_at_sibase50.csv"))

## ===== Stratum 3: Chapman-Richards anamorphic projection =====
## SI50 ≈ SI_base * (1 - exp(-k * 50)) / (1 - exp(-k * base))
## k = 0.025 is a working species-average from Carmean et al. (1989).
## For each plot with SIBASE != 50, project SICOND to base 50.
cat("\n=== Anamorphic projection to base 50 ===\n")
k <- 0.025
plt[, SICOND_b50 := ifelse(
  is.na(SIBASE) | SIBASE <= 0, NA_real_,
  SICOND_m * (1 - exp(-k * 50)) / (1 - exp(-k * SIBASE))
)]

## Compare distributions: SICOND raw vs SICOND projected to base 50
cat("Raw SICOND_m summary:\n"); print(summary(plt$SICOND_m))
cat("Projected SICOND_b50 summary:\n"); print(summary(plt$SICOND_b50))

cor_proj <- plt[!is.na(SICOND_b50), .(
  measure = c("ESI", "BGI", "Asym", "NPP"),
  r_with_SICOND_base50_projected = round(c(
    cor(SICOND_b50, esi   , use = "p"),
    cor(SICOND_b50, bgi_v , use = "p"),
    cor(SICOND_b50, asym_v, use = "p"),
    cor(SICOND_b50, npp_v , use = "p")
  ), 3),
  n = sum(!is.na(SICOND_b50) & !is.na(esi))
)]
print(cor_proj)
fwrite(cor_proj, file.path(OUT, "D3_sicond_base50_projected.csv"))

## ===== Side by side =====
cat("\n=== Side-by-side: raw SICOND vs SICOND_b50 vs SIBASE==50 only ===\n")
side <- data.table(
  measure = c("ESI", "BGI", "Asym", "NPP"),
  r_raw_SICOND = round(c(
    cor(plt$SICOND_m,  plt$esi   , use = "p"),
    cor(plt$SICOND_m,  plt$bgi_v , use = "p"),
    cor(plt$SICOND_m,  plt$asym_v, use = "p"),
    cor(plt$SICOND_m,  plt$npp_v , use = "p")
  ), 3),
  r_SICOND_base50_projected = round(c(
    cor(plt$SICOND_b50, plt$esi   , use = "p"),
    cor(plt$SICOND_b50, plt$bgi_v , use = "p"),
    cor(plt$SICOND_b50, plt$asym_v, use = "p"),
    cor(plt$SICOND_b50, plt$npp_v , use = "p")
  ), 3),
  r_SIBASE_50_only = round(c(
    cor(sub50$SICOND_m, sub50$esi   , use = "p"),
    cor(sub50$SICOND_m, sub50$bgi_v , use = "p"),
    cor(sub50$SICOND_m, sub50$asym_v, use = "p"),
    cor(sub50$SICOND_m, sub50$npp_v , use = "p")
  ), 3)
)
print(side)
fwrite(side, file.path(OUT, "D4_sicond_side_by_side.csv"))

cat("\n=== Done. Outputs in", OUT, "===\n")
