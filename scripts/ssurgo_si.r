## NRCS SSURGO forest site index extraction at FIA plot locations
##
## Inputs:
##   1. gSSURGO mukey raster at /fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/environmental_data/gssurgo/mukey_raster.tif
##   2. FIA plot lat/lon from multidim_v2 table
##   3. SDA web service (https://sdmdataaccess.sc.egov.usda.gov) for the coforprod query
##
## Workflow:
##   1. Reproject FIA plot lat/lon to the gSSURGO raster CRS, extract mukey per plot
##   2. Pool unique mukeys (likely ~5000-10000 across CONUS)
##   3. Query SDA for the coforprod table per mukey list, retain dominant component
##      and the per-species site index (prefer SiteIndex_dom_sp)
##   4. Join site_index back to FIA plots, save as a new column
##   5. Recompute Table 2-style correlation against ESI, BGI, Asym, NPP, SICOND

suppressPackageStartupMessages({
  library(data.table); library(terra); library(soilDB)
})

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

MUKEY_TIF <- "/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/environmental_data/gssurgo/mukey_raster.tif"

## --- Step 1: pull mukey for each FIA plot
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("plots loaded:", nrow(plt), "\n")

mukey_r <- rast(MUKEY_TIF)
cat("mukey raster CRS:", crs(mukey_r, describe = TRUE)[[1]], "\n")

plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON", "LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(mukey_r))
plt_xy[, mukey := terra::extract(mukey_r, pts, ID = FALSE)[, 1]]
cat("plots with mukey:", sum(!is.na(plt_xy$mukey)), "\n")

uniq_mukeys <- unique(plt_xy$mukey[!is.na(plt_xy$mukey)])
cat("unique mukeys:", length(uniq_mukeys), "\n")

## --- Step 2: query SDA for coforprod records per mukey
## SDA limits 100k char per query; chunk mukeys
chunk_size <- 800
fetch_chunk <- function(mks) {
  q <- paste0(
    "SELECT mu.mukey, cp.cokey, c.compname, c.comppct_r, ",
    "       cp.plantsciname, cp.siteindexbase, cp.siteindex ",
    "FROM mapunit mu ",
    "INNER JOIN component c ON c.mukey = mu.mukey ",
    "INNER JOIN coforprod cp ON cp.cokey = c.cokey ",
    "WHERE mu.mukey IN (", paste(mks, collapse = ","), ") ",
    "  AND cp.siteindex IS NOT NULL")
  tryCatch(setDT(SDA_query(q)),
           error = function(e) { cat("chunk failed:", conditionMessage(e), "\n"); NULL })
}

all_rows <- list()
for (i in seq(1, length(uniq_mukeys), by = chunk_size)) {
  mks <- uniq_mukeys[i:min(i + chunk_size - 1, length(uniq_mukeys))]
  r <- fetch_chunk(mks)
  if (!is.null(r) && nrow(r)) {
    all_rows[[length(all_rows) + 1]] <- r
    cat("chunk", i, "got", nrow(r), "rows\n")
  }
  Sys.sleep(0.5)
}
sda <- rbindlist(all_rows, fill = TRUE)
cat("total SDA rows:", nrow(sda), "\n")
fwrite(sda, file.path(OUT, "E0_sda_raw.csv"))

## --- Step 3: pick dominant component per mukey and mean site index across species
## Many components will have multiple plantsciname rows. Take comppct-weighted mean.
sda[, siteindex := as.numeric(siteindex)]
sda[, siteindexbase := as.numeric(siteindexbase)]
sda[, comppct_r := as.numeric(comppct_r)]
sda <- sda[!is.na(siteindex) & siteindex > 0]

dom_mu <- sda[, .(
  ssurgo_si_ft   = weighted.mean(siteindex, w = comppct_r, na.rm = TRUE),
  ssurgo_si_base = round(weighted.mean(siteindexbase, w = comppct_r, na.rm = TRUE)),
  n_components   = uniqueN(cokey)
), by = mukey]
dom_mu[, ssurgo_si_m := ssurgo_si_ft * 0.3048]
fwrite(dom_mu, file.path(OUT, "E1_ssurgo_si_per_mukey.csv"))
cat("mukeys with SSURGO SI:", nrow(dom_mu), "\n")

## --- Step 4: join back to plots and compute correlations
plt_xy[, mukey := as.integer(mukey)]
dom_mu[, mukey := as.integer(mukey)]
plt_xy <- merge(plt_xy, dom_mu[, .(mukey, ssurgo_si_m, ssurgo_si_base)], by = "mukey", all.x = TRUE)

n_with_si <- sum(!is.na(plt_xy$ssurgo_si_m))
cat("plots with SSURGO SI:", n_with_si, "of", nrow(plt_xy), "\n")

## SICOND base50 from sicond_base50.r is not loaded here; compute SICOND_m only
plt_xy[, SICOND_m := SICOND * 0.3048]

cor_mat <- plt_xy[!is.na(ssurgo_si_m), .(
  measure = c("ESI", "BGI", "Asym", "NPP", "SICOND_raw_m"),
  r_with_SSURGO_SI = round(c(
    cor(ssurgo_si_m, esi    , use = "p"),
    cor(ssurgo_si_m, bgi_v  , use = "p"),
    cor(ssurgo_si_m, asym_v , use = "p"),
    cor(ssurgo_si_m, npp_v  , use = "p"),
    cor(ssurgo_si_m, SICOND_m, use = "p")
  ), 3),
  n = sum(!is.na(ssurgo_si_m) & !is.na(esi))
)]
print(cor_mat)
fwrite(cor_mat, file.path(OUT, "E2_ssurgo_correlations.csv"))

## Save the joined plot table for downstream §3.5.2 use
fwrite(plt_xy[, .(key, LAT, LON, mukey, ssurgo_si_m, ssurgo_si_base,
                  SICOND_m, esi, bgi_v, asym_v, npp_v, SITECLCD, STDAGE)],
       file.path(OUT, "E3_plt_with_ssurgo.csv"))

cat("\n=== SSURGO SI extraction done. Outputs in", OUT, "===\n")
