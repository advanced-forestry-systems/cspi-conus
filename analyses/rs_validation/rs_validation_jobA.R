#!/usr/bin/env Rscript
# Job A: repeat-RS structural validation of the CSPI productivity surfaces at FIA plots
# Question: do observed MODIS NPP (mean + interannual CV) and observed LANDFIRE canopy
# height track the existing ESI / BGI / Asym / composite measures, and which measure
# tracks observed canopy height best (feasibility precursor to a CH-increment map)?
# R / data.table + terra. Headless. Scratch-first. Seed set. Errors -> error_log.txt.

set.seed(20260621)
suppressWarnings(suppressMessages({
  library(data.table); library(terra)
}))

WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
dir.create(WORK, showWarnings = FALSE, recursive = TRUE)
elog <- file.path(WORK, "error_log.txt")
logmsg <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(), "%H:%M:%S"), paste0(...)))
trap <- function(expr, what) tryCatch(expr, error = function(e) {
  cat(sprintf("ERROR %s: %s\n", what, conditionMessage(e)), file = elog, append = TRUE)
  logmsg("ERROR ", what, ": ", conditionMessage(e)); NULL })

V7  <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
LF  <- "/fs/scratch/PUOM0008/crsfaaron/sae-aux/landfire/LF2023_CH_CONUS.tif"
LFL <- "/fs/scratch/PUOM0008/crsfaaron/sae-aux/landfire/LF2023_CH.csv"

# ---- 1. Load plot-level productivity measures + observed MODIS NPP ----
logmsg("Loading plot tables")
core <- trap(fread(file.path(V7, "cspi_4c_plot_values.csv")), "read cspi_4c")
npp  <- trap(fread(file.path(V7, "rs_mod17_extract.csv")), "read mod17")
stopifnot(!is.null(core), !is.null(npp))

# keep observed MODIS NPP/GPP, drop dup coords
npp <- npp[, .(ID, npp_obs = npp_mean, npp_obs_cv = npp_cv, gpp_obs = gpp_mean)]
dt <- merge(core, npp, by = "ID", all.x = TRUE)
logmsg("Joined core+NPP: n = ", nrow(dt))

# ---- 2. Extract observed LANDFIRE 2023 canopy height at plots ----
logmsg("Extracting LANDFIRE CH at plot coordinates")
ch_ok <- FALSE
trap({
  r <- rast(LF)
  pts <- vect(data.frame(ID = dt$ID, x = dt$LON, y = dt$LAT),
              geom = c("x", "y"), crs = "EPSG:4326")
  pts <- project(pts, crs(r))
  ex  <- terra::extract(r, pts)
  chv <- data.table(ID = dt$ID, ch_class = ex[[2]])
  # LANDFIRE CH is classified; map class -> representative height via legend if parseable
  leg <- trap(fread(LFL), "read LF legend")
  if (!is.null(leg)) {
    nm <- names(leg)
    valcol <- nm[grepl("value|VALUE|^Value", nm)][1]
    labcol <- nm[grepl("CLASSNAMES|Classnames|LABEL|Label|EVT|HEIGHT|Forest", nm)][1]
    if (!is.na(valcol) && !is.na(labcol)) {
      lab <- as.character(leg[[labcol]])
      # pull first numeric range midpoint from labels like "Forest Height 5 to 10 meters"
      mid <- vapply(lab, function(s){
        n <- as.numeric(regmatches(s, gregexpr("[0-9]+\\.?[0-9]*", s))[[1]])
        if (length(n) >= 2) mean(n[1:2]) else if (length(n)==1) n[1] else NA_real_
      }, numeric(1))
      legmap <- data.table(ch_class = as.integer(leg[[valcol]]), ch_m = as.numeric(mid))
      chv <- merge(chv, legmap, by = "ch_class", all.x = TRUE)
    }
  }
  if (!"ch_m" %in% names(chv)) chv[, ch_m := as.numeric(ch_class)]  # fallback: ordinal
  # non-forest / NoData -> NA
  chv[ch_class <= 0 | is.na(ch_class), ch_m := NA_real_]
  dt <<- merge(dt, chv[, .(ID, ch_class, ch_m)], by = "ID", all.x = TRUE)
  ch_ok <<- TRUE
}, "LANDFIRE extract")
logmsg("CH extracted, non-NA = ", if (ch_ok) sum(!is.na(dt$ch_m)) else 0)

fwrite(dt, file.path(WORK, "plots_validation_joined.csv"))

# ---- 3. Correlation matrix: productivity measures vs observed RS ----
measures <- c(ESI = "SI", BGI = "bgi", Asym = "asym",
              NPP_miami = "npp_miami", Composite = "cspi_4c_0100")
