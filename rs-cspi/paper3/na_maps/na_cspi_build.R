#!/usr/bin/env Rscript
# =============================================================================
# na_cspi_build.R
# Seamless North American CSPI (Continental Site Productivity Index) surface
#
# Author track: Aaron Weiskittel Paper 2/3 line (BGI-CSPI CONUS -> continental)
# Purpose: harmonize the existing CONUS 5-component CSPI product and the Canada
#          RS-CSPI product into two continental deliverables on one common grid.
#
# ANNOTATION, 25 August 2026, per cspi-component-count-reconciliation_FINAL_2026-08-19.md.
# The "CONUS 5-component CSPI product" this script harmonizes with Canada is an experimental
# v2both-line surface, NOT the CSPI v2 of record. CSPI v2 of record is the three-component
# composite z(ESI) + z(BGI) + z(Asym) per the manuscript, the composite specification section
# 3.2, and build job 11555064. See the reconciliation memo for the full evidence chain and the
# file-by-file edit list; the path bindings below are left as-is pending a decision to repoint.
#
#   Deliverable 1 (built now, fully seamless):
#     NA_RS_CSPI_2km.tif  = feathered mosaic of the Canada RS-CSPI surface and a
#     CONUS RS/NPP-equivalent productivity surface, cross-calibrated in the
#     ~49 N overlap band and blended across a 50 km buffer so the seam is
#     invisible. Forest-masked.
#
#   Deliverable 2 (framework staged, Asym flagged pending for Canada):
#     NA_CSPI_composite_2km.tif = composite of the NA-wide components that exist
#     (ESI, BGI, NPP), with Asym as a CONUS-only / Canada-pending component. The
#     composite is written as a function so it recomputes automatically once a
#     Canada Asym raster is dropped in. A component-availability table CSV is
#     written alongside.
#
# Outputs land in /fs/scratch/PUOM0008/crsfaaron/na_maps/cspi/ :
#   - continental GeoTIFF (LZW)              *_2km.tif
#   - downsampled COG (overviews, PNG-friendly) *_2km_cog.tif
#   - provenance JSON                        na_cspi_provenance.json
#   - component availability table           na_cspi_component_availability.csv
#
# House rules honored: no em dashes; SI units with caret exponents in comments
# (Mg ha^-1 yr^-1); idiomatic runnable terra + data.table; robust file.exists
# guards with clearly commented TODO fallbacks; no invented band names or scales.
# =============================================================================

# ------------------------------------------------------------------ libraries
suppressPackageStartupMessages({
  library(terra)
  library(data.table)
  library(jsonlite)
})

terraOptions(progress = 0)  # quiet, headless
set.seed(42)

# =============================================================================
# DESIGN DEFAULTS (documented; chosen on autopilot, confirm at submit time)
# -----------------------------------------------------------------------------
# GRID: EPSG:4326 at 0.02 deg (~2 km). This is the honest common denominator:
#       Canada RS-CSPI is native 0.02 deg, so we do not fabricate resolution by
#       upsampling Canada to CONUS 30 m. CONUS products are downsampled to 2 km
#       with AREA-WEIGHTED averaging (method = "average"), which is the correct
#       aggregation for a continuous productivity field.
#
# NA EXTENT: union of the two source extents.
#       CONUS lon -125..-65.99, lat 24..49 ; Canada lon -141..-52, lat 41..70.
#       Union -> lon -141..-52, lat 24..70. Snapped to the 0.02 deg grid origin.
#
# CROSS-CALIBRATION (Deliverable 1): the CONUS RS side is driven by MIAMI NPP
#       (NPP_MIAMI_full_prismres.tif), the Canada side by the published Canada
#       RS-CSPI (env -> MODIS NPP). These are on different native scales, so we
#       DO NOT assume a shared unit. Default strategy, in priority order:
#         (A) If the two surfaces overlap (they share the 41..49 N band), fit a
#             simple linear cross-calibration CONUS ~ a + b * Canada within a
#             ~200 km overlap window near 49 N, apply it to map CONUS NPP into
#             Canada RS-CSPI units, and record a, b, n, R2 in provenance.
#         (B) Fallback if the overlap is too thin / degenerate (n small or near
#             zero variance): z-standardize each side within its own extent so
#             both are unitless anomalies, and record method = "zscore".
#       The chosen path is written to provenance ($cross_calibration$method).
#
# SEAM BLEND: 49 N is the political CONUS/Canada line but the DATA seam is where
#       the two rasters stop overlapping. We feather over a 50 km buffer using a
#       linear distance-to-edge weight (weight -> 1 deep inside a surface, ramps
#       to 0.5 at the seam). No visible discontinuity results. See seam_blend().
#
# FOREST MASK: applied to both deliverables. Source preference:
#       (1) CONUS forest mask implied by CSPI_v2_5component_30m_forest.tif
#           (non-NA cells = forest), aggregated to 2 km as a fractional cover
#           then thresholded at >= 0.05 (i.e. any forest in the 2 km cell).
#       (2) TODO fallback: if no NA-wide forest layer is available for Canada,
#           we keep Canada cells where the Canada RS-CSPI itself is non-NA (the
#           Canada product is already effectively forest-domain), and only apply
#           the CONUS forest mask to the CONUS side. Documented in provenance.
# =============================================================================

