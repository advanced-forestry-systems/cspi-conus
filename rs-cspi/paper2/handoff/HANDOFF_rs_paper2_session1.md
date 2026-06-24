# CSPI Paper 2 (RS-target) handoff: session 1
## 23 June 2026, extended autopilot

## What this session did

Launched the FIA-independent RS-target project (the follow-on to the v3.0.0 FEM paper) and executed Tracks 1 to 4 of the plan in `HANDOFF_NEW_PROJECT_rs_target_paper.md`. Six satellite targets are now fit against the v3 environmental stack at the FIA plot frame, with cross-target agreement and per-ecoregion bias computed. Full results in `paper2/analyses/RESULTS_rs_multitarget_session1.md`; paper scaffold in `paper2/manuscript/methods_results_outline.md`.

## State

| Track | Status |
|---|---|
| T1 acquisition | GEDI L4B v2.1 and NASA-CMS CONUS biomass downloaded; MODIS NPP/GPP and canopy height already at plots; Sentinel-2 blocked (see below) |
| T2 per-target fits | Done, 6 targets |
| T3 cross-target agreement | Done at plot level; 30 m surface CV still to do |
| T4 ecoregion stratification | Done, per-L1 across all targets |

## Headline numbers

OOB R² (v3 stack): NPP 0.919, GPP 0.886, GEDI AGBD 0.743, CMS AGB-2016 0.574, CMS AGB-change 0.512, canopy height 0.480. Asym v9 FIA-target reference was 0.836. Flux targets beat the FIA benchmark; structural targets fall below it. Cross-target Pearson r: flux pair 0.85, structural mean 0.63, flux-vs-structure 0.41. Per-L1 bias geography matches §3.23 across all six targets.

## The two acquisition fixes (so they are not re-derived)

1. **GEDI L4B v2.1.** Correct CMR collection is `GEDI_L4B_Gridded_Biomass_V2_1_2299` (concept id C2792577683-ORNL_CLOUD), not the names tried earlier. Data files: `GEDI04_B_MW019MW223_02_002_02_R01000M_{MU,SE,...}.tif` under `https://data.ornldaac.earthdata.nasa.gov/protected/gedi/GEDI_L4B_Gridded_Biomass_V2_1/data/`. ORNL DAAC protected store rejects netrc basic auth (the netrc password field holds an EDL JWT, not a password); download with `Authorization: Bearer <token>` and `--location-trusted`. Files on Cardinal at `rs_target/gedi_l4b/`.
2. **NASA-CMS CONUS biomass.** Collection `CMS_CONUS_Biomass_1752` (C2389289428-ORNL_CLOUD). `CONUS_agb_{2005,2010,2015,2016}_v1.tif` plus bgb, dead, soil-carbon, litter layers. Same Bearer-token download. Files on Cardinal at `rs_target/cms_conus/`. Confirm physical units from the product user guide before reporting RMSE.

## Sentinel-2 (the one open acquisition)

GEE service account authenticates fine (`~/.config/earthengine/service_account.json`, project sae-followon; S2_SR_HARMONIZED returns 71,442 CONUS growing-season scenes). Interactive `reduceRegions` over the plot points hits "user memory limit exceeded" even at 500-point chunks, scale 30, tileScale 16, single growing season. The mean composite over a large image collection reduced per point is too heavy for synchronous getInfo. **Fix:** submit an async `Export.table.toDrive` with the NDVI/EVI growing-season composite and the plot FeatureCollection, let GEE batch it, then download the table from Drive. Script staged at `rs_target/s2_ndvi_extract.py` (chunked getInfo version, needs converting to Export). Lowest-priority target since NDVI is most collinear with the NPP/GPP flux targets already in hand.

## Next session

1. Convert the Sentinel-2 extraction to `Export.table.toDrive`; land the NDVI/EVI target and add a 7th fit.
2. Isolated parent-material ΔR² per target (drop-one-predictor) to test H4 cleanly.
3. Surface step: predict each target at 30 m CONUS using the same predictor rasters as the Asym v9 surface (`/users/PUOM0008/crsfaaron/raster_layers/asym_v9/ASYM_V9_CONUS_30m.tif` is the reference grid), then compute the true per-pixel cross-target CV and the equal-weight consensus surface for v4.0.0.
4. Build F1 to F3 (OOB R² bar, cross-target heatmap, per-L1 residual panel) via the advanced-viz / r-analysis skills.
5. Draft the Introduction and fold the Methods/Results outline into a full draft.

## Cardinal jobs this session

11961552 multitarget fit (gpp, ch) COMPLETED; 11961741 GEDI AGBD fit COMPLETED; 11961932 CMS download+fit COMPLETED; 11962453 ecoregion FAILED then 11962771 COMPLETED (column-name fix); 11962852 cross-target FAILED then 11962881 COMPLETED (duplicate-ID fix). Scripts archived in `paper2/cardinal_scripts/`.

## Security / policy (unchanged)

File deletions on Cardinal prohibited from autopilot (provide rm as text only). Earthdata token lives in `~/.netrc` password field; pass as Bearer header, never echo to stdout, never in URL query params. Zenodo token at `~/.zenodo_token` mode 600. GitHub PAT scoped to advanced-forestry-systems. Funding: CRSF only (no MAFES/McIntire-Stennis). Style: retain past knowledge, R first then Python, no hyphens in prose.

## Note on the FEM paper

This RS-target work is the standalone follow-on. The FEM manuscript stays at v0.10q and was not touched this session. Note: the FEM line has two parallel versions (full v0.10q combined and condensed v0.11 single-paper); the intended submission version is still open. This RS-CSPI paper is single-author.
