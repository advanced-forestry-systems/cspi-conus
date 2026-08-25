# =============================================================================
# mosaic_na_30m.R                                          STAGE 4 of 4
# -----------------------------------------------------------------------------
# Assemble the STAGE 3 per-tile predictions into continental products:
#
#   1. Canada 30 m RD     : VRT over rd30/tiles/*.tif  (+ overview pyramid)
#   2. Canada 30 m CSPI30 : VRT over cspi30/tiles/*.tif (+ overview pyramid)
#   3. Seamless NA 30 m RD: mosaic of the Canada RD VRT (warped to the CONUS
#        grid) with the existing CONUS 30 m RD raster, as a VRT with per-source
#        warping (+ overview pyramid). CONUS and Canada RD are on the SAME RD
#        definition (RD = SDI / SDImax), so no rescaling is applied at the seam.
#   4. NA 30 m CSPI30      : a CONUS 30 m CSPI product DOES exist, and this stage now
#        takes the CONUS branch it previously skipped. See the DEFECT 1 note below.
#
# -----------------------------------------------------------------------------------
# DEFECT 1 CORRECTION, 28 July 2026.
# -----------------------------------------------------------------------------------
# This file previously asserted, in the header and again in the provenance record, that
# "CONUS has no 30 m CSPI product". That is false and has been false since 8 July 2026.
# Verified on Cardinal 28 July 2026 with gdalinfo:
#
#   /fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m.tif
#     41,755,385,529 bytes (41.8 GB), 212,400 x 90,000 cells, EPSG:4326,
#     pixel 0.000277778 deg, extent -125 to -66 lon and 24 to 49 lat,
#     single band, description CSPI_v2_5component, value range 24.864 to 100.000
#   ..._30m_forest.tif  14.5 GB, the forest-masked variant
#   ..._1km.tif         42 MB, the 1 km aggregate, range 25.583 to 100.000
#
# The five components are ESI v7, BGI, Asym, MIAMI NPP and MOD17A3HGF NPP. Confirmation is
# on disk in the same directory: mia_g.tif carries band description npp_miami_gDM_m2_yr and
# mod_g.tif carries mod17a3hgf_npp_mean_2017_2023, both rendered on the 212,400 x 90,000
# ESI grid, alongside the three aligned component grids Asym_on_esi_grid.tif,
# BGI_on_esi_grid.tif and NPP_MIAMI_on_esi_grid.tif in cspi_v7/cspi_v2_aligned/. The full
# definition, transformation and rules are recorded in
# CONUS_CSPI_v2_5component_definition_2026-07-28.md alongside this script.
#
# ANNOTATION, 25 August 2026, per cspi-component-count-reconciliation_FINAL_2026-08-19.md.
# CSPI_v2_5component_30m.tif, the file this header and the CONUS_CSPI30 binding below both
# name, is an experimental v2both-line surface, NOT the CSPI v2 of record. CSPI v2 of record
# is the three-component composite z(ESI) + z(BGI) + z(Asym) per the manuscript, the composite
# specification section 3.2, and build job 11555064 (CSPI_v21_3component_30m.tif). This script
# keeps the five-component file as its CONUS input pending a decision to repoint or retire it;
# separately, the 12 August raster ceiling decision and blocker B4 declare every product off
# the NA20 grid stale, including this one, so this script may be moot regardless. See the
# reconciliation memo for the full evidence chain and the file-by-file edit list.
#
# WHAT THE SCRIPT DID DIFFERENTLY, which is the part that matters. This was not only a
# stale comment. Section 3 below skipped an entire branch: instead of building a two
# source mosaic the way section 2 does for RD, it performed a file.copy() of the Canada
# CSPI30 VRT onto the NA CSPI30 name, wrote na_cspi30_status = "CANADA-ONLY" into the
# provenance, and listed only Canada products in the summary CSV. Downstream consumers of
# NA_CSPI30_30m.vrt were therefore reading a Canada-only surface under a North American
# name, with a provenance record giving a reason that was not the real one. The branch now
# exists and is taken: the CONUS product is registered as a first-class input, verified on
# disk, warped into the Canada CSPI30 CRS as a VRT, and offered to the mosaic.
#
# WHAT STILL BLOCKS A SINGLE CANONICAL NA CSPI30, which is a different and honest reason.
# The two sides are not on one definition. CONUS CSPI_v2_5component is an equal-weight mean
# of five z-standardised productivity components, requiring at least three of five, clamped
# at plus or minus 3 and rescaled to 0 to 100. The Canada CSPI30 in this pipeline is an
# equal-weight mean of within-sample z-scores of basal area per hectare, top height and
# relative density, which are stand state and stocking variables rather than productivity
# components, and which the 28 July rescope memo rejects as a CSPI definition. Mosaicking
# them would produce a seamless raster that means one thing south of the border and a
# different thing north of it, which is the same silent redefinition the 2 km membership
# work exists to prevent. So the canonical name is gated on harmonisation, not on
# existence, and the gate is the CSPI30_HARMONIZED switch below. Both surfaces are emitted
# either way, plus an explicitly named unharmonised container for the reconciliation the
# rescope memo requires.
#
# CRS CHOICE (documented): the common grid is EPSG:5070 (NAD83 CONUS Albers), the
# CONUS RD native CRS. We warp the Canada VRT INTO 5070 rather than reprojecting
# the very large CONUS 30 m raster, which is cheaper and leaves the authoritative
# CONUS product untouched. The Canada AEF tiles / predictions are EPSG:4326, so
# the Canada->5070 step is a genuine reprojection (bilinear, RD/CSPI30 continuous).
# TODO(Aaron): if a downstream consumer needs EPSG:4326, warp CONUS to 4326
# instead (flip WARP_TARGET below); the VRT machinery is symmetric.
#
# -----------------------------------------------------------------------------------
# SUPERSEDED 28 July 2026 (CRS CHOICE).
# -----------------------------------------------------------------------------------
# The reasoning above stands as written and its cost argument is still correct, warping
# the smaller side is cheaper than warping a 41.8 GB raster, but the conclusion does not.
# EPSG:5070 was overturned by NA20_GRID_SPEC_v1.0. Extending 5070 northward degrades
# faster than linearly beyond its upper standard parallel of 45.5 N: maximum angular
# deformation is 1.42 degrees at 49 N, 11.72 degrees at 60 N and 35.09 degrees at 70 N,
# and at 70 N a pixel the header calls 30 m measures far less east to west than north to
# south. This is a Canada-inclusive product. Roughly two thirds of the North American
# forest estate lies north of 49 N, so assembling it on the CONUS-only projection put the
# majority of the surface in the part of the projection where that projection fails. That
# is the opposite of the trade the cost argument was optimising.
#
# ESRI:102008, which the sibling hex scripts used, is also superseded: it reaches 6.44
# degrees of maximum angular deformation at 49 N, exactly the latitude of the seam this
# script exists to make continuous. The adopted CRS differs from ESRI:102008 in exactly
# one parameter pair, the standard parallels, now 40 and 65, and holds 49 N to 2.30
# degrees. It is read from grid_spec_20m/na20_canonical_grid.json and is not restated
# anywhere in this file.
#
# CONSEQUENCE FOR THE WARP. Under EPSG:5070 the CONUS RD raster was native and needed no
# warping, which is what made the one-sided warp possible. Under the adopted grid NEITHER
# side is native: CONUS RD is 5070 and the Canada tiles are 4326, so both are now warped
# into the common CRS as VRTs. Section 2 below does this. The cost is real but bounded,
# because per-source warping in a VRT materialises no pixels until something reads them.
# The WARP_TARGET switch keeps its historical value strings so nothing downstream that
# reads the provenance JSON breaks; read "canada_to_5070" as "assemble in the canonical
# NA CRS", which is what it now does.
#
# STALE PRODUCT WARNING, 28 July 2026: NA_RD_30m.vrt, Canada_RD_30m_5070.vrt and their
# .ovr overview pyramids, together with na_30m_summary.csv and the provenance JSON that
# record them as EPSG:5070, were all assembled on the superseded grid. They are stale with
# respect to the adopted grid and must be rebuilt. The per-tile Stage 3 GeoTIFFs the VRTs
# reference are NOT stale, since they are the unprojected 4326 predictions, so the rebuild
# is a re-warp and a re-mosaic rather than a re-prediction. No rebuild is attempted here.
#
# WHY VRT + OVERVIEWS, NOT A MATERIALIZED GEOTIFF: a full-Canada / full-NA 30 m
# GeoTIFF is enormous (hundreds of GB). The primary products are therefore
# lightweight GDAL VRTs that reference the per-tile GeoTIFFs in place, plus an
# external overview pyramid (.ovr) for fast preview and for -approx_stats. A fully
# materialized Cloud-Optimized GeoTIFF is available but OPT-IN (MATERIALIZE_COG),
# off by default because of its size and build time.
#
# RUNS SERVER-SIDE ON OSC CARDINAL ONLY (submitted via mosaic_na_30m.slurm).
# Nothing here is executed locally.
#
# COMPLIANCE: gridded rasters only (allowed downstream). The one tabular output
# (a value-range / tile-count summary) is coordinate-free and passes safe_write.
#
# House rules: no em dashes; RD/CSPI30 unitless; heavy comments; headless; every
# GDAL call and write guarded so a failure lands in error_log.txt.
# =============================================================================