# ------------------------------------------------------------------ constants
GRID_RES_DEG <- 0.02                 # ~2 km at mid-latitudes
NA_XMIN <- -141.00; NA_XMAX <- -52.00
NA_YMIN <-   24.00; NA_YMAX <-  70.00
CRS_LL  <- "EPSG:4326"

SEAM_BUFFER_KM   <- 50               # feather half-width
SEAM_LAT         <- 49               # CONUS northern edge; handoff latitude to Canada
OVERLAP_BAND_KM  <- 200              # cross-calibration window near the seam
FOREST_FRAC_THRESH <- 0.05           # 2 km cell kept if >= 5% forest at 30 m

# Approximate km-per-degree latitude (constant); longitude handled where needed.
KM_PER_DEG_LAT <- 111.32

# ------------------------------------------------------------------ input paths
# All confirmed EPSG:4326 in the Cardinal inventory; used as-is.
P <- list(
  conus_composite_30m      = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m.tif",
  conus_composite_30m_for  = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m_forest.tif",
  conus_composite_1km      = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_1km.tif",
  conus_bgi                = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/cspi_v2_aligned/BGI_on_esi_grid.tif",
  conus_asym               = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/cspi_v2_aligned/Asym_on_esi_grid.tif",
  conus_npp_on_esi         = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/cspi_v2_aligned/NPP_MIAMI_on_esi_grid.tif",
  conus_npp_full           = "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/NPP_MIAMI_full_prismres.tif",
  canada_rs_cspi_2km       = "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/Canada_RS_CSPI_npp_2km.tif",
  canada_npp_5km           = "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/Canada_MODIS_NPP_5km.tif",
  # ESI is NA-wide (ClimateNA ESI). The CONUS ESI grid is implicit in the
  # aligned components; a wall-to-wall Canada ESI raster may need generating.
  # TODO(submit): confirm final NA ESI raster path once na_esi_surface.R has run
  # on Cardinal. Placeholder path below is checked with file.exists and skipped
  # gracefully if absent.
  na_esi_2km               = "/fs/scratch/PUOM0008/crsfaaron/na_maps/cspi/NA_ESI_2km.tif",
  # Canada BGI wall-to-wall raster: likely must be predicted from the RS->BGI
  # model (NSBE net increment ~ +1.1 Mg ha^-1 yr^-1 at Canadian plots). Flagged
  # TODO; checked with file.exists and skipped if absent.
  canada_bgi_2km           = "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/Canada_BGI_2km.tif",
  # Canada Asym: NOT available (gated on true-coordinate remeasurement). The
  # composite function looks for this path and, if present, folds Asym in NA-wide.
  canada_asym_2km          = "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/Canada_Asym_2km.tif"
)

OUT_DIR <- "/fs/scratch/PUOM0008/crsfaaron/na_maps/cspi"
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------ helpers ---

# require_file(): file.exists guard that records the miss and returns NULL so the
# caller can trigger its documented fallback rather than crashing the batch job.
MISSING <- character(0)
require_file <- function(path, label) {
  if (is.null(path) || !file.exists(path)) {
    msg <- sprintf("[MISSING] %s not found at: %s", label, path %||% "<NULL>")
    message(msg)
    MISSING[[length(MISSING) + 1L]] <<- sprintf("%s :: %s", label, path %||% "<NULL>")
    return(NULL)
  }
  message(sprintf("[ok] %s -> %s", label, path))
  path
}
`%||%` <- function(a, b) if (is.null(a)) b else a

# na_template(): the canonical continental 0.02 deg grid, snapped to a clean
# origin so all resampled inputs share exactly aligned cells.
na_template <- function() {
  # Snap extent outward to a multiple of the resolution to guarantee alignment.
  xmin <- floor(NA_XMIN / GRID_RES_DEG) * GRID_RES_DEG
  xmax <- ceiling(NA_XMAX / GRID_RES_DEG) * GRID_RES_DEG
  ymin <- floor(NA_YMIN / GRID_RES_DEG) * GRID_RES_DEG
  ymax <- ceiling(NA_YMAX / GRID_RES_DEG) * GRID_RES_DEG
  rast(ext(xmin, xmax, ymin, ymax), resolution = GRID_RES_DEG, crs = CRS_LL)
}

