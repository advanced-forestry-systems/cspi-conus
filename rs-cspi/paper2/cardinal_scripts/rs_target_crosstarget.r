#!/usr/bin/env Rscript
# Track 3 (plot-level proxy for cross-target spatial agreement).
# Merges the OOB predicted surfaces for all targets at the 61k plot locations
# and computes pairwise Pearson r between target-specific predicted values and
# a per-plot CV across z-standardised predictions. This measures whether the v3
# environmental stack drives the targets toward the same CONUS spatial pattern,
# without yet committing the heavy 30 m surface prediction.

suppressPackageStartupMessages({ library(data.table) })
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
files <- c(npp="PIX22_npp_predictions.csv", gpp="PIX22_gpp_obs_predictions.csv",
           ch="PIX22_ch_m_predictions.csv", agbd="PIX22_agbd_predictions.csv",
           cms_agb16="PIX22_cms_agb16_predictions.csv", cms_agbchg="PIX22_cms_agbchg_predictions.csv")
m <- NULL
for (tg in names(files)) {
  d <- fread(file.path(WORK, files[[tg]]))
  pc <- intersect(c("pred","npp_pred"), names(d))[1]
  d <- d[, .(p = mean(get(pc), na.rm=TRUE)), by=ID]   # dedup repeated IDs
  setnames(d, "p", tg)
  m <- if (is.null(m)) d else merge(m, d, by="ID", all=TRUE)
}
cat("merged plots:", nrow(m), " targets:", ncol(m)-1, "\n")

cols <- names(files)
cmat <- cor(m[, ..cols], use="pairwise.complete.obs", method="pearson")
cat("\n=== pairwise Pearson r between predicted target surfaces (plot level) ===\n")
print(round(cmat, 3))
fwrite(as.data.table(round(cmat,3), keep.rownames="target"),
       file.path(WORK, "PIX50_crosstarget_pearson.csv"))

# flux-vs-structure block means
flux <- c("npp","gpp"); struct <- c("agbd","ch","cms_agb16")
cat("\nmean r within flux targets:", round(mean(cmat[flux,flux][upper.tri(cmat[flux,flux])]),3), "\n")
cat("mean r within structural targets:",
    round(mean(cmat[struct,struct][upper.tri(cmat[struct,struct])]),3), "\n")
cat("mean r flux-vs-structural:", round(mean(cmat[flux,struct]),3), "\n")

# per-plot CV across z-standardised predictions (consensus dispersion)
z <- copy(m)
for (c in cols) z[[c]] <- as.numeric(scale(z[[c]]))
z[, consensus := rowMeans(.SD, na.rm=TRUE), .SDcols=cols]
z[, disp_sd  := apply(.SD, 1, sd, na.rm=TRUE), .SDcols=cols]
cat("\nconsensus z dispersion (SD across targets) summary:\n"); print(summary(z$disp_sd))
fwrite(z[, .(ID, consensus, disp_sd)], file.path(WORK, "PIX51_consensus_dispersion.csv"))
cat("\n=== DONE Track 3 plot-level ===\n")