suppressPackageStartupMessages({
  library(terra)
  library(data.table)
  library(jsonlite)
})

## ---- canonical CRS, read not retyped ---------------------------------------
## The target CRS is declared in exactly one place, grid_spec_20m/
## na20_canonical_grid.json. Nothing here restates it. See NA20_GRID_SPEC_v1.md
## sections 4.1 to 4.4 for the defence of the adopted parameters. The SLURM
## wrapper exports NA20_SPEC so the run does not depend on the working directory.
NA20_SPEC_PATH <- Sys.getenv("NA20_SPEC", "")
if (!nzchar(NA20_SPEC_PATH)) {
  .na20_cand <- c("grid_spec_20m/na20_canonical_grid.json",
                  "/users/PUOM0008/crsfaaron/na_maps/grid_spec_20m/na20_canonical_grid.json")
  .na20_hit  <- which(file.exists(.na20_cand))
  NA20_SPEC_PATH <- if (length(.na20_hit)) .na20_cand[.na20_hit[1]] else .na20_cand[1]
}
na20_canonical_crs <- function(path = NA20_SPEC_PATH) {
  if (file.exists(path) && requireNamespace("jsonlite", quietly = TRUE)) {
    s <- jsonlite::fromJSON(path, simplifyVector = TRUE)
    return(s$crs$proj4)
  }
  ## Documented fallback: the generated PROJ.4 one-liner beside the spec.
  p <- file.path(dirname(path), "na20.proj")
  if (file.exists(p)) return(trimws(readLines(p, warn = FALSE)[1]))
  ## Deliberate stop. A silent fallback to a hardcoded CRS is the failure being closed.
  stop("Canonical NA20 grid spec not found at ", path,
       ". Refusing to guess a target CRS. Stage grid_spec_20m/ alongside ",
       "this script or set NA20_SPEC.")
}

