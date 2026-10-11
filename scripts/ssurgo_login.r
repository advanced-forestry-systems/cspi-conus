## Login-node SSURGO SI extraction (canonical SSURGO script).
## SDA web service is reachable from login but not compute nodes on Cardinal.
## This script: (a) extracts unique mukeys at FIA plot locations from the
## existing gSSURGO mukey raster, (b) hits SDA in chunks for the coforprod
## table, (c) writes the joined plot table for downstream compute use.
##
## Revision (2026-10): factor-safe mukey join (formerly in ssurgo_join_fix.r),
## SDA retries with a failed-mukey log, and two-stage per-mukey aggregation that
## no longer averages across base ages. E1b/E2b/E3b must be regenerated.
## The E3b output contains plot coordinates and stays on the server.
##
## Run via: ssh cardinal "bash -lc 'module load gcc/12.3.0 gdal/3.7.3 R/4.4.0 && cd /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3 && Rscript --vanilla ssurgo_login.r'"

suppressPackageStartupMessages({
  library(data.table); library(terra); library(soilDB)
})

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

MUKEY_TIF <- "/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/environmental_data/gssurgo/mukey_raster.tif"

cat("--- Step 1: extract mukey at FIA plot locations ---\n")
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots:", nrow(plt), "\n")
mukey_r <- rast(MUKEY_TIF)
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON", "LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(mukey_r))
## The mukey raster extracts as a factor; as.integer() alone returns the level
## index, not the mukey. Go through the label.
mk <- terra::extract(mukey_r, pts, ID = FALSE)[, 1]
plt_xy[, mukey := as.integer(as.character(mk))]
cat("with mukey:", sum(!is.na(plt_xy$mukey)), "\n")
uniq <- unique(plt_xy$mukey[!is.na(plt_xy$mukey)])
cat("unique mukeys:", length(uniq), "\n")

cat("--- Step 2: SDA queries for coforprod ---\n")
## SDA_query can signal an error or return a try-error; retry with backoff and
## keep a list of mukeys whose chunk never succeeded.
sda_retry <- function(q, tries = 4) {
  for (k in seq_len(tries)) {
    res <- tryCatch(SDA_query(q), error = function(e) e)
    if (!inherits(res, c("error", "try-error"))) return(list(ok = TRUE, res = res))
    Sys.sleep(2^k)
  }
  list(ok = FALSE, res = NULL)
}
chunk_size <- 800
rows_list <- list()
failed <- integer()
for (i in seq(1, length(uniq), by = chunk_size)) {
  mks <- uniq[i:min(i + chunk_size - 1, length(uniq))]
  q <- paste0(
    "SELECT mu.mukey, cp.cokey, c.compname, c.comppct_r, ",
    "cp.plantsciname, cp.siteindexbase, cp.siteindex_r ",
    "FROM mapunit mu ",
    "INNER JOIN component c ON c.mukey = mu.mukey ",
    "INNER JOIN coforprod cp ON cp.cokey = c.cokey ",
    "WHERE mu.mukey IN (", paste(mks, collapse = ","), ") ",
    "AND cp.siteindex_r IS NOT NULL")
  r <- sda_retry(q)
  if (!r$ok) {
    failed <- c(failed, mks)
    cat("chunk", i, "FAILED after retries\n")
  } else if (!is.null(r$res) && nrow(r$res)) {
    rows_list[[length(rows_list) + 1]] <- setDT(r$res)
    cat("chunk", i, "rows:", nrow(r$res), "\n")
  }
  Sys.sleep(0.5)
}
sda <- rbindlist(rows_list, fill = TRUE)
cat("total SDA rows:", nrow(sda), " mukeys in failed chunks:", length(failed), "\n")
fwrite(sda, file.path(OUT, "E0b_sda_raw.csv"))
fwrite(data.table(mukey = failed), file.path(OUT, "E0b_failed_mukeys.csv"))
if (!nrow(sda)) stop("No SDA rows returned; check SDA connectivity (login node only)")

cat("--- Step 3: per-mukey site index ---\n")
## Two-stage aggregation: average species within a component first, then
## weight components by comppct_r. Weighting raw rows by comppct_r let a
## component with more species rows count more. Rows with an explicit base age
## other than 50 are dropped instead of being averaged with base-50 values;
## rows with no recorded base are kept and counted.
sda[, `:=`(siteindex_r = as.numeric(siteindex_r),
           siteindexbase = as.numeric(siteindexbase),
           comppct_r = as.numeric(comppct_r))]
sda <- sda[!is.na(siteindex_r) & siteindex_r > 0]
cat("rows by base age (NA = not recorded):\n")
print(sda[, .N, by = siteindexbase][order(-N)])
n_before <- nrow(sda)
sda <- sda[is.na(siteindexbase) | siteindexbase == 50]
cat("dropped", n_before - nrow(sda), "rows with an explicit non-50 base age\n")
comp <- sda[, .(si_ft     = mean(siteindex_r),
                comppct_r = comppct_r[1],
                n_species = uniqueN(plantsciname),
                base50    = any(siteindexbase == 50, na.rm = TRUE)),
            by = .(mukey, cokey)]
dom <- comp[, .(
  ssurgo_si_ft   = weighted.mean(si_ft, w = comppct_r, na.rm = TRUE),
  ssurgo_si_base = fifelse(any(base50), 50, NA_real_),
  n_components   = .N,
  n_species      = sum(n_species)
), by = mukey]
dom[, ssurgo_si_m := ssurgo_si_ft * 0.3048]
fwrite(dom, file.path(OUT, "E1b_ssurgo_si_per_mukey.csv"))
cat("mukeys with SSURGO SI:", nrow(dom), "\n")

cat("--- Step 4: join to plots and compute correlations ---\n")
dom[, mukey := as.integer(mukey)]
plt_xy <- merge(plt_xy, dom[, .(mukey, ssurgo_si_m, ssurgo_si_base)],
                by = "mukey", all.x = TRUE)
plt_xy[, SICOND_m := SICOND * 0.3048]
n_with_si <- sum(!is.na(plt_xy$ssurgo_si_m))
cat("plots with SSURGO SI:", n_with_si, "of", nrow(plt_xy), "\n")

cor_mat <- plt_xy[!is.na(ssurgo_si_m), .(
  measure = c("ESI", "BGI", "Asym", "NPP", "SICOND_raw"),
  r_with_SSURGO_SI = round(c(
    cor(ssurgo_si_m, esi   , use = "p"),
    cor(ssurgo_si_m, bgi_v , use = "p"),
    cor(ssurgo_si_m, asym_v, use = "p"),
    cor(ssurgo_si_m, npp_v , use = "p"),
    cor(ssurgo_si_m, SICOND_m, use = "p")
  ), 3),
  n = sum(!is.na(ssurgo_si_m) & !is.na(esi))
)]
print(cor_mat)
fwrite(cor_mat, file.path(OUT, "E2b_ssurgo_correlations.csv"))

fwrite(plt_xy[, .(key, LAT, LON, mukey, ssurgo_si_m, ssurgo_si_base,
                  SICOND_m, esi, bgi_v, asym_v, npp_v, SITECLCD, STDAGE)],
       file.path(OUT, "E3b_plt_with_ssurgo.csv"))

cat("\n=== SSURGO SI extraction (login-node) done. Outputs in", OUT, "===\n")