# to_grid(): reproject/resample any input onto the NA template. Continuous
# productivity fields are AREA-WEIGHTED averaged when downsampling (native finer
# than 2 km), bilinear when upsampling (native coarser than 2 km, e.g. Canada
# NPP at 5 km). We inspect native resolution to pick the honest method.
to_grid <- function(r, tmpl, prefer_average = TRUE, label = "layer") {
  if (is.null(r)) return(NULL)
  native_deg <- mean(res(r))
  if (prefer_average && native_deg < GRID_RES_DEG) {
    method <- "average"   # downsampling a fine grid: conserve the mean
  } else if (native_deg > GRID_RES_DEG) {
    method <- "bilinear"  # upsampling a coarse grid: smooth interpolation
  } else {
    method <- "average"
  }
  message(sprintf("[to_grid] %s native ~%.5f deg -> 2 km via %s",
                  label, native_deg, method))
  # project() handles CRS + grid in one step; align to template cells exactly.
  out <- project(r, tmpl, method = method, align = TRUE)
  # project() with align can pad; crop/extend to the exact template footprint.
  out <- resample(out, tmpl, method = if (method == "average") "average" else "bilinear")
  out
}

# zstd(): z-standardize within a raster's own valid domain (unitless anomaly).
zstd <- function(r) {
  v  <- values(r, mat = FALSE)
  mu <- mean(v, na.rm = TRUE)
  sdv <- stats::sd(v, na.rm = TRUE)
  if (!is.finite(sdv) || sdv == 0) return(r)  # degenerate; leave as-is
  (r - mu) / sdv
}

# -----------------------------------------------------------------------------
# seam_blend(): feathered mosaic of two co-gridded rasters over a distance
# buffer so there is no visible discontinuity at the data seam.
#
# Logic: where only one surface has data, take it. Where BOTH have data (the
# overlap band), blend with a weight that ramps linearly with distance from the
# nearest edge of the *other* surface, saturating to a straight average at the
# seam line and to the pure surface once you are SEAM_BUFFER_KM inside your own
# exclusive domain.
#
# rA, rB : SpatRasters on the identical template (single layer each).
# returns: single blended SpatRaster.
# -----------------------------------------------------------------------------
seam_blend <- function(rA, rB, buffer_km = SEAM_BUFFER_KM, tmpl = NULL) {
  stopifnot(!is.null(rA), !is.null(rB))
  if (is.null(tmpl)) tmpl <- rA

  # rA is the CONUS-side surface (extent stops at ~49 N), rB is the Canada-side
  # surface (extends 41 to 70 N), so the two OVERLAP across the whole 41 to 49
  # band, not just at a thin seam. We therefore prefer CONUS wherever it exists
  # (the US domain) and hand off to Canada north of 49 N, feathering only in a
  # thin latitude band around 49 N so no visible discontinuity appears. This
  # avoids terra::distance() entirely (which failed on the 10 M-cell lon/lat grid
  # and is needlessly slow here).
  a_has <- !is.na(rA)
  b_has <- !is.na(rB)
  both  <- a_has & b_has

  # Base mosaic: CONUS where present, else Canada.
  base <- cover(rA, rB)

  # If there is no genuine overlap, the straight cover() is already correct.
  if (global(both, "sum", na.rm = TRUE)[[1]] == 0) {
    message("[seam_blend] no overlap; using straight cover() mosaic")
    names(base) <- "NA_RS_CSPI"; return(base)
  }

  # Latitude-feather across the handoff band. buffer_km is converted to a
  # half-width in degrees (~111 km per degree) centred on the CONUS northern
  # edge SEAM_LAT. South of the band -> pure CONUS; north -> pure Canada.
  half_deg <- max(buffer_km, 25) / 111
  lat  <- init(tmpl, "y")
  # wA (CONUS weight) = 1 at/below (SEAM_LAT - half), 0 at/above (SEAM_LAT + half)
  wA <- clamp((SEAM_LAT + half_deg - lat) / (2 * half_deg), 0, 1, values = TRUE)
  inband <- both & (lat > (SEAM_LAT - half_deg)) & (lat < (SEAM_LAT + half_deg))
  ov <- wA * rA + (1 - wA) * rB
  blended <- ifel(inband, ov, base)
  blended <- cover(blended, rB)          # fill any residual NA from Canada
  names(blended) <- "NA_RS_CSPI"
  blended
}