# =============================================================================
# PATHS / PARAMETERS
# =============================================================================
RD_TILE_DIR   <- "/fs/scratch/PUOM0008/crsfaaron/na_maps/rd30/tiles"
CSPI_TILE_DIR <- "/fs/scratch/PUOM0008/crsfaaron/na_maps/cspi30/tiles"

RD_OUT_DIR   <- "/fs/scratch/PUOM0008/crsfaaron/na_maps/rd30"
CSPI_OUT_DIR <- "/fs/scratch/PUOM0008/crsfaaron/na_maps/cspi30"
dir.create(RD_OUT_DIR,   recursive = TRUE, showWarnings = FALSE)
dir.create(CSPI_OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Existing CONUS 30 m RD (EPSG:5070) and its uncertainty layer.
CONUS_RD     <- "/fs/scratch/PUOM0008/crsfaaron/Disturbance_run/alphaearth/conus/conus_RD_30m_SAEcal_2022.tif"
CONUS_RD_UNC <- "/fs/scratch/PUOM0008/crsfaaron/Disturbance_run/alphaearth/conus/conus_RD_30m_SAEcal_uncertainty_2022.tif"

# Existing CONUS 30 m CSPI (DEFECT 1). Registered as a first-class input, not assumed
# absent. EPSG:4326 at 0.000277778 deg over -125 to -66 lon and 24 to 49 lat, 41.8 GB.
CONUS_CSPI30        <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m.tif"
CONUS_CSPI30_FOREST <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m_forest.tif"
CONUS_CSPI30_1KM    <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_1km.tif"

# The CONUS definition, recorded here so the mismatch below is auditable from the script
# rather than only from the companion note.
CONUS_CSPI30_DEF <- paste(
  "CSPI v2 five-component, CONUS: equal-weight mean of the z-standardised components",
  "ESI v7 (dominant-height site index, m), BGI (net aboveground biomass increment,",
  "Mg ha-1 yr-1), Asym (asymptotic aboveground biomass, Mg ha-1, Chapman-Richards BLUP",
  "with top height as the developmental axis and relative density in the asymptote,",
  "evaluated at RD 0.60), MIAMI NPP (npp_miami_gDM_m2_yr) and MOD17A3HGF NPP mean",
  "2017-2023; at least 3 of 5 components required per cell, mean z clamped to +/-3,",
  "rescaled to 0-100. Landed range 24.864 to 100.000.")
CANADA_CSPI30_DEF <- paste(
  "CSPI30 (Canada, this pipeline): equal-weight mean of within-sample z-scores of",
  "BA_ha (m2 ha-1), topht (m) and RD (unitless). Stand state and stocking, NOT",
  "productivity components. Rejected as a CSPI definition by the 28 July 2026 rescope",
  "memo; retained here only as the surface the Stage 3 tiles currently carry.")

# CSPI30_HARMONIZED: flip to TRUE only when the two national surfaces are genuinely on ONE
# definition, i.e. when the Canada side has been rebuilt to the CONUS component set (or
# both to a new fixed set) and standardised against one locked reference population. Until
# then the canonical NA_CSPI30 name stays with the Canada surface, the CONUS surface is
# emitted under its own name, and the two-source container is emitted under a name that
# says out loud that it is unharmonised.
CSPI30_HARMONIZED <- as.logical(Sys.getenv("CSPI30_HARMONIZED", "FALSE"))
if (is.na(CSPI30_HARMONIZED)) CSPI30_HARMONIZED <- FALSE

# CRS the CSPI30 mosaic is assembled in. The Canada CSPI30 tiles and the CONUS CSPI30 are
# both EPSG:4326 geographic, so this is a no-op reprojection today and the warp exists to
# reconcile the two pixel sizes (0.000269494585 deg for the AEF-derived Canada tiles
# against 0.000277778 deg for the CONUS grid). Note that neither is an equal-area 30 m
# grid; the rescope memo requires the eventual NA product to be declared on an equal-area
# projection, at which point CSPI_CRS should be set to it.
#
# STATUS 28 July 2026. The equal-area projection that comment anticipates now exists and is
# the canonical NA20 CRS available here as na20_canonical_crs(). CSPI_CRS is deliberately
# NOT flipped to it in this edit, for a reason that is about semantics rather than
# geometry: the canonical NA CSPI30 name is still gated on CSPI30_HARMONIZED, which is
# FALSE, so there is as yet no single NA CSPI30 product to declare on any grid. Warping the
# 41.8 GB CONUS raster and the Canada tiles into an equal-area frame before the two sides
# are on one definition would spend the reprojection on a surface that still means
# different things north and south of the border. The flip is owed at the moment
# CSPI30_HARMONIZED goes TRUE, and at that moment the correct value is
# na20_canonical_crs(), read from the canonical file, not a literal typed here.
CSPI_CRS <- "EPSG:4326"
CSPI_RES <- 0.000277778   # deg, the CONUS CSPI grid step; Canada is warped onto it

ERR_LOG <- file.path(RD_OUT_DIR, "mosaic_error_log.txt")

# Common CRS for the seamless NA_RD mosaic. BOTH sides are warped into this; see the
# SUPERSEDED (CRS CHOICE) block in the header for why the one-sided warp no longer works.
# Was the literal "EPSG:5070" until 28 July 2026.
NA_CRS       <- na20_canonical_crs()
# Historical value strings retained so the provenance JSON stays comparable across runs.
# Read "canada_to_5070" as "assemble in the canonical NA CRS".
WARP_TARGET  <- "canada_to_5070"   # or "conus_to_4326" (flip to reproject CONUS)
WARP_RES     <- 30                  # metres, 30 m target grid in the canonical NA CRS

# Materialize a full COG in addition to the VRT + overviews? OFF by default
# (a full 30 m NA / Canada COG is very large and slow). Flip to TRUE only when
# a standalone GeoTIFF is genuinely needed and disk/time allow.
MATERIALIZE_COG <- FALSE

say <- function(...) cat(sprintf("[mosaic_na_30m] %s\n", sprintf(...)))
log_err <- function(context, msg)
  cat(sprintf("[%s] %s :: %s\n", format(Sys.time()), context, msg),
      file = ERR_LOG, append = TRUE)

# Run a GDAL command-line tool (gdal module is loaded by the SLURM script).
# Returns TRUE on success; logs stderr on failure and returns FALSE (non-fatal).
run_gdal <- function(cmd, args, context) {
  say("%s: %s %s", context, cmd, paste(args, collapse = " "))
  res <- suppressWarnings(tryCatch(
    system2(cmd, args = args, stdout = TRUE, stderr = TRUE),
    error = function(e) { log_err(context, conditionMessage(e)); NULL }))
  status <- attr(res, "status")
  if (!is.null(status) && status != 0) {
    log_err(context, paste(res, collapse = " | ")); say("  FAILED (%s)", context)
    return(FALSE)
  }
  TRUE
}

# safe_write() -- coordinate-name gate (backstop; summary is coordinate-free).
safe_write <- function(dt, path) {
  dt <- as.data.table(dt); nm <- tolower(names(dt))
  bad <- nm %in% c("lat","latitude","lon","long","longitude","x","y","easting",
                   "northing","coord","coords","coordinate","coordinates",
                   "geometry","elev","elevation") |
         grepl("(^|_)(lat|latitude|lon|longitude|easting|northing)(_|$)", nm)
  if (any(bad)) stop("REFUSED coordinate-named column(s): ",
                     paste(names(dt)[bad], collapse = ", "))
  tryCatch({ fwrite(dt, path); say("[safe_write] %d rows -> %s", nrow(dt), path) },
           error = function(e) log_err(paste0("safe_write ", path), e))
  invisible(path)
}

# Write a newline-delimited file listing all tiles, for gdalbuildvrt -input_file_list.
tile_list_file <- function(dir, out_txt) {
  tiles <- sort(list.files(dir, pattern = "\\.tif$", full.names = TRUE))
  writeLines(tiles, out_txt)
  length(tiles)
}

# Approximate min/max/mean from an overview-backed VRT via gdalinfo -approx_stats.
approx_stats <- function(vrt_path) {
  out <- suppressWarnings(tryCatch(
    system2("gdalinfo", c("-stats", "-approx_stats", "-json", shQuote(vrt_path)),
            stdout = TRUE, stderr = TRUE), error = function(e) NULL))
  if (is.null(out)) return(list(min = NA, max = NA, mean = NA))
  j <- tryCatch(fromJSON(paste(out, collapse = "\n")), error = function(e) NULL)
  st <- tryCatch(j$bands$metadata[[1]], error = function(e) NULL)
  # Robust fallback: parse the flat metadata list if the structure differs.
  getn <- function(key) {
    v <- suppressWarnings(as.numeric(unlist(st)[grepl(key, names(unlist(st)))][1]))
    if (length(v)) v else NA_real_
  }
  list(min = getn("MINIMUM"), max = getn("MAXIMUM"), mean = getn("MEAN"))
}

# =============================================================================
# 1. CANADA VRTs (RD, CSPI30) + overview pyramids
# =============================================================================
say("[1] building Canada RD and CSPI30 VRTs over the per-tile predictions")

rd_list  <- file.path(RD_OUT_DIR,   "_canada_rd30_tiles.txt")
cspi_list <- file.path(CSPI_OUT_DIR, "_canada_cspi30_tiles.txt")
n_rd_tiles   <- tile_list_file(RD_TILE_DIR,   rd_list)
n_cspi_tiles <- tile_list_file(CSPI_TILE_DIR, cspi_list)
say("    RD tiles: %d ; CSPI30 tiles: %d", n_rd_tiles, n_cspi_tiles)
if (n_rd_tiles == 0L) stop("No RD tiles under ", RD_TILE_DIR, " (run STAGE 3 first).")

CAN_RD_VRT   <- file.path(RD_OUT_DIR,   "Canada_RD_30m.vrt")
CAN_CSPI_VRT <- file.path(CSPI_OUT_DIR, "Canada_CSPI30_30m.vrt")

run_gdal("gdalbuildvrt",
         c("-input_file_list", shQuote(rd_list), shQuote(CAN_RD_VRT)),
         "Canada RD VRT")
if (n_cspi_tiles > 0L)
  run_gdal("gdalbuildvrt",
           c("-input_file_list", shQuote(cspi_list), shQuote(CAN_CSPI_VRT)),
           "Canada CSPI30 VRT")

# External overview pyramids (.ovr) for fast preview + approx stats. -ro keeps
# them read-only external to the VRT. AVERAGE resampling suits continuous fields.
run_gdal("gdaladdo",
         c("-ro", "-r", "average", shQuote(CAN_RD_VRT), "2", "4", "8", "16", "32"),
         "Canada RD overviews")
if (n_cspi_tiles > 0L)
  run_gdal("gdaladdo",
           c("-ro", "-r", "average", shQuote(CAN_CSPI_VRT), "2", "4", "8", "16", "32"),
           "Canada CSPI30 overviews")

# =============================================================================
# 2. SEAMLESS NA 30 m RD: warp BOTH sides into the canonical NA CRS, then mosaic
# =============================================================================
# CHANGED 28 July 2026. This section formerly warped only Canada, because the common CRS
# was EPSG:5070 and the CONUS RD raster was already native to it. The common CRS is now
# the canonical NA20 CRS, in which neither side is native, so CONUS is warped too. Leaving
# the old one-sided code in place would have handed gdalbuildvrt one source in the
# canonical CRS and one in EPSG:5070, which is a mixed-projection mosaic and is exactly
# the class of silent geometry error this whole reconciliation exists to close.
say("[2] building seamless NA 30 m RD (common CRS %s)", NA_CRS)
if (!file.exists(CONUS_RD)) {
  log_err("CONUS RD", paste("absent:", CONUS_RD))
  say("    CONUS RD absent; NA_RD will be Canada-only. TODO: stage %s", CONUS_RD)
}

# Variable names below are historical and deliberately unchanged so nothing downstream
# breaks; the "5070" in CAN_RD_5070_VRT now means "on the common NA CRS", and the file it
# points at was renamed so that no artifact on disk carries a projection name it does not
# have. The old Canada_RD_30m_5070.vrt is a stale product of the superseded grid.
CAN_RD_5070_VRT  <- file.path(RD_OUT_DIR, "Canada_RD_30m_NA20.vrt")
CONUS_RD_NA_VRT  <- file.path(RD_OUT_DIR, "conus_RD_30m_NA20.vrt")
NA_RD_VRT        <- file.path(RD_OUT_DIR, "NA_RD_30m.vrt")

if (identical(WARP_TARGET, "canada_to_5070")) {
  # Warp the Canada RD VRT to the common NA CRS at 30 m as a VRT (per-source warping;
  # no pixels materialized). bilinear resampling for a continuous RD field.
  run_gdal("gdalwarp",
           c("-of", "VRT", "-t_srs", NA_CRS, "-tr", WARP_RES, WARP_RES,
             "-r", "bilinear", "-overwrite",
             shQuote(CAN_RD_VRT), shQuote(CAN_RD_5070_VRT)),
           "warp Canada RD -> canonical NA CRS")
  # Warp CONUS the same way. Under the superseded EPSG:5070 common grid this step did not
  # exist, since CONUS was native. It is still cheap in VRT form: no pixels move until a
  # reader asks for them, and the overview build below is what pays the cost.
  na_conus_src <- CONUS_RD
  if (file.exists(CONUS_RD)) {
    ok_conus <- run_gdal("gdalwarp",
             c("-of", "VRT", "-t_srs", NA_CRS, "-tr", WARP_RES, WARP_RES,
               "-r", "bilinear", "-overwrite",
               shQuote(CONUS_RD), shQuote(CONUS_RD_NA_VRT)),
             "warp CONUS RD -> canonical NA CRS")
    if (isTRUE(ok_conus) && file.exists(CONUS_RD_NA_VRT)) na_conus_src <- CONUS_RD_NA_VRT
    else log_err("CONUS RD warp",
                 "warp to the canonical NA CRS failed; refusing to mosaic mixed CRS")
  }
  # Mosaic CONUS-in-NA20 + Canada-in-NA20 into one VRT. Sources listed CONUS first,
  # Canada second; they meet only in a thin border band.
  na_inputs <- c(shQuote(na_conus_src), shQuote(CAN_RD_5070_VRT))
  # Canada-only if CONUS is absent, or if its warp failed: a mixed-CRS mosaic is worse
  # than an honestly incomplete one.
  if (!file.exists(CONUS_RD) || identical(na_conus_src, CONUS_RD))
    na_inputs <- shQuote(CAN_RD_5070_VRT)
  run_gdal("gdalbuildvrt", c(shQuote(NA_RD_VRT), na_inputs), "NA RD mosaic VRT")
} else {
  # Alternative: reproject CONUS to EPSG:4326 and mosaic in the Canada CRS.
  # RETAINED, NOT ENDORSED, 28 July 2026. This branch assembles the NA RD product in a
  # geographic CRS, which is not equal-area and is not the canonical NA grid, so anything
  # it writes is outside the adopted specification and must be labelled as such. It stays
  # available only as the escape hatch it was written to be, for a downstream consumer
  # that genuinely requires lon/lat. It is not reachable with WARP_TARGET at its default.
  CONUS_RD_4326 <- file.path(RD_OUT_DIR, "conus_RD_30m_4326.vrt")
  run_gdal("gdalwarp",
           c("-of", "VRT", "-t_srs", "EPSG:4326", "-r", "bilinear", "-overwrite",
             shQuote(CONUS_RD), shQuote(CONUS_RD_4326)),
           "warp CONUS RD -> 4326")
  run_gdal("gdalbuildvrt",
           c(shQuote(NA_RD_VRT), shQuote(CONUS_RD_4326), shQuote(CAN_RD_VRT)),
           "NA RD mosaic VRT (4326)")
}

run_gdal("gdaladdo",
         c("-ro", "-r", "average", shQuote(NA_RD_VRT), "2", "4", "8", "16", "32", "64"),
         "NA RD overviews")

# =============================================================================
# 3. NA CSPI30: the CONUS branch, which this script used to skip (DEFECT 1)
# =============================================================================
# Previously this section asserted that CONUS had no 30 m CSPI product and copied the
# Canada VRT onto the NA name. The CONUS product exists (see the header). The branch is
# now taken: verify the CONUS product, warp it into the common CSPI CRS as a VRT, and
# build a genuine two-source mosaic. Which product carries the canonical NA_CSPI30 name is
# decided by CSPI30_HARMONIZED, because the blocker is a definition mismatch, not absence.
NA_CSPI_VRT        <- file.path(CSPI_OUT_DIR, "NA_CSPI30_30m.vrt")
NA_CSPI_CAN_VRT    <- file.path(CSPI_OUT_DIR, "NA_CSPI30_30m_canada_only.vrt")
CONUS_CSPI_VRT     <- file.path(CSPI_OUT_DIR, "CONUS_CSPI30_30m_on_cspi_crs.vrt")
NA_CSPI_UNHARM_VRT <- file.path(CSPI_OUT_DIR, "NA_CSPI30_30m_UNHARMONIZED_container.vrt")

conus_cspi_ok <- file.exists(CONUS_CSPI30)
if (!conus_cspi_ok) {
  # Kept as a genuine fallback, but note that this branch is now the exceptional one.
  log_err("CONUS CSPI30", paste("absent:", CONUS_CSPI30))
  say("[3] CONUS 30 m CSPI NOT FOUND at %s", CONUS_CSPI30)
  say("    (as of 8 July 2026 this file DOES exist at 41.8 GB; if it is missing now, ")
  say("     something has been moved or deleted, investigate before proceeding)")
} else {
  say("[3] CONUS 30 m CSPI present (%.1f GB): %s",
      file.info(CONUS_CSPI30)$size / 2^30, CONUS_CSPI30)
  say("    CONUS definition : %s", CONUS_CSPI30_DEF)
  say("    Canada definition: %s", CANADA_CSPI30_DEF)
}

if (n_cspi_tiles > 0L) {
  # (a) The Canada surface always gets its own explicit name, so it is never only
  #     reachable through a North American alias.
  ok_can <- tryCatch({ file.copy(CAN_CSPI_VRT, NA_CSPI_CAN_VRT, overwrite = TRUE); TRUE },
                     error = function(e) { log_err("Canada CSPI30 alias", conditionMessage(e)); FALSE })
  if (ok_can) say("    wrote %s (Canada CSPI30, explicit name)", basename(NA_CSPI_CAN_VRT))
}

if (conus_cspi_ok) {
  # (b) Warp the CONUS product into the common CSPI CRS and grid step as a VRT. No pixels
  #     are materialised. This is the step section 2 already performs for RD and which
  #     section 3 never performed because it believed the source did not exist.
  run_gdal("gdalwarp",
           c("-of", "VRT", "-t_srs", CSPI_CRS, "-tr", CSPI_RES, CSPI_RES,
             "-r", "bilinear", "-overwrite",
             shQuote(CONUS_CSPI30), shQuote(CONUS_CSPI_VRT)),
           "warp CONUS CSPI30 -> CSPI CRS")
  run_gdal("gdaladdo",
           c("-ro", "-r", "average", shQuote(CONUS_CSPI_VRT), "2", "4", "8", "16", "32", "64"),
           "CONUS CSPI30 overviews")
}

if (conus_cspi_ok && n_cspi_tiles > 0L) {
  # (c) The two-source container. Sources listed CONUS first, Canada second. This is a
  #     genuine mosaic in the geometric sense and NOT a harmonised index, which is why it
  #     is named UNHARMONIZED. It exists so the reconciliation the rescope memo requires
  #     (report the correlation between any new fixed-component index and the existing
  #     CONUS five-component surface over their shared footprint) can be computed without
  #     anyone having to reconstruct the warp by hand.
  run_gdal("gdalbuildvrt",
           c(shQuote(NA_CSPI_UNHARM_VRT), shQuote(CONUS_CSPI_VRT), shQuote(CAN_CSPI_VRT)),
           "NA CSPI30 unharmonized container VRT")
  say("    wrote %s (two-source container; MIXED DEFINITIONS, do not read as one index)",
      basename(NA_CSPI_UNHARM_VRT))
}

# (d) Decide what carries the canonical NA_CSPI30 name.
na_cspi30_basis <- NA_character_
if (isTRUE(CSPI30_HARMONIZED) && conus_cspi_ok && n_cspi_tiles > 0L) {
  run_gdal("gdalbuildvrt",
           c(shQuote(NA_CSPI_VRT), shQuote(CONUS_CSPI_VRT), shQuote(CAN_CSPI_VRT)),
           "NA CSPI30 mosaic VRT (harmonized)")
  run_gdal("gdaladdo",
           c("-ro", "-r", "average", shQuote(NA_CSPI_VRT), "2", "4", "8", "16", "32", "64"),
           "NA CSPI30 overviews")
  na_cspi30_basis <- "true CONUS + Canada mosaic (CSPI30_HARMONIZED=TRUE)"
  say("    NA_CSPI30_30m.vrt = CONUS + Canada mosaic (harmonized)")
} else if (n_cspi_tiles > 0L) {
  ok <- tryCatch({ file.copy(CAN_CSPI_VRT, NA_CSPI_VRT, overwrite = TRUE); TRUE },
                 error = function(e) { log_err("NA CSPI30 copy", conditionMessage(e)); FALSE })
  na_cspi30_basis <- paste(
    "Canada CSPI30 only. NOT because CONUS lacks a 30 m CSPI (it has one, 41.8 GB, since",
    "8 July 2026) but because the two sides are on DIFFERENT DEFINITIONS: CONUS is a",
    "five-component productivity index rescaled 0-100, Canada is a z-composite of basal",
    "area, top height and relative density. The CONUS surface is emitted separately and",
    "the two-source container is emitted for reconciliation. Set CSPI30_HARMONIZED=TRUE",
    "only after both sides are rebuilt to one component set and one reference population.")
  if (ok) say("    NA_CSPI30_30m.vrt = Canada CSPI30 VRT (definition mismatch, see provenance)")
} else {
  na_cspi30_basis <- "no Canada CSPI30 tiles present; NA_CSPI30 not written"
}

# =============================================================================
# 4. OPTIONAL: materialize COGs (OFF by default; large + slow)
# =============================================================================
if (isTRUE(MATERIALIZE_COG)) {
  say("[4] materializing COGs (MATERIALIZE_COG=TRUE); this is large and slow")
  run_gdal("gdal_translate",
           c("-of", "COG", "-co", "COMPRESS=DEFLATE", "-co", "PREDICTOR=2",
             "-co", "BIGTIFF=YES", "-co", "RESAMPLING=AVERAGE",
             shQuote(NA_RD_VRT), shQuote(file.path(RD_OUT_DIR, "NA_RD_30m_cog.tif"))),
           "NA RD COG")
  if (n_cspi_tiles > 0L)
    run_gdal("gdal_translate",
             c("-of", "COG", "-co", "COMPRESS=DEFLATE", "-co", "PREDICTOR=2",
               "-co", "BIGTIFF=YES", "-co", "RESAMPLING=AVERAGE",
               shQuote(CAN_CSPI_VRT), shQuote(file.path(CSPI_OUT_DIR, "Canada_CSPI30_30m_cog.tif"))),
             "Canada CSPI30 COG")
} else {
  say("[4] MATERIALIZE_COG=FALSE; keeping VRT + overviews only (set TRUE to build COGs)")
}

# =============================================================================
# 5. PROVENANCE JSON + COORDINATE-FREE SUMMARY CSV
# =============================================================================
say("[5] writing provenance JSON and value-range / tile-count summary")

rd_stats     <- approx_stats(CAN_RD_VRT)
na_rd_stats  <- approx_stats(NA_RD_VRT)
cspi_stats   <- if (n_cspi_tiles > 0L) approx_stats(CAN_CSPI_VRT) else
                list(min = NA, max = NA, mean = NA)

conus_cspi_stats <- if (isTRUE(conus_cspi_ok)) approx_stats(CONUS_CSPI_VRT) else
                    list(min = NA, max = NA, mean = NA)

summary_dt <- data.table(
  product   = c("Canada_RD_30m", "NA_RD_30m", "Canada_CSPI30_30m", "CONUS_CSPI30_30m"),
  crs       = c("EPSG:4326", NA_CRS, "EPSG:4326", CSPI_CRS),
  n_tiles   = c(n_rd_tiles, n_rd_tiles, n_cspi_tiles, NA_integer_),
  approx_min  = c(rd_stats$min,  na_rd_stats$min,  cspi_stats$min,  conus_cspi_stats$min),
  approx_max  = c(rd_stats$max,  na_rd_stats$max,  cspi_stats$max,  conus_cspi_stats$max),
  approx_mean = c(rd_stats$mean, na_rd_stats$mean, cspi_stats$mean, conus_cspi_stats$mean),
  note = c("Canada 30 m RD from RS->RD RF over AEF tiles (RD clamped [0,1])",
           paste("Seamless NA 30 m RD: CONUS SAE-cal + Canada, BOTH warped into the",
                 "canonical NA CRS read from grid_spec_20m/na20_canonical_grid.json;",
                 "same RD definition on both sides, no rescaling at the seam.",
                 "Was assembled in EPSG:5070 before 28 July 2026; any product carrying",
                 "that CRS is stale and must be rebuilt."),
           "Canada 30 m CSPI30 from RS->CSPI30 RF (z-composite of BA_ha, topht, RD); stand state, not productivity",
           paste("CONUS 30 m CSPI, CSPI_v2_5component_30m.tif, warped to the CSPI CRS.",
                 "EXISTS since 8 July 2026 (41.8 GB); the earlier claim that it did not",
                 "was wrong. Five components: ESI v7, BGI, Asym, MIAMI NPP, MOD17 NPP;",
                 ">=3 of 5 required, clamp +/-3, rescaled 0-100."))
)
safe_write(summary_dt, file.path(RD_OUT_DIR, "na_30m_summary.csv"))
print(summary_dt)

prov <- list(
  product        = "North American 30 m RD + Canada 30 m CSPI30",
  generated_utc  = format(Sys.time(), tz = "UTC", usetz = TRUE),
  generator      = "mosaic_na_30m.R (STAGE 4)",
  common_crs_na_rd = NA_CRS,
  # ADDED 28 July 2026. The CRS above is no longer typed into this script; it is read from
  # the canonical spec, and the path it was read from is recorded here so any consumer can
  # verify which declaration this run actually used.
  common_crs_na_rd_source = NA20_SPEC_PATH,
  common_crs_na_rd_superseded_note = paste(
    "This field read EPSG:5070 before 28 July 2026. EPSG:5070 and ESRI:102008 are both",
    "superseded by NA20_GRID_SPEC_v1.0; see the superseded_declarations block of",
    "na20_canonical_grid.json. Products built before that date are stale and must be",
    "rebuilt; the Stage 3 per-tile predictions they reference are not."),
  warp_target    = WARP_TARGET,
  target_res_m   = WARP_RES,
  materialize_cog = MATERIALIZE_COG,
  products = list(
    canada_rd_30m     = basename(CAN_RD_VRT),
    canada_cspi30_30m = if (n_cspi_tiles > 0L) basename(CAN_CSPI_VRT) else NA,
    na_rd_30m         = basename(NA_RD_VRT),
    na_cspi30_30m     = if (n_cspi_tiles > 0L) basename(NA_CSPI_VRT) else NA,
    na_cspi30_30m_canada_only = if (n_cspi_tiles > 0L) basename(NA_CSPI_CAN_VRT) else NA,
    conus_cspi30_30m  = if (isTRUE(conus_cspi_ok)) basename(CONUS_CSPI_VRT) else NA,
    na_cspi30_30m_unharmonized_container =
      if (isTRUE(conus_cspi_ok) && n_cspi_tiles > 0L) basename(NA_CSPI_UNHARM_VRT) else NA
  ),
  rd_definition = "RD = SDI / SDImax (Woodall-Weiskittel maxSDI), common to CONUS and Canada; no rescaling at the seam",
  rd_clamp = c(0, 1),
  cspi30_note = paste("cspi30_target = equal-weight mean of within-sample z-scores of",
                      "BA_ha (m2 ha-1), topht (m), and RD (unitless); trained on Canada NFI",
                      "true-coordinate plots. Operational fine-scale ground-productivity",
                      "index; DESIGN CHOICE flagged for Aaron's review."),
  # CORRECTED 28 July 2026. The previous value of this field read "CANADA-ONLY. CONUS has
  # no 30 m CSPI product; NA_CSPI30 becomes a true mosaic only when a CONUS 30 m CSPI is
  # built." That was factually wrong and it is the field downstream consumers read.
  na_cspi30_status = na_cspi30_basis,
  conus_cspi30 = list(
    exists      = isTRUE(conus_cspi_ok),
    path        = CONUS_CSPI30,
    forest_path = CONUS_CSPI30_FOREST,
    aggregate_1km_path = CONUS_CSPI30_1KM,
    verified_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    grid        = "EPSG:4326, 0.000277778 deg, 212400 x 90000, extent -125 to -66 lon, 24 to 49 lat",
    size_bytes  = if (isTRUE(conus_cspi_ok)) file.info(CONUS_CSPI30)$size else NA,
    definition  = CONUS_CSPI30_DEF,
    components  = c("ESI v7", "BGI", "Asym", "MIAMI NPP", "MOD17A3HGF NPP mean 2017-2023"),
    rules       = c("at least 3 of 5 components required per cell",
                    "mean z clamped to +/- 3",
                    "rescaled to 0-100"),
    evidence    = c("mia_g.tif band description npp_miami_gDM_m2_yr",
                    "mod_g.tif band description mod17a3hgf_npp_mean_2017_2023",
                    "cspi_v2_aligned/{Asym,BGI,NPP_MIAMI}_on_esi_grid.tif",
                    "CSPI_v2_1_0_release_plan.md (MOD17 swap; four-component ancestor)"),
    reference_note = "CONUS_CSPI_v2_5component_definition_2026-07-28.md"
  ),
  cspi30_definition_mismatch = list(
    harmonized = isTRUE(CSPI30_HARMONIZED),
    conus_definition  = CONUS_CSPI30_DEF,
    canada_definition = CANADA_CSPI30_DEF,
    consequence = paste(
      "The two national 30 m surfaces are geometrically mosaicable and semantically",
      "incompatible. NA_CSPI30_30m_UNHARMONIZED_container.vrt exists for reconciliation",
      "only; it must not be read as a single index. Reconciliation obligation: report the",
      "correlation between any new fixed-component NA index and CSPI_v2_5component_30m.tif",
      "over their shared footprint and explain any offset in terms of the component set.")
  ),
  inputs = list(conus_rd = CONUS_RD, conus_rd_uncertainty = CONUS_RD_UNC,
                conus_cspi30 = CONUS_CSPI30,
                rd_tile_dir = RD_TILE_DIR, cspi_tile_dir = CSPI_TILE_DIR),
  tile_counts = list(rd = n_rd_tiles, cspi30 = n_cspi_tiles),
  compliance = "Gridded rasters only; no plot coordinate; NB gridded predictions are model outputs from public AEF embeddings, not JDI plot data.",
  notes = c("Products are GDAL VRTs referencing per-tile GeoTIFFs in place, plus external .ovr overview pyramids.",
            "A materialized COG is opt-in (MATERIALIZE_COG).")
)
tryCatch(
  write_json(prov, file.path(RD_OUT_DIR, "na_30m_provenance.json"),
             auto_unbox = TRUE, pretty = TRUE, na = "null"),
  error = function(e) log_err("provenance json", conditionMessage(e)))

say("[done] STAGE 4 complete. Products in %s and %s", RD_OUT_DIR, CSPI_OUT_DIR)
say("       NA_RD_30m.vrt is seamless (CONUS + Canada).")
say("       NA_CSPI30 basis: %s", na_cspi30_basis)
