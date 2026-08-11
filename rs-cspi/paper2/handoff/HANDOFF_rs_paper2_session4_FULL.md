# CSPI Paper 2 (RS-CSPI) full handoff: session 4
## 23 June 2026

## Status in one line

The FIA-independent Remote Sensing Composite Site Productivity Index is built end to end at 1 km and 30 m CONUS, published on Zenodo with a minted DOI, committed to GitHub under CAFS, and drafted as a manuscript. A short punch list of refinements remains.

## Published dataset (DOI minted this session)

- **Version DOI: 10.5281/zenodo.20827437** (CSPI v4.0.0)
- **Concept DOI: 10.5281/zenodo.20827436**
- Record: https://zenodo.org/record/20827437
- Contents (23 files): RS-CSPI 1 km equal-weight and PC1 composites; 1 km agreement layer; SAE-refined (FIA-localized) 1 km surface; **30 m CONUS consensus, 18.5 GB COG**; 4.6 km companion; Smokies 30 m pilot; trained models (npp, agbd, chg; predictor_names); OOB and blocked-CV tables; per-L1 and cross-target tables; MODIS NPP interannual stability layer; Sentinel-2 NDVI; analysis scripts; README, CITATION, data dictionary.
- Note: the publish stalled on a model upload via the bundled script; recovered by uploading the missing files to the existing draft and publishing via the API directly. The m_cms16 model and the GPP/NDVI models did not make it in (path slip / hang); add them in v4.1.0.

## GitHub (under CAFS = advanced-forestry-systems)

- PR #2 on advanced-forestry-systems/cspi-conus, branch feature/rs-cspi-v4, subdir rs-cspi/ (code, manuscript, analyses, figures, Zenodo metadata; large rasters excluded).
- Token lacks Administration, so a standalone advanced-forestry-systems/cspi-rs-conus repo could not be created. To split it out, grant Administration on the holoros fine-grained PAT (or create the empty repo in the web UI) and push the local repo at active-projects/cspi-rs-paper.
- The DOI backfill (README + manuscript) is committed locally; push it to the PR branch next session (or now if a session is open).

## The science, with numbers

Design: remote sensing productivity metrics are the response (Y); a 43-variable wall-to-wall stack (ClimateNA + aligned terrain, soil, canopy) is the predictor (X). No FIA in the modeling chain. Fitted per target, predicted across all forested cells, combined into the RS-CSPI.

Per-target OOB R2 (augmented 1 km): NPP 0.948, GPP 0.965, GEDI AGBD 0.791, CMS biomass 0.894, CMS change 0.602, Sentinel-2 NDVI 0.815.
Wall-to-wall beats the FIA plot frame on every target (e.g. biomass 0.57 to 0.93).
Spatially blocked CV (the headline, conservative): NPP 0.858, biomass 0.862, AGBD 0.748, change 0.485.
Composite: PC1 explains 69 percent of variance across the three level targets; equal-weight and PC1 nearly identical (r 0.995).
Independence from site index: pooled Pearson -0.12 (level composite) and -0.39 (with change), positive within region; confirmed at the plot level (site index vs NPP -0.38, vs GPP -0.42). Height-versus-flux divergence, as in the FEM paper.
Microsite: 1 km to 30 m captures ~32 percent of variance (sub-1 km microsite); 30 m to 10 m adds only 1.3 percent. 30 m is the resolution sweet spot.
SAE refinement: adding a spatial small-area term lifts blocked prediction of a ground growth index from 0.71 to 0.94 and of biomass asymptote from 0.15 to 0.75.

## Manuscript

Draft at paper2/manuscript/RS_CSPI_manuscript_draft_v0_2.md, framed as "beyond site index": site index is the limitation (plot-bound, single height dimension, too coarse for microsite); the RS-CSPI is the integrated, microsite-resolving, FIA-independent replacement for driving G&Y and management. Voice pass done; provisional reference list added (needs CrossRef verification). DOI now backfilled.

## Punch list for next session (v4.1.0 + submission prep)

1. Per-pixel uncertainty layer: the quantile-RF job OOM'd at 96 GB on the predict step. Rerun with chunked quantile prediction (predict in 1 to 2 M cell blocks), then add RS_CSPI_uncertainty_1km.tif to a v4.1.0 new version.
2. Add the missing models to v4.1.0: m_cms16_aug.rds (at wtw1km_aug/), m_gpp_aug.rds, m_ndvi_aug.rds (at cspi_rebuild/). Use new_version.py against concept DOI 10.5281/zenodo.20827436 so the 18 GB COG is inherited, not re-uploaded.
3. Predict wall-to-wall GPP and NDVI surfaces (models exist) and build a flux-broadened consensus; compare to the 3-target RS-CSPI as a robustness check.
4. Full SAE surface national rollout with its own uncertainty (the prototype and the asym surface are done; productionize).
5. Manuscript: CrossRef-verify every reference (citation-integrity protocol), run the writing-quality script, build the submission docx, fold in the 10 m sweet-spot, GPP, NDVI, temporal-stability, and SAE results, and add the temporal stability and uncertainty figures.
6. Render: the colored 30 m CONUS map job (render30, gdalwarp 500 m downsample) was submitted; confirm it produced WTW_consensus_30m_CONUS_colored.png and pull it.
7. Push the DOI-backfill commit to PR #2.

## Key paths (Cardinal)

- Surfaces and models: /fs/scratch/PUOM0008/crsfaaron/rs_target/{cspi_rebuild,wtw,wtw30m,wtw1km_aug}
- 30 m CONUS COG: /fs/scratch/PUOM0008/crsfaaron/rs_target/wtw30m/WTW_consensus_z_30m_CONUS.tif
- Zenodo staging: /users/PUOM0008/crsfaaron/zenodo_staging/v4_surfaces
- Predictors: ClimateNA at SiteIndex/rasters/ClimateNA; aligned terrain/soil/canopy at cspi_v3/aligned_1km and aligned_30m; forest mask cspi_rs/CSPI_V3_CONUS_1km_forest.tif

## Acquisition fixes locked in

GEDI L4B: collection GEDI_L4B_Gridded_Biomass_V2_1_2299, Bearer-header auth. NASA-CMS: CMS_CONUS_Biomass_1752. MODIS NPP/GPP and NPP interannual CV: GEE getDownloadURL single-shot (small collections, one export at a time for Restricted Mode). Sentinel-2: tile into longitude strips (full-CONUS composite times out); 8 strips mosaic to S2_NDVI_conus_5km.tif.

## Policy (unchanged)

Cardinal deletions prohibited from autopilot. Tokens (Zenodo ~/.zenodo_token, Earthdata netrc JWT, GitHub PAT) never echoed; Bearer header. Funding CRSF only. R first, no decorative hyphens. The FEM v0.10q manuscript remains untouched.