# -----------------------------------------------------------------------------
# cross_calibrate(): fit CONUS ~ a + b * Canada in the ~200 km overlap band
# near 49 N and return the mapped-CONUS raster plus fit stats. Falls back to
# z-standardization if the overlap is too thin or degenerate.
# -----------------------------------------------------------------------------
cross_calibrate <- function(conus_r, canada_r, tmpl,
                            band_km = OVERLAP_BAND_KM) {
  a_has <- !is.na(conus_r)
  b_has <- !is.na(canada_r)
  both  <- a_has & b_has
  n_ov  <- global(both, "sum", na.rm = TRUE)[[1]]

  result <- list()
  if (is.na(n_ov) || n_ov < 50) {
    # Not enough joint cells to trust a regression. Fall back to z-scores.
    message("[xcal] overlap too thin (n=", n_ov, "); z-standardizing each side")
    return(list(
      conus_mapped = zstd(conus_r),
      canada_mapped = zstd(canada_r),
      method = "zscore",
      a = NA_real_, b = NA_real_, n = as.numeric(n_ov), r2 = NA_real_
    ))
  }

  # Restrict to the overlap band: cells within band_km of 49 N AND jointly valid.
  # (The physical data overlap is 41..49 N; we weight the calibration to the
  #  cells nearest the seam to avoid distant-latitude bias.)
  seam_lat <- 49.0
  yc <- init(tmpl, "y")
  in_band <- abs(yc - seam_lat) * KM_PER_DEG_LAT <= band_km
  msk <- both & in_band
  if (global(msk, "sum", na.rm = TRUE)[[1]] < 50) msk <- both  # widen if sparse

  d <- data.table(
    conus  = as.numeric(values(mask(conus_r,  msk, maskvalues = c(NA, FALSE)))),
    canada = as.numeric(values(mask(canada_r, msk, maskvalues = c(NA, FALSE))))
  )
  d <- d[is.finite(conus) & is.finite(canada)]

  if (nrow(d) < 50 || stats::sd(d$canada) == 0 || stats::sd(d$conus) == 0) {
    message("[xcal] degenerate variance; z-standardizing each side")
    return(list(
      conus_mapped = zstd(conus_r),
      canada_mapped = zstd(canada_r),
      method = "zscore",
      a = NA_real_, b = NA_real_, n = nrow(d), r2 = NA_real_
    ))
  }

  # Fit Canada-units = a + b * CONUS-NPP so CONUS is mapped INTO Canada units,
  # which keeps the published Canada RS-CSPI as the reference scale.
  fit <- stats::lm(canada ~ conus, data = d)
  a <- unname(coef(fit)[1]); b <- unname(coef(fit)[2])
  r2 <- summary(fit)$r.squared
  message(sprintf("[xcal] linear map canada = %.4g + %.4g * conus  (n=%d, R2=%.3f)",
                  a, b, nrow(d), r2))

  list(
    conus_mapped  = a + b * conus_r,  # CONUS now in Canada RS-CSPI units
    canada_mapped = canada_r,         # Canada kept as reference
    method = "linear",
    a = a, b = b, n = nrow(d), r2 = r2
  )
}

# -----------------------------------------------------------------------------
# build_forest_mask(): NA-wide forest mask on the template. CONUS side from the
# forest-only composite (non-NA = forest), aggregated to 2 km fractional cover
# and thresholded. Canada side defaults to "keep where Canada RS-CSPI is valid".
# Returns a logical-ish SpatRaster (1 = keep, NA = drop) plus a source string.
# -----------------------------------------------------------------------------
build_forest_mask <- function(tmpl, conus_forest_path, canada_valid_r) {
  src <- character(0)
  keep <- tmpl * 0 + NA

  fp <- require_file(conus_forest_path, "CONUS forest composite (30 m)")
  if (!is.null(fp)) {
    fr <- rast(fp)
    if (nlyr(fr) > 1) fr <- fr[[1]]
    forest_frac <- project(!is.na(fr), tmpl, method = "average", align = TRUE)
    forest_frac <- resample(forest_frac, tmpl, method = "average")
    conus_keep  <- ifel(forest_frac >= FOREST_FRAC_THRESH, 1, NA)
    keep <- cover(keep, conus_keep)
    src  <- c(src, sprintf("CONUS: non-NA of %s aggregated to 2 km, frac >= %.2f",
                           basename(conus_forest_path), FOREST_FRAC_THRESH))
  } else {
    # TODO(submit): no CONUS forest composite -> CONUS side unmasked. Consider
    # substituting a NLCD/ESA-WorldCover forest class aggregated to 2 km.
    src <- c(src, "CONUS: forest composite MISSING -> CONUS side left unmasked (TODO)")
  }

  if (!is.null(canada_valid_r)) {
    canada_keep <- ifel(!is.na(canada_valid_r), 1, NA)
    keep <- cover(keep, canada_keep)
    src  <- c(src, "Canada: keep where Canada RS-CSPI is non-NA (product is forest-domain)")
    # TODO(submit): if a true NA-wide forest raster (e.g. Canada NFI / ESA
    # WorldCover) is dropped in, replace this with an explicit forest class.
  }

  names(keep) <- "forest_mask"
  list(mask = keep, source = paste(src, collapse = " | "))
}