observed <- c(NPP_obs = "npp_obs", NPP_obs_CV = "npp_obs_cv",
              GPP_obs = "gpp_obs", CanopyHt_LF2023 = "ch_m")
measures <- measures[measures %in% names(dt)]
observed <- observed[observed %in% names(dt)]

cor_rows <- list()
for (mn in names(measures)) for (on in names(observed)) {
  x <- dt[[measures[mn]]]; y <- dt[[observed[on]]]
  ok <- is.finite(x) & is.finite(y)
  n  <- sum(ok)
  if (n > 50) {
    rp <- suppressWarnings(cor(x[ok], y[ok], method = "pearson"))
    rs <- suppressWarnings(cor(x[ok], y[ok], method = "spearman"))
  } else { rp <- rs <- NA_real_ }
  cor_rows[[paste(mn, on)]] <- data.table(measure = mn, observed = on,
                                          n = n, pearson = rp, spearman = rs)
}
cortab <- rbindlist(cor_rows)
fwrite(cortab, file.path(WORK, "RS_validation_correlations.csv"))
logmsg("Wrote correlation table")
print(dcast(cortab, measure ~ observed, value.var = "spearman"))

# ---- 4. Which combination best predicts observed canopy height? (feasibility signal) ----
# Quick OLS: observed CH ~ each measure, and ~ ESI+BGI+Asym jointly. Report adj R^2.
ch_fit <- list()
if (ch_ok && sum(is.finite(dt$ch_m)) > 200) {
  sub <- dt[is.finite(ch_m) & is.finite(SI) & is.finite(bgi) & is.finite(asym)]
  for (mn in names(measures)) {
    f <- trap(lm(ch_m ~ get(measures[mn]), data = sub), paste("lm", mn))
    if (!is.null(f)) ch_fit[[mn]] <- data.table(model = mn, adj_r2 = summary(f)$adj.r.squared)
  }
  fj <- trap(lm(ch_m ~ SI + bgi + asym, data = sub), "lm joint")
  if (!is.null(fj)) ch_fit[["ESI+BGI+Asym"]] <-
    data.table(model = "ESI+BGI+Asym", adj_r2 = summary(fj)$adj.r.squared)
  chtab <- rbindlist(ch_fit)
  fwrite(chtab, file.path(WORK, "CH_predictability.csv"))
  logmsg("Wrote CH predictability table"); print(chtab)
}

# ---- 5. Headless figures ----
trap({
  png(file.path(WORK, "F_rs_validation_heatmap.png"), width = 1700, height = 1200, res = 300)
  m <- as.matrix(dcast(cortab, measure ~ observed, value.var = "spearman")[, -1])
  rownames(m) <- dcast(cortab, measure ~ observed, value.var = "spearman")$measure
  par(mar = c(7, 7, 3, 2))
  image(t(m[nrow(m):1, , drop = FALSE]), axes = FALSE,
        col = hcl.colors(21, "Blue-Red 3"), zlim = c(-1, 1))
  axis(1, at = seq(0, 1, length.out = ncol(m)), labels = colnames(m), las = 2, cex.axis = 0.7)
  axis(2, at = seq(0, 1, length.out = nrow(m)), labels = rev(rownames(m)), las = 1, cex.axis = 0.7)
  title("Spearman: productivity measures vs observed repeat-RS")
  for (i in 1:nrow(m)) for (j in 1:ncol(m))
    text((j-1)/(ncol(m)-1), (nrow(m)-i)/(nrow(m)-1),
         sprintf("%.2f", m[i, j]), cex = 0.7)
  dev.off()
}, "heatmap")

trap({
  if (ch_ok && sum(is.finite(dt$ch_m)) > 200) {
    png(file.path(WORK, "F_ch_vs_composite.png"), width = 1500, height = 1300, res = 300)
    s <- dt[is.finite(ch_m) & is.finite(cspi_4c_0100)]
    if (nrow(s) > 5000) s <- s[sample(.N, 5000)]
    plot(s$cspi_4c_0100, s$ch_m, pch = 16, cex = 0.3,
         col = rgb(0,0.3,0.5,0.25), xlab = "Composite productivity (0-100)",
         ylab = "Observed LANDFIRE 2023 canopy height (m, class midpoint)",
         main = "Observed canopy height vs composite")
    abline(lm(ch_m ~ cspi_4c_0100, data = s), col = "red", lwd = 2)
    dev.off()
  }
}, "scatter")

gc()
logmsg("Job A complete. Outputs in ", WORK)
cat("DONE\n", file = file.path(WORK, "_jobA_status.txt"))
