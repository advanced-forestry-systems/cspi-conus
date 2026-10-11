## Step 2: Site index refit from NA_SITREE height-age records.
##
## Anamorphic Chapman-Richards height model, one global fit per species:
##
##   H_t  = b1 * (1 - exp(-b2 * t))^b3
##
## Site quality enters only through b1, so for any (H_obs, A_obs) the implied
## site index at base 50 is the anamorphic solution
##
##   SI50 = H_obs * ((1 - exp(-b2 * 50)) / (1 - exp(-b2 * A_obs)))^b3
##
## This is not the polymorphic Cieszewski-Bailey GADA form (earlier versions of
## this header said it was); output names keep "gada" for continuity only.
## AGEDIA is breast-height age, so SI50 here is at breast-height base age 50
## and is not directly comparable to FIA SICOND in total-age SIBASE regions.
##
## Plot aggregation: SI_gada_plot is the mean across all site trees (all top-12
## species pooled, unchanged from earlier versions). SI_gada_dom, added
## 2026-10, uses only the plot's most-sampled species, which avoids mixing
## species with different curves.
##
## Outputs: G1_si_gada_per_plot_KEYED.csv carries the lat/lon plot key and is
## server-only. G1_si_gada_per_plot.csv carries an opaque plot_id and is the
## only version that may be copied into the public repository.

suppressPackageStartupMessages({ library(data.table) })

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

results <- list(); coefs <- list()
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
  ## warnOnly = TRUE returns non-converged fits instead of erroring; drop them.
  if (!isTRUE(fit$convInfo$isConv)) {
    cat("  fit did not converge for SPCD", sp, ":", fit$convInfo$stopMessage, "\n")
    next
  }
  cf <- coef(fit)
  cat("  b1 =", round(cf["b1"], 2), "  b2 =", round(cf["b2"], 4),
      "  b3 =", round(cf["b3"], 3), "\n")
  d[, SI_gada := HT * ((1 - exp(-cf["b2"] * 50)) /
                       (1 - exp(-cf["b2"] * AGEDIA)))^cf["b3"]]
  results[[as.character(sp)]] <- d[, .(ID, LAT, LON, SPCD, HT, AGEDIA, SI_gada,
                                      b2 = cf["b2"], b3 = cf["b3"])]
  coefs[[as.character(sp)]] <- data.table(SPCD = sp, n = nrow(d), b1 = cf["b1"],
                                          b2 = cf["b2"], b3 = cf["b3"])
}
fwrite(rbindlist(coefs), file.path(OUT, "G0b_cr_coefficients.csv"))

all_gada <- rbindlist(results)
cat("\nTotal GADA SI per tree:", nrow(all_gada), "\n")

## ===== Aggregate to plot level =====
all_gada[, plot_key := paste0(round(LAT, 4), "_", round(LON, 4))]
ok_gada <- all_gada[!is.na(SI_gada) & SI_gada > 0 & SI_gada < 80]
plot_gada <- ok_gada[,
  .(SI_gada_plot = mean(SI_gada),
    SI_gada_n   = .N,
    n_species   = uniqueN(SPCD)),
  by = plot_key]
dom_sp <- ok_gada[, .N, by = .(plot_key, SPCD)][order(plot_key, -N, SPCD)][, .SD[1], by = plot_key]
plot_dom <- ok_gada[dom_sp, on = .(plot_key, SPCD)][,
  .(SI_gada_dom = mean(SI_gada), SPCD_dom = SPCD[1]), by = plot_key]
plot_gada <- merge(plot_gada, plot_dom, by = "plot_key", all.x = TRUE)
cat("GADA plot keys:", nrow(plot_gada), "\n")
fwrite(plot_gada, file.path(OUT, "G1_si_gada_per_plot_KEYED.csv"))
fwrite(plot_gada[, c(list(plot_id = .I), .SD), .SDcols = !"plot_key"],
       file.path(OUT, "G1_si_gada_per_plot.csv"))

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
