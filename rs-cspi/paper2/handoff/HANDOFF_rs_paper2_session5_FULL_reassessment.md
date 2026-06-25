# CSPI Paper 2 (RS-CSPI) full handoff and reassessment: session 5
## 23 June 2026. Supersedes session 4.

## Reassessment in one paragraph

The FIA-independent RS-CSPI is built, published (DOI 10.5281/zenodo.20827437), committed under CAFS (PR #2), and drafted. A red-team stress test plus hardening analyses then changed what we can honestly claim. The construct survives and gains a real independent validation (AmeriFlux r = 0.66, 95 percent CI [0.35, 0.85]), but three claims were corrected: the wall-to-wall design buys coverage and a structural-target gain, not a uniform predictability boost (fair blocked CV: NPP equal to the plot frame, AGBD better); the small-area refinement is inventory spatial interpolation, not the RS layer doing the work; and the index predicts FIA structural productivity weakly (bgi R2 0.25, asym 0.05, site index negative), so it is a complementary independent flux-and-biomass productivity axis, not a drop-in site-index replacement or calibrated growth-and-yield driver. The manuscript and the deposit description have been tempered to match. This is a more defensible and still novel paper.

## Where the science honestly stands

Strengths that hold:
- Genuinely FIA-independent design (RS as response, environment as predictor), wall to wall, repeatable.
- Independent validation against flux towers: composite r = 0.66 [0.35, 0.85]; structural surfaces 0.60 to 0.63; the circular MODIS-NPP surface only 0.24, which is itself a clean diagnostic.
- 30 m resolution is the sweet spot (10 m adds only 1.3 percent variance; 1 km to 30 m captures about 32 percent microsite variance).
- Height-versus-flux divergence from site index, confirmed in surfaces and plots, consistent with the FEM multi-dimensional thesis.
- Non-climate predictors carry the signal (NPP 0.81, AGBD 0.61 from terrain/soil/canopy alone), so the result is not a pure climate-circularity artifact.

Honest limits, now in the manuscript:
- MODIS NPP is partly climate-circular; lean on the structural targets.
- Wall-to-wall OOB was autocorrelation-inflated; all headline numbers are blocked CV.
- SAE gain is inventory interpolation; RS contributes coverage, not interpolation skill.
- The index is unitless and weakly tied to FIA productivity; not yet a G&Y driver. Calibration to remeasured increment is the path.
- Microsite variance is predictor-driven, not independently validated at fine scale.

## Published and committed

- Zenodo v4.0.0: DOI 10.5281/zenodo.20827437, concept 10.5281/zenodo.20827436, https://zenodo.org/record/20827437. 23 files incl. 18.5 GB 30 m COG, 1 km RS-CSPI (equal-weight + PC1), SAE-refined surface, 4.6 km companion, Smokies pilot, models (npp, agbd, chg), tables, temporal stability layer, Sentinel-2 NDVI, scripts.
- GitHub: advanced-forestry-systems/cspi-conus PR #2, branch feature/rs-cspi-v4, subdir rs-cspi/. Latest commit has the red-team docs, hardening results, tempered manuscript, backfilled DOI.
- Manuscript: paper2/manuscript/RS_CSPI_manuscript_draft_v0_2.md (hardened, tempered) and RS_CSPI_manuscript_v0_2.docx (pandoc build).
- Key memos: REDTEAM_stress_test.md, RESULTS_redteam_hardening.md, RESULTS_comparison_vs_FIA.md, RESULTS_resolution_1km_and_30m.md, RESULTS_augmented_1km_and_30m_pilot.md.

## In flight at handoff

- Per-pixel uncertainty layer (chunked quantile RF, job rs_unc2 12003832) running; writes RS_CSPI_uncertainty_1km.tif.
- v4.1.0 publish script staged at rs_target/zenodo_v410.py: when the uncertainty tif exists, run it to publish v4.1.0 as a new version of concept 10.5281/zenodo.20827436 (inherits the 18 GB COG; adds uncertainty + m_cms16, m_gpp, m_ndvi models). One command: python3 zenodo_v410.py.

## Punch list (priority order)

1. Run zenodo_v410.py once the uncertainty layer finishes (adds uncertainty + missing models as v4.1.0).
2. Predict wall-to-wall GPP and NDVI surfaces (models exist) and report a flux-broadened consensus vs the 3-target RS-CSPI.
3. Calibration to physical units: this is the gating science question for the G&Y framing. Use remeasured FIA increment (not the fuzzed single-measurement asym/bgi) as the response; the plot-level calibration was weak partly due to coordinate fuzzing, so test at coarser aggregation or with the unfuzzed plot coordinates if available.
4. Manuscript: CrossRef-verify every reference (none verified yet), run the writing-quality anti-AI-tell script, finalize the docx with the validation figure (AmeriFlux scatter) and the corrected claims, choose target journal (RSE or FEM).
5. Expand the independent validation beyond 29 AmeriFlux sites (the CI is wide).
6. Redo the colored 30 m CONUS map (the gdalwarp-average render came out sparse; use gdal_translate decimation like the grayscale overview, which was correct).
7. Push the latest manuscript and docx to PR #2; consider splitting into a standalone advanced-forestry-systems/cspi-rs-conus repo once Administration is on the token.

## Key paths and fixes (unchanged)

Cardinal: surfaces and models in rs_target/{cspi_rebuild,wtw,wtw30m,wtw1km_aug}; 18 GB COG at wtw30m/WTW_consensus_z_30m_CONUS.tif; Zenodo staging at /users/PUOM0008/crsfaaron/zenodo_staging/v4_surfaces. Predictors: ClimateNA at SiteIndex/rasters/ClimateNA; aligned terrain/soil/canopy at cspi_v3/aligned_{1km,30m}; forest mask cspi_rs/CSPI_V3_CONUS_1km_forest.tif; AmeriFlux at v3.1_analyses/ameriflux_us_forest_sites.csv.
Acquisition: GEDI L4B collection GEDI_L4B_Gridded_Biomass_V2_1_2299, Bearer header; NASA-CMS CMS_CONUS_Biomass_1752; MODIS via GEE getDownloadURL one-shot; Sentinel-2 via longitude-strip tiling.
Zenodo via API works (Bearer header); the bundled uploader can stall on large model files, so the API recover/new-version path in zenodo_v410.py and zenodo_recover_publish.py is the reliable route.

## Policy (unchanged)

Cardinal deletions prohibited from autopilot. Tokens never echoed; Bearer header. Funding CRSF only. R first, no decorative hyphens. FEM v0.10q manuscript untouched.