# -----------------------------------------------------------------------------
# write_cog(): write a Cloud-Optimized GeoTIFF with overviews, PNG-friendly for
# quick continental previews. LZW-compressed, tiled.
# -----------------------------------------------------------------------------
write_geotiff <- function(r, path) {
  writeRaster(r, path, overwrite = TRUE,
              gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=IF_SAFER"))
  message("[write] GeoTIFF -> ", path)
}
write_cog <- function(r, path) {
  writeRaster(r, path, overwrite = TRUE, filetype = "COG",
              gdal = c("COMPRESS=LZW", "OVERVIEWS=AUTO", "BIGTIFF=IF_SAFER",
                       "RESAMPLING=AVERAGE"))
  message("[write] COG -> ", path)
}

# =============================================================================
# PIPELINE
# =============================================================================
message("\n==== NA CSPI build starting ", format(Sys.time()), " ====\n")
tmpl <- na_template()
message(sprintf("[grid] template %d x %d cells, res %.3f deg, ext [%.2f,%.2f]x[%.2f,%.2f]",
                nrow(tmpl), ncol(tmpl), GRID_RES_DEG,
                xmin(tmpl), xmax(tmpl), ymin(tmpl), ymax(tmpl)))

# ------------------------------------------------------------ load Canada side
canada_path <- require_file(P$canada_rs_cspi_2km, "Canada RS-CSPI (2 km)")
canada_rs   <- if (!is.null(canada_path)) to_grid(rast(canada_path), tmpl,
                                                  label = "Canada RS-CSPI") else NULL

# ------------------------------------------------- load CONUS RS/NPP side
# Priority: MIAMI NPP full PRISM-res surface. Fallback: NPP-on-ESI-grid; last
# resort the 1 km composite itself (already CSPI-scaled, documented in prov).
conus_npp_path <- require_file(P$conus_npp_full, "CONUS MIAMI NPP (PRISM res)")
conus_src_note <- "NPP_MIAMI_full_prismres.tif"
if (is.null(conus_npp_path)) {
  conus_npp_path <- require_file(P$conus_npp_on_esi, "CONUS NPP on ESI grid (fallback)")
  conus_src_note <- "NPP_MIAMI_on_esi_grid.tif (fallback)"
}
if (is.null(conus_npp_path)) {
  # Last-resort fallback: use the CONUS composite directly. It is already on the
  # CSPI scale, so treat it as the CONUS RS-equivalent surface and note it.
  conus_npp_path <- require_file(P$conus_composite_1km, "CONUS CSPI 1 km (last-resort)")
  conus_src_note <- "CSPI_v2_5component_1km.tif (last-resort; already CSPI-scaled)"
}
conus_rs <- if (!is.null(conus_npp_path)) to_grid(rast(conus_npp_path), tmpl,
                                                  label = "CONUS RS/NPP") else NULL

# --------------------------------------------------- cross-calibrate + blend
rs_cspi <- NULL
xcal <- list(method = "not_run", a = NA, b = NA, n = NA, r2 = NA)
if (!is.null(canada_rs) && !is.null(conus_rs)) {
  xcal_res <- cross_calibrate(conus_rs, canada_rs, tmpl)
  xcal <- xcal_res[c("method", "a", "b", "n", "r2")]
  # A = CONUS mapped into Canada units, B = Canada reference.
  rs_cspi <- seam_blend(xcal_res$conus_mapped, xcal_res$canada_mapped,
                        buffer_km = SEAM_BUFFER_KM, tmpl = tmpl)
} else if (!is.null(canada_rs)) {
  message("[warn] CONUS RS side missing -> emitting Canada-only RS-CSPI (TODO CONUS)")
  rs_cspi <- canada_rs; names(rs_cspi) <- "NA_RS_CSPI"
} else if (!is.null(conus_rs)) {
  message("[warn] Canada RS side missing -> emitting CONUS-only RS-CSPI (TODO Canada)")
  rs_cspi <- conus_rs; names(rs_cspi) <- "NA_RS_CSPI"
} else {
  stop("Both RS sources missing; cannot build Deliverable 1. Check input paths.")
}

# ------------------------------------------------------------- forest mask
fm <- build_forest_mask(tmpl, P$conus_composite_30m_for, canada_rs)
rs_cspi_masked <- mask(rs_cspi, fm$mask)
names(rs_cspi_masked) <- "NA_RS_CSPI"

# ------------------------------------------------------------- write Deliv 1
d1_tif <- file.path(OUT_DIR, "NA_RS_CSPI_2km.tif")
d1_cog <- file.path(OUT_DIR, "NA_RS_CSPI_2km_cog.tif")
write_geotiff(rs_cspi_masked, d1_tif)
write_cog(rs_cspi_masked, d1_cog)

# =============================================================================
# DELIVERABLE 2: NA composite framework (ESI + BGI + NPP now; Asym pending)
# -----------------------------------------------------------------------------
# Written as a function so a later Canada Asym raster auto-folds in. Components
# are z-standardized within the NA domain before averaging so the composite is
# a balanced multi-signal productivity index and unit mismatches do not bias it.
# The equal-weight mean over AVAILABLE components is the default; document any
# weighting change here.
# =============================================================================
load_component_na <- function(conus_path, canada_path, tmpl, label,
                              conus_is_composite = FALSE) {
  cp <- require_file(conus_path,  sprintf("CONUS %s", label))
  kp <- require_file(canada_path, sprintf("Canada %s", label))
  conus_r <- if (!is.null(cp)) to_grid(rast(cp), tmpl, label = sprintf("CONUS %s", label)) else NULL
  canada_r <- if (!is.null(kp)) to_grid(rast(kp), tmpl, label = sprintf("Canada %s", label)) else NULL
  if (is.null(conus_r) && is.null(canada_r)) return(NULL)
  # Feather the two national pieces of the SAME component across the seam.
  if (!is.null(conus_r) && !is.null(canada_r)) {
    seam_blend(zstd(conus_r), zstd(canada_r), tmpl = tmpl)
  } else if (!is.null(conus_r)) {
    r <- zstd(conus_r); names(r) <- label; r
  } else {
    r <- zstd(canada_r); names(r) <- label; r
  }
}

build_na_composite <- function(tmpl, forest_mask) {
  comps <- list()
  avail <- data.table(component = character(), conus = logical(),
                      canada = logical(), used = logical(), note = character())

  # --- ESI (NA-wide ClimateNA ESI). CONUS from aligned grid via composite ESI
  #     is not directly a file; we use the NA ESI raster if generated, else the
  #     CONUS composite as an ESI-bearing proxy is NOT valid, so ESI is only
  #     included when the explicit NA ESI raster exists. TODO fallback below.
  esi_path <- require_file(P$na_esi_2km, "NA ESI (2 km)")
  if (!is.null(esi_path)) {
    esi <- to_grid(rast(esi_path), tmpl, label = "NA ESI")
    esi <- zstd(esi); names(esi) <- "ESI"
    comps[["ESI"]] <- esi
    avail <- rbind(avail, data.table(component = "ESI", conus = TRUE, canada = TRUE,
      used = TRUE, note = "NA-wide ClimateNA ESI raster"))
  } else {
    # TODO(submit): generate the wall-to-wall NA ESI raster (canada/magplot/
    # na_esi_surface.R + acadian_esi_surface.R) and drop it at P$na_esi_2km.
    avail <- rbind(avail, data.table(component = "ESI", conus = TRUE, canada = TRUE,
      used = FALSE, note = "NA ESI raster MISSING -> generate via na_esi_surface.R (TODO)"))
  }

  # --- BGI. CONUS BGI on ESI grid is available. Canada BGI wall-to-wall likely
  #     must be predicted from the RS->BGI model; included only if present.
  bgi <- load_component_na(P$conus_bgi, P$canada_bgi_2km, tmpl, "BGI")
  if (!is.null(bgi)) {
    comps[["BGI"]] <- bgi
    avail <- rbind(avail, data.table(component = "BGI",
      conus = file.exists(P$conus_bgi %||% ""),
      canada = file.exists(P$canada_bgi_2km %||% ""),
      used = TRUE,
      note = "CONUS BGI_on_esi_grid; Canada BGI from RS->BGI model if present (TODO wall-to-wall)"))
  } else {
    avail <- rbind(avail, data.table(component = "BGI", conus = FALSE, canada = FALSE,
      used = FALSE, note = "BGI unavailable both sides (TODO)"))
  }

  # --- NPP. CONUS MIAMI NPP + Canada MODIS NPP. Both exist.
  npp <- load_component_na(P$conus_npp_full, P$canada_npp_5km, tmpl, "NPP")
  if (!is.null(npp)) {
    comps[["NPP"]] <- npp
    avail <- rbind(avail, data.table(component = "NPP",
      conus = file.exists(P$conus_npp_full %||% ""),
      canada = file.exists(P$canada_npp_5km %||% ""),
      used = TRUE, note = "CONUS MIAMI NPP + Canada MODIS NPP"))
  } else {
    avail <- rbind(avail, data.table(component = "NPP", conus = FALSE, canada = FALSE,
      used = FALSE, note = "NPP unavailable both sides (TODO)"))
  }

  # --- Asym. CONUS Asym on ESI grid is available. Canada Asym is NOT (gated on
  #     true-coordinate remeasurement). Fold in NA-wide ONLY if a Canada Asym
  #     raster has been dropped in; otherwise Asym is CONUS-only and FLAGGED.
  conus_asym_ok  <- file.exists(P$conus_asym %||% "")
  canada_asym_ok <- file.exists(P$canada_asym_2km %||% "")

  # -------------------------------------------------------------------------------
  # DEGENERACY GATE, added 28 July 2026 (defect 4 of the code-versus-disk audit).
  # This script is superseded by na_cspi_composite.R for the composite, but it still
  # carries a live auto-fold slot for a Canada Asym raster, so it gets the same gate.
  # The hazard: /fs/scratch/PUOM0008/crsfaaron/canada/magplot/canada_asym_by_site.csv
  # holds 33,410 sites with status DONE, but cor(Asym_Mgha, AGB_Mgha) = 1.000. That
  # estimator returned standing aboveground biomass, not an asymptote. Rasterising it
  # would silently redefine the Canadian side of the composite. The gate refuses any
  # candidate whose correlation with standing AGB exceeds the threshold, and it fails
  # CLOSED: a candidate with no evaluable reference is refused, not assumed valid.
  # The full record is in DEFECT_FIXES_2026-07-28.md.
  # -------------------------------------------------------------------------------
  ASYM_AGB_R_MAX  <- as.numeric(Sys.getenv("CSPI_ASYM_AGB_R_MAX", "0.90"))
  ASYM_QUARANTINE <- c(
    "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/canada_asym_by_site.csv",
    "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/Canada_Asym_2km.tif")
  ASYM_SRC_CSV <- "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/canada_asym_by_site.csv"
  ASYM_AGB_CSV <- "/fs/scratch/PUOM0008/crsfaaron/canada/magplot/canada_agb_by_site.csv"

  if (canada_asym_ok) {
    cand <- P$canada_asym_2km
    quarantined <- cand %in% ASYM_QUARANTINE || file.exists(paste0(cand, ".QUARANTINED"))
    r_obs <- NA_real_; n_obs <- NA_integer_; basis <- "none"
    if (!quarantined && file.exists(ASYM_SRC_CSV) && file.exists(ASYM_AGB_CSV)) {
      a <- tryCatch(fread(ASYM_SRC_CSV), error = function(e) NULL)
      b <- tryCatch(fread(ASYM_AGB_CSV), error = function(e) NULL)
      if (!is.null(a) && !is.null(b) &&
          all(c("magp_site_id","Asym_Mgha") %in% names(a)) &&
          "magp_site_id" %in% names(b)) {
        bcol <- intersect(c("AGB_Mgha","AGB","agb_Mgha"), names(b))[1]
        if (!is.na(bcol)) {
          m  <- merge(a[, .(magp_site_id, Asym_Mgha)],
                      b[, c("magp_site_id", bcol), with = FALSE], by = "magp_site_id")
          ok <- is.finite(m$Asym_Mgha) & is.finite(as.numeric(m[[bcol]]))
          if (sum(ok) >= 30L) {
            r_obs <- suppressWarnings(cor(m$Asym_Mgha[ok], as.numeric(m[[bcol]])[ok]))
            n_obs <- sum(ok); basis <- "plot table"
          }
        }
      }
    }
    passed <- !quarantined && is.finite(r_obs) && abs(r_obs) <= ASYM_AGB_R_MAX
    if (!passed) {
      stop(sprintf(paste0(
        "\nREFUSED Canada Asym component: %s\n",
        "  quarantined: %s ; basis: %s ; cor(Asym, standing AGB) = %s over n = %s\n",
        "  gate: |cor| must be <= %.2f, and a candidate with no evaluable reference is refused.\n",
        "  An asymptote that tracks standing biomass at unity is the observation, not an\n",
        "  asymptote. Correct specification: transfer the CONUS estimator, which fits AGB as\n",
        "  a Chapman-Richards function with TOP HEIGHT as the developmental axis and relative\n",
        "  density in the asymptote, taking the plot asymptote as the BLUP of the plot random\n",
        "  effect at relative density 0.60. Stand age is NOT used. Reference:\n",
        "  /users/PUOM0008/crsfaaron/FIA/asym_agb_analysis/02_estimate_blups.r\n",
        "  See DEFECT_FIXES_2026-07-28.md and canada_asym_QUARANTINE_2026-07-28.md.\n"),
        cand, quarantined, basis,
        if (is.finite(r_obs)) sprintf("%.4f", r_obs) else "not evaluable",
        if (is.finite(n_obs)) format(n_obs) else "NA", ASYM_AGB_R_MAX))
    }
    message(sprintf("[asym gate] Canada Asym PASSED (basis %s, r = %.4f, n = %s)",
                    basis, r_obs, format(n_obs)))
  }

  if (canada_asym_ok) {
    asym <- load_component_na(P$conus_asym, P$canada_asym_2km, tmpl, "Asym")
    comps[["Asym"]] <- asym
    avail <- rbind(avail, data.table(component = "Asym", conus = conus_asym_ok,
      canada = TRUE, used = TRUE,
      note = "Canada Asym raster present -> folded in NA-wide"))
  } else if (conus_asym_ok) {
    # CONUS-only Asym. Excluded from the balanced NA composite to avoid a hard
    # CONUS/Canada discontinuity, but staged and clearly flagged so it activates
    # automatically once Canada Asym exists. Recorded used = FALSE.
    avail <- rbind(avail, data.table(component = "Asym", conus = TRUE, canada = FALSE,
      used = FALSE,
      note = "Canada Asym PENDING (true-coordinate remeasurement follow-on). CONUS-only Asym withheld from balanced composite to avoid seam bias; auto-activates when Canada_Asym_2km.tif is dropped in."))
  } else {
    avail <- rbind(avail, data.table(component = "Asym", conus = FALSE, canada = FALSE,
      used = FALSE, note = "Asym unavailable both sides (TODO)"))
  }

  if (length(comps) == 0L) {
    message("[warn] no components available; composite not built")
    return(list(raster = NULL, availability = avail, components = character(0)))
  }

  # Equal-weight mean over available, z-standardized components. Stack, average
  # ignoring NA so partial-coverage cells still get a value from what exists.
  stk <- rast(comps)
  comp_mean <- app(stk, fun = function(x) mean(x, na.rm = TRUE))
  comp_mean <- mask(comp_mean, forest_mask)
  names(comp_mean) <- "NA_CSPI_composite"

  list(raster = comp_mean, availability = avail, components = names(comps))
}

comp_res <- build_na_composite(tmpl, fm$mask)

d2_tif <- file.path(OUT_DIR, "NA_CSPI_composite_2km.tif")
d2_cog <- file.path(OUT_DIR, "NA_CSPI_composite_2km_cog.tif")
if (!is.null(comp_res$raster)) {
  write_geotiff(comp_res$raster, d2_tif)
  write_cog(comp_res$raster, d2_cog)
} else {
  message("[warn] Deliverable 2 composite not written (no components).")
}

# ------------------------------------------------- component availability CSV
avail_csv <- file.path(OUT_DIR, "na_cspi_component_availability.csv")
fwrite(comp_res$availability, avail_csv)
message("[write] component availability -> ", avail_csv)

# =============================================================================
# PROVENANCE JSON
# =============================================================================
prov <- list(
  product        = "North American CSPI (continental site productivity index)",
  generated_utc  = format(Sys.time(), tz = "UTC", usetz = TRUE),
  generator      = "na_cspi_build.R",
  grid = list(
    crs = CRS_LL, resolution_deg = GRID_RES_DEG, resolution_approx_km = 2,
    extent = list(xmin = xmin(tmpl), xmax = xmax(tmpl),
                  ymin = ymin(tmpl), ymax = ymax(tmpl)),
    ncol = ncol(tmpl), nrow = nrow(tmpl),
    resample_downsample = "area-weighted average", resample_upsample = "bilinear"
  ),
  deliverable_1 = list(
    file = basename(d1_tif), cog = basename(d1_cog),
    description = "Seamless NA RS-CSPI: feathered mosaic of Canada RS-CSPI (reference scale) and CONUS RS/NPP surface mapped into Canada units.",
    conus_source = conus_src_note,
    canada_source = basename(P$canada_rs_cspi_2km),
    units = "Canada RS-CSPI units (CONUS cross-calibrated into this scale); unitless z-anomaly if method=zscore",
    seam_method = sprintf("linear distance-feather over %d km buffer at the data seam near 49 N", SEAM_BUFFER_KM),
    cross_calibration = xcal
  ),
  deliverable_2 = list(
    file = if (!is.null(comp_res$raster)) basename(d2_tif) else NA,
    cog  = if (!is.null(comp_res$raster)) basename(d2_cog) else NA,
    description = "NA CSPI composite: equal-weight mean of z-standardized NA-wide components.",
    components_used = comp_res$components,
    asym_status = "Canada Asym PENDING (true-coordinate remeasurement follow-on); composite function auto-includes Asym NA-wide once Canada_Asym_2km.tif exists.",
    availability_table = basename(avail_csv)
  ),
  forest_mask = list(applied = TRUE, source = fm$source, frac_threshold = FOREST_FRAC_THRESH),
  inputs = P,
  missing_inputs = MISSING,
  design_defaults = list(
    grid = "EPSG:4326 @ 0.02 deg (~2 km), Canada-native common denominator",
    downsampling = "area-weighted average (terra project/resample method=average)",
    seam = sprintf("%d km linear distance-feather", SEAM_BUFFER_KM),
    cross_calibration_band_km = OVERLAP_BAND_KM,
    composite_weighting = "equal-weight mean over available z-standardized components"
  ),
  notes = c(
    "FIA true plot coordinates not involved; gridded public products only.",
    "Asym not available for Canada; excluded from balanced composite until a Canada Asym raster is dropped in.",
    "Canada BGI wall-to-wall raster likely predicted from RS->BGI model (TODO)."
  )
)
prov_json <- file.path(OUT_DIR, "na_cspi_provenance.json")
write_json(prov, prov_json, auto_unbox = TRUE, pretty = TRUE, na = "null")
message("[write] provenance -> ", prov_json)

message("\n==== NA CSPI build finished ", format(Sys.time()), " ====")
if (length(MISSING) > 0) {
  message("\n[SUMMARY] ", length(MISSING), " input(s) missing (fallbacks used):")
  for (m in MISSING) message("   - ", m)
}
message("[done] outputs in ", OUT_DIR)
