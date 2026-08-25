# F1 interior-nodata lattice probe: NA CSPI/RD map chain

Track E of the 25 August 2026 OODA pass. Follow-up to Cardinal job 13728891 (19 August 2026), which checked declared bounding boxes against filename jurisdiction claims across the NA CSPI/RD chain and explicitly flagged, as its own stated limitation, that a bbox-level check cannot catch a raster whose extent looks right while its interior is silently nodata. This report builds and runs the interior probe that check was missing.

## Headline verdict

Yes, interior-nodata defects were found, and they cluster in two places that matter for the parallel tracks running today.

First, two Canada-claimed 2 km diagnostic files are void of valid data almost everywhere they were sampled, not just in one province: `cspi/Canada_FIPI_composite_2km_strict.tif` and `cspi/_intermediate_canada_soils_2km.tif`. The second of these is not a partial defect. Every one of 93,366 lattice points sampled across its full declared extent, including the CONUS-overlap strip, returned its declared nodata sentinel (-2147483648). This is not the single-province masking pattern the probe was designed to hunt (the New Brunswick case), it is worse: the whole file appears never to have been populated. Both are auxiliary or intermediate outputs, not the headline CSPI/BGI/ESI products, which lowers the operational stakes but the finding should still be traced to its source job before either file is trusted or re-used.

Second, and more directly relevant to the RD30 CONUS assembly and ESI30 gate tracks running in parallel: 34 of 60 stratified-sampled tiles (57 percent) in `Disturbance_run/alphaearth/conus/rd30m_unc_tiles/` (the RD30 uncertainty layer) are at or near total nodata inside their own CONUS footprint, while the remaining 26 sampled tiles span a real gradient from 8 percent to 93 percent nodata. This does not look like silent masking, it looks like an uncertainty layer that is partially computed. It is the kind of gap that a downstream assembly step could either legitimately treat as "not yet done" or silently swallow as "no uncertainty here," which is exactly the F1 failure pattern. By contrast, the primary RD30 data tiles (`rd30m_tiles`), the quality-mask tiles (`rd30m_qm_tiles`), the calibration tiles (`rd30m_cal_tiles`), the CONUS RD30 mosaic (`conus_RD_30m_2022.tif`, 81.1 percent nodata, below threshold but worth a second look given it is the flagship CONUS RD30 product), the Canada NFI aef tile sample, and the entire cspi_v7 CONUS composite family (Asym, BGI, NPP_MIAMI, CSPI_v2_5component, mia_g, mod_g) came back clean at this coarse resolution. No evidence of a healthy-bbox-dead-interior defect in the flagship RD30 or ESI30 products themselves.

## Probe design, pre-registered

For every raster, lay a regular lattice across its full declared extent (not a bbox corner check), read the raster decimated to that lattice via a single bulk resampled read, classify each lattice cell as nodata or valid, and bin cells into jurisdiction cells (CONUS plus the ten Canadian provinces, three territories, and Alaska, using simple public-reference bounding boxes). Flag INTERIOR_NODATA when a jurisdiction the file claims to cover has a nodata fraction above 0.95 with at least 5 sampled points in that cell.

Spacing: targeted 20 km native ground spacing per axis, decimated grid capped to 20 to 500 columns and 20 to 350 rows. Twenty kilometers was chosen against Prince Edward Island, the smallest Canadian jurisdiction at roughly 145 km by 65 km. At this spacing PEI still receives on the order of 7 by 3 lattice cells, enough to establish a nodata fraction rather than a single lucky or unlucky sample. Every larger province or territory gets proportionally more. A NA-wide 2 km raster produces on the order of 94,000 to 126,000 lattice cells; an individual 30 m RD tile produces 368 to 400. All reads were single bulk decimated reads (rasterio `out_shape` with nearest-neighbor resampling), not per-point I/O, which is what kept a 344-raster run under four minutes of wall time on one Cardinal node.

