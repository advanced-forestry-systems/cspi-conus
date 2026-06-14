## Step 2: GADA refit of site index from NA_SITREE height-age records.
##
## Cieszewski-Bailey base-age-invariant Chapman-Richards GADA form:
##
##   H_t  = b1 * (1 - exp(-b2 * t))^b3
##   SI50 = b1 * (1 - exp(-b2 * 50))^b3
##
## Polymorphic GADA derivation: site quality enters through b1 (asymptote
## allowed to vary by site). Cieszewski (2002, For. Sci. 48: 7-23) shows
## that for any pair (H_obs, A_obs) the implicit SI at base 50 is
##
##   SI50 = H_obs * ((1 - exp(-b2 * 50)) / (1 - exp(-b2 * A_obs)))^b3
##
## We fit b2 and b3 globally per major species group, then derive SI50
## per tree. Aggregate to plot level via weighted mean.
##
## Approach is anamorphic (single b2, b3 per species) for tractability.
## True polymorphic GADA would let b3 vary; left for future work.

suppressPackageStartupMessages({ library(data.table); library(nlme) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

sit <- fread("/users/PUOM0008/crsfaaron/SiteIndex/NA_SITREE.csv")
cat("site tree records:", nrow(sit), "\n")
cat("cols:", paste(names(sit), collapse = ", "), "\n")

## Quality filters
sit <- sit[!is.na(HT) & !is.na(AGEDIA) & HT > 0 & AGEDIA >= 10 & AGEDIA <= 200]
cat("after filter:", nrow(sit), "\n")

## Major species groups by SPCD count
top_spcd <- sit[, .N, by = SPCD][order(-N)][1:12]
cat("top 12 species:\n"); print(top_spcd)
fwrite(top_spcd, file.path(OUT, "G0_top_species.csv"))

## ===== GADA fit per major species =====
## Chapman-Richards: H = b1 * (1 - exp(-b2 * A))^b3
## Anamorphic (single b2, b3 per species)

results <- list()
for (i in seq_len(min(12, nrow(top_spcd)))) {
  sp <- top_spcd$SPCD[i]
  d <- sit[SPCD == sp]
  if (nrow(d) < 100) next
  cat("\n=== SPCD", sp, "n =", nrow(d), "===\n")
  fit <- try(nls(HT ~ b1 * (1 - exp(-b2 * AGEDIA))^b3,
                 data = d,
                 start = list(b1 = 35, b2 = 0.03, b3 = 1.2),
                 control = nls.control(maxiter = 200, warnOnly = TRUE)),
             silent = TRUE)
  if (inherits(fit, "try-error")) {
    cat("  fit failed for SPCD", sp, "\n")
    next
  }
  cf <- coef(fit)
  cat("  b1 =", round(cf["b1"], 2), "  b2 =", round(cf["b2"], 4),
      "  b3 =", round(cf["b3"], 3), "\n")
  d[, SI_gada := HT * ((1 - exp(-cf["b2"] * 50)) /
                       (1 - exp(-cf["b2"] * AGEDIA)))^cf["b3"]]
  results[[as.character(sp)]] <- d[, .(ID, LAT, LON, SPCD, HT, AGEDIA, SI_gada,
                                      b2 = cf["b2"], b3 = cf["b3"])]
}

all_gada <- rbindlist(results)
cat("\nTotal GADA SI per tree:", nrow(all_gada), "\n")

## ===== Aggregate to plot level =====
all_gada[, plot_key := paste0(round(LAT, 4), "_", round(LON, 4))]
plot_gada <- all_gada[!is.na(SI_gada) & SI_gada > 0 & SI_gada < 80,
  .(SI_gada_plot = mean(SI_gada),
    SI_gada_n   = .N,
    n_species   = uniqueN(SPCD)),
  by = plot_key]
cat("GADA plot keys:", nrow(plot_gada), "\n")
fwrite(plot_gada, file.path(OUT, "G1_si_gada_per_plot.csv"))

## ===== Join to multidim_v3 plt table =====
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt[, SICOND_m := SICOND * 0.3048]
plt <- merge(plt, plot_gada, by.x = "key", by.y = "plot_key", all.x = TRUE)
n_with <- sum(!is.na(plt$SI_gada_plot))
cat("plots with GADA SI:", n_with, "\n")

## ===== Correlations with all measures =====
sub <- plt[!is.na(SI_gada_plot) & !is.na(esi) & !is.na(bgi_v) & !is.na(asym_v) &
           !is.na(npp_v) & !is.na(SICOND_m)]
cat("Complete-case n:", nrow(sub), "\n")

g3 <- data.table(
  measure = c("ESI_v7_predicted", "BGI", "Asym", "NPP",
              "SICOND_raw_per_region", "CSPI_3comp"),
  r_with_SI_GADA = round(c(
    cor(sub$SI_gada_plot, sub$esi   ),
    cor(sub$SI_gada_plot, sub$bgi_v ),
    cor(sub$SI_gada_plot, sub$asym_v),
    cor(sub$SI_gada_plot, sub$npp_v ),
    cor(sub$SI_gada_plot, sub$SICOND_m),
    {
      mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
      sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
      z_esi  <- pmax(pmin((sub$esi    - mu$esi ) / sd$esi , 3), -3)
      z_bgi  <- pmax(pmin((sub$bgi_v  - mu$bgi ) / sd$bgi , 3), -3)
      z_asym <- pmax(pmin((sub$asym_v - mu$asym) / sd$asym, 3), -3)
      cor(sub$SI_gada_plot, (z_esi + z_bgi + z_asym) / 3)
    }
  ), 3),
  n = nrow(sub)
)
print(g3)
fwrite(g3, file.path(OUT, "G2_si_gada_correlations.csv"))

## ===== Side-by-side: 3 site-index measures =====
m3 <- round(cor(sub[, .(SICOND_m, SI_gada_plot, esi)]), 3)
dimnames(m3) <- list(c("SICOND_raw","SI_GADA","ESI_v7"),
                     c("SICOND_raw","SI_GADA","ESI_v7"))
cat("\n=== Three SI measures vs each other ===\n")
print(m3)
fwrite(as.data.table(m3, keep.rownames = "row"),
       file.path(OUT, "G3_three_si_pairwise.csv"))

cat("\n=== G4: GADA SI vs BGI / ESI_v7 side by side ===\n")
g4 <- data.table(
  si_measure = c("SICOND_raw", "SI_GADA_anamorphic", "ESI_v7_predicted"),
  r_with_BGI = round(c(
    cor(sub$SICOND_m,  sub$bgi_v),
    cor(sub$SI_gada_plot, sub$bgi_v),
    cor(sub$esi,           sub$bgi_v)
  ), 3),
  n = nrow(sub)
)
print(g4)
fwrite(g4, file.path(OUT, "G4_si_vs_bgi_side_by_side.csv"))

cat("\n=== GADA refit done. Outputs in", OUT, "===\n")