Threshold: 0.95 nodata fraction, chosen because the motivating prior defect (the New Brunswick raster masked by a CONUS-only land cover product) was not "mostly missing," it was completely absent across the whole province. A 95 percent bar catches a wholesale masking failure while leaving room for jurisdictions that are legitimately sparse (for example a forest-productivity layer over Nunavut's tundra, which came back around 88 percent nodata across several files and was judged plausible, not flagged).

Claim assignment, extended to unprefixed files as required: filename prefix (na_/conus/canada) first; then a working-record override for the six cspi_v7 files confirmed CONUS-only by `NEWS_v3.0.0.md` and `manuscript/v3_release_path_forward.md` in the cspi-conus repo; then a filename substring match; then a parent-directory substring match (this is what let the RD30 tile family, which carries no per-tile prefix, inherit a CONUS claim from living under `.../alphaearth/conus/`); then, only as a last resort, inference from the file's own measured bbox coverage fraction. A file that conflicts between two of these signals, or matches none, is flagged OPEN rather than guessed.

## Result table, known-inventory rasters (the 44 files the 19 August sweep covered)

| file | claim | basis | worst jurisdiction | worst nodata frac | flag |
|---|---|---|---|---|---|
| Canada_BGI_2km.tif | CANADA_ALL | prefix | PE | 0.765 | |
| Canada_BGI_gross_2km.tif | CANADA_ALL | prefix | PE | 0.765 | |
| Canada_BGI_gross_full_2km.tif | CANADA_ALL | prefix | PE | 0.765 | |
| Canada_BGI_min_2km_20260804.tif | CANADA_ALL | prefix | PE | 0.765 | |
| Canada_ESI_refit_2km.tif | CANADA_ALL | prefix | PE | 0.755 | |
| Canada_FIPI_composite_2km.tif | CANADA_ALL | prefix | PE | 0.755 | |
| Canada_FIPI_composite_2km_cog.tif | CANADA_ALL | prefix | NL | 0.479 | |
| Canada_FIPI_composite_2km_componentmask.tif | CANADA_ALL | prefix | PE | 0.714 | |
| Canada_FIPI_composite_2km_ncomponents.tif | CANADA_ALL | prefix | PE | 0.714 | |
| Canada_FIPI_composite_2km_qaflags.tif | CANADA_ALL | prefix | PE | 0.714 | |
| Canada_FIPI_composite_2km_strict.tif | CANADA_ALL | prefix | AB | 1.000 | INTERIOR_NODATA |
| Canada_FIPI_composite_2km_uncertainty.tif | CANADA_ALL | prefix | PE | 0.714 | |
| Canada_land_mask_2km.tif | CANADA_ALL | prefix | PE | 0.752 | |
| NA_ESI_2km.tif | NA_WIDE | prefix | CONUS | 0.938 | |
| NA_RS_CSPI_2km.tif | NA_WIDE | prefix | PE | 0.684 | |
| _can2.tif | OPEN | no_claim_found | | | OPEN |
| _con2.tif | OPEN | no_claim_found | | | OPEN |
| _con_map.tif | OPEN | no_claim_found | | | OPEN |
| _intermediate_canada_climate34_2km.tif | CANADA_ALL | name_substring | PE | 0.694 | |
| _intermediate_canada_soils_2km.tif | CANADA_ALL | name_substring | AB | 1.000 | INTERIOR_NODATA |
| _intermediate_conus_forest_frac_2km.tif | CONUS | name_substring | | 0.000 | |
| _lat.tif | OPEN | no_claim_found | | | OPEN |
| rd/_conus_rd_1km.tif | CONUS | prefix | | 0.000 | |
| CONUS_RD_2km.tif | CONUS | prefix | CONUS | 0.368 | |
| Canada_RD_2km.tif | CANADA_ALL | prefix | NU | 0.879 | |
| NA_RD_2km.tif | NA_WIDE | prefix | NU | 0.879 | |
| _raw_canada.tif | CANADA_ALL | name_substring | NU | 0.877 | |
| _raw_conus.tif | CONUS | name_substring | CONUS | 0.306 | |
| cov_canmask_2km.tif | OPEN | no_claim_found | | | OPEN |
| cov_climna33_2km.tif | OPEN | no_claim_found | | | OPEN |
| cov_npp_canada_2km.tif | CANADA_ALL | name_substring | PE | 0.633 | |
| cov_npp_conus_2km.tif | CONUS | name_substring | CONUS | 0.332 | |
| cov_nppcv_conus_2km.tif | CONUS | name_substring | CONUS | 0.332 | |
| cov_srad12_2km.tif | OPEN | no_claim_found | | | OPEN |
| CSPI_v2_5component_1km.tif | CONUS | working_record | CONUS | 0.443 | |
| CSPI_v2_5component_30m.tif | CONUS | working_record | CONUS | 0.444 | |
| CSPI_v2_5component_30m_forest.tif | CONUS | working_record | CONUS | 0.822 | |
| mia_g.tif | CONUS | working_record | CONUS | 0.431 | |
| mod_g.tif | CONUS | working_record | CONUS | 0.358 | |
| Asym_on_esi_grid.tif | CONUS | working_record | CONUS | 0.447 | |
| BGI_on_esi_grid.tif | CONUS | working_record | CONUS | 0.447 | |
| NPP_MIAMI_on_esi_grid.tif | CONUS | working_record | CONUS | 0.291 | |
| v4_climate_33_1km.tif | OPEN | crs_bbox_artifact | | | OPEN |
| conus_RD_30m_2022.tif | CONUS | prefix | CONUS | 0.811 | |

`CSPI_v2_5component_30m_forest.tif` at 82.2 percent CONUS nodata is expected, not a defect. It is the forest-masked variant, so non-forest CONUS land is deliberately set to nodata.

## Result table, discovered tile families (stratified samples, not full enumeration)

| directory | population | sampled | flagged INTERIOR_NODATA | note |
|---|---|---|---|---|
| Disturbance_run/alphaearth/conus/rd30m_tiles (RD30 CONUS main) | 24,544 | 60 | 0 | clean sample |
| Disturbance_run/alphaearth/conus/rd30m_qm_tiles (quality mask) | 24,544 | 60 | 0 | clean sample |
| Disturbance_run/alphaearth/conus/rd30m_cal_tiles (calibration) | 24,544 | 60 | 0 | clean sample |
| Disturbance_run/alphaearth/conus/rd30m_unc_tiles (uncertainty) | 24,544 | 60 | 34 | fraction runs 0.08 to 1.00, not uniform |
| canada_nfi/aef_tiles (Canada NFI, all provinces) | 1,499 | 60 | 0 | max 0.944, below threshold |
| canada/magplot/rd30m_tiles_ca (Canada RD30 mirror) | 0 | 0 | n/a | directory exists, currently empty |

Sample fraction against population is small (60 of 24,544 is 0.24 percent per RD30 layer), so the clean result for `rd30m_tiles`, `rd30m_qm_tiles`, and `rd30m_cal_tiles` is evidence of no defect in the sample, not proof the full 24,544-tile population is defect-free.

## Firewall table

| check | scope | this run | result |
|---|---|---|---|
| F1a: declared bbox vs filename jurisdiction | all named/prefixed files | inherited from 19 Aug sweep, not rerun | 14 NAME_EXTENT_MISMATCH carried forward, unchanged |
| F1b: interior nodata vs claimed jurisdiction (this probe) | 344 rasters, full declared extent | new | 36 INTERIOR_NODATA (2 whole-file voids, 34 rd30m_unc_tiles) |
| F1c: unprefixed-file coverage gap | 8 files with no na_/conus/canada prefix and no resolvable claim | extended | now measured and reported as OPEN rather than silently skipped |
| F1d: truncation disclosure | raster inventory completeness | self-corrected mid-run, see implementation notes | final run: 344 of 344 candidates in the sampling plan processed, 0 silently dropped |

## Unknowns ledger

Known unknown, needs Track D input: is `rd30m_unc_tiles` a finished deliverable or a known work in progress. The 8 to 100 percent gradient across sampled tiles looks like partial completion, not masking, but only the assembly job's own state can confirm that.

Known unknown, needs Track C input: `canada_nfi/aef_tiles/` holds files named `aef_<province>_2023_...tif`, not anything with "ESI" in the name. This report treated them as the Canadian ESI-adjacent surfaces per the task brief, but the naming does not confirm that identification. Worth a one-line reconciliation with whoever owns the ESI30 gate rerun.

Known unknown: `canada/magplot/rd30m_tiles_ca`, the directory structurally parallel to the CONUS RD30 tile set, exists but holds zero files. Either the Canada-side RD30 tiling has not started, or it lives somewhere else not yet discovered by this probe's watch list.

Discovered unknown, not anticipated before this run: the CONUS RD30 product is not one mosaic file, it is four parallel families of 24,544 tiles each (98,176 tiles total), an order of magnitude larger than the 44-file inventory the 19 August sweep covered. The original sweep's 80-raster cap would never have reached this population at all; it was scoped to the mosaic-and-composite layer, not the tile layer underneath it.

Unknown unknown risk, flagged rather than resolved: jurisdiction cells here are simple rectangles, not true province polygons, so cells overlap at borders (for example the Alberta and British Columbia boxes share edge territory). The two 100 percent, whole-file-void findings are robust to this imprecision because every jurisdiction cell in those files reads 100 percent nodata, not just a border one. The intermediate findings in the 60 to 90 percent range (Nunavut, Prince Edward Island) should not be read at province-boundary precision.

## Implementation notes

Deviation: the first submitted job (13958717) failed in 2 seconds because Cardinal has no dedicated GDAL Python-binding module, only a compiler-gated `gdal/3.7.3` C library. Diagnosed via `module spider gdal` and confirmed instead that `rasterio` 1.4.3 and `numpy` 1.25.2 are already installed in the user's own `~/.local` site-packages under system `/usr/bin/python3`, no module load required. The probe script was rewritten from `osgeo.gdal` to `rasterio` for this reason; this is a durable fact worth carrying into the `hpc-cardinal` or `firebreather` skill notes for future raster work on Cardinal.

Deviation and self-correction: the first successful run (13958780) set `MAX_FILES=140` and discovered 98,220 candidate rasters once the RD30 tile directories were found by the broad `find` scan, which would have silently processed only the first 140 in list order (the 44 known files plus 96 tiles from a single directory, not a representative geographic sample) and dropped 98,080 with a logged but easy-to-miss truncation line. Caught this via the `TILE_SUMMARY` log line before treating that run as final, cancelled the job, and rewrote the discovery step to take an evenly-spaced stratified sample of 60 tiles from any directory exceeding 300 files rather than truncating in listing order. The second run (13958852) completed cleanly with 0 files dropped from its sampling plan.

Deferred: did not fetch or read `f1_sweep.py` itself, the source of the 19 August sweep. Relied on its CSV output, `na_chain_f1_sweep_20260819.csv`, mirrored locally and matching the Cardinal copy by row count, as the authoritative record of what that sweep covered. This satisfies the instruction to use "the exact raster inventory the prior sweep covered" but means this report cannot independently confirm whether the 19 August sweep's own 80-raster cap silently dropped anything; that remains an open question about the prior sweep, not this one.

Known limitation: `v4_climate_33_1km.tif` carries an unusual CRS (`PROJCS["unknown", ...]`, EPSG:8807-adjacent) whose corner-to-WGS84 transform produces a bounding box that appears to cross the antimeridian (xmin 166.9, xmax -12.8). The probe's own sanity check did not catch the resulting negative-span case cleanly, so this file's claim was correctly assigned OPEN but its raw jurisdiction counts should be treated as unreliable, not as a clean result, pending a direct look at the file's actual CRS definition.

Cardinal connectivity: the osc-cardinal connector returned "Connection closed" on a majority of interactive calls throughout this session, consistent with contention from the two other Cardinal-touching tracks (RD30 assembly, ESI30 gate) running concurrently. Worked around per standing guidance by reissuing failed calls rather than raising timeouts, and by routing the actual raster sampling through `cardinal_submit_job` plus `cardinal_job_status` polling, which is far less exposed to the interactive-call stall than repeated `cardinal_run` calls would have been.

No rasters were deleted, moved, or modified on Cardinal. No FIA or NFI true coordinates appear anywhere in this report or its output CSV; all reported values are jurisdiction-level aggregates.

## Files

Full per-raster, per-jurisdiction results: `f1-interior-nodata-probe_DATA_2026-08-25.csv` (344 rows, alongside this memo). Probe script as actually run on Cardinal: `f1-interior-nodata-probe_FINAL_2026-08-25.py`. Cardinal-side outputs remain at `/fs/scratch/PUOM0008/crsfaaron/na_maps/f1_interior_nodata_probe_20260825.csv` and the accompanying `..._DISCOVERY_20260825.log`.
