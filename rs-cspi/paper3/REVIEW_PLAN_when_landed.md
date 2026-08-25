# Stress test, red-team, and next-steps protocol (run when the deliverables land)

*The specific, per-deliverable checks to run once the ESI refit, AlphaEarth microsite validation, and NA RD map plus figures complete. Actor-critic: one pass computes and stress-tests, a second independent pass red-teams the first, a third verifies numbers against source files. De-identified throughout; no true coordinate in any output.*

## Deliverables and their Cardinal paths

- True-coord RD/CSPI analysis: /fs/scratch/PUOM0008/crsfaaron/canada_nfi/analysis/ (done)
- ESI refit: /fs/scratch/PUOM0008/crsfaaron/canada_nfi/esi_refit/ (model card, blocked-CV CSVs, NFI predictions, importance)
- AlphaEarth microsite: /fs/scratch/PUOM0008/crsfaaron/canada_nfi/aef_analysis/
- NA RS-CSPI surface: /fs/scratch/PUOM0008/crsfaaron/na_maps/cspi/NA_RS_CSPI_2km.tif (done)
- NA RD hex surface: /fs/scratch/PUOM0008/crsfaaron/na_maps/rd/NA_RD_12km_hex.gpkg
- NA validation + figures: /fs/scratch/PUOM0008/crsfaaron/na_maps/{validation,figures}/

## ESI refit

Stress tests. Blocked R2 and RMSE of the expanded (climate+soils+terrain) model against the climate-only baseline on identical province and ecoregion holdouts; report the delta, not just the level. Confirm the Nova Scotia vs New Brunswick sign flip is resolved (both provinces same-sign, blocked R2 above the prior 0.46 to 0.55). Soils-coverage split: compare blocked performance on the soils_available=TRUE subset vs the boreal soils=NA subset, so the soils contribution is not masked by the coverage gap. Imputation sensitivity: refit with soils dropped entirely and confirm the terrain gain persists. Calibration ratio (observed vs predicted slope) near 1. Biological realism spot check: ESI should order known productive Acadian sites above boreal sites.

Red team. Is the gain real or spatial-autocorrelation leakage, are the CV blocks large enough that held-out plots are not within a variogram range of training plots. Are soils covariates informative or noise, check variable importance and the soils-subset delta. Does US soils=NA bias the CONUS side of the joint fit, and does that leak into Canadian prediction. Is the dominant-height SI response consistent in definition across the CONUS+Canada compilation (base age, top-height definition). Does terrain (TPI/TWI proxy) add signal or just overfit at true coordinates.

Next steps. Wire US gNATSGO/POLARIS soils for the CONUS training rows; add SLC v2.2 for boreal soils coverage; test an stLMM/NNGP spatial random-effect term against the ranger on the same folds; freeze the fitted object and feed it as the ESI component of the NA CSPI composite and as the FVS-ACD dominant-height driver.

## AlphaEarth 30 m microsite (NB pilot)

Stress tests. Blocked-CV R2 and RMSE of the 30 m AEF productivity model vs ground productivity (BA, top height, increment, NSBE AGB), contrasted directly against the coarse RS-CSPI and MODIS NPP plot-scale nulls from the true-coord analysis (the headline question: does fine resolution plus true coordinates recover a signal the coarse surfaces could not). Buffer sensitivity: single 10 m pixel vs 15 m mean. Precise-location check: NB is all true-coordinate (not BC-rounded), so no coord-quality confound, confirm.

Red team. Is NB representative or a favorable special case, flag before generalizing. Is the AEF-productivity link real productivity or land-cover/compositional confounding (AEF encodes cover, which correlates with but is not productivity). Year mismatch: AEF 2023 vs plot measurement years, quantify the temporal offset distribution. Spatial-block leakage as above. Is 30 m the right grain or does the signal only appear under aggregation.

Next steps. If the pilot shows signal, scale the export to the remaining provinces (one config change), build wall-to-wall Canada 30 m RD from the RS-to-RD model on the AEF tiles, and mosaic with CONUS 30 m to upgrade the NA RD map; if the pilot is null, that is itself the paper result (fine-scale RS is still productivity-orthogonal even at true coordinates).

## NA RD and CSPI maps

Stress tests. Seam continuity: residuals of plots within 100 km of 49 N, CONUS side vs Canada side, should show no step. Cross-calibration stability: refit the CONUS-into-Canada linear map on a held-out half of the overlap and confirm coefficients are stable. NA RD hex uncertainty: fraction of hexes below a usable plot count, and the per-hex 90 percent CI distribution. Blocked validation by region from na_validation.

Red team. Is the CSPI cross-calibration units-mixing defensible, or does it paper over two different constructs (CONUS 5-component composite vs Canada single RS-NPP surface), state the interpretation limit plainly. [Annotated 25 August 2026, per cspi-component-count-reconciliation_FINAL_2026-08-19.md: the CONUS product of record is the three-component composite z(ESI) + z(BGI) + z(Asym), and the five-component surface is an experimental v2both-line artifact, so this units-mixing question should be posed against the three-component product.] Given the plot-scale CSPI null, what does the continental CSPI map actually represent (a climate-flux gradient, not plot productivity), make sure the caption says so. Canada RD 12 km hex: is the SAE gamma shrink honest, and is boreal RD extrapolated beyond the plot support. 

Next steps. Build the NA CSPI composite once the refit ESI and a Canada BGI raster exist, with Canada Asym flagged pending; upgrade RD to 30 m when the AEF wall-to-wall lands; finalize the two manuscript map figures with the calibrated-error insets; reconcile shared numbers across the RD and CSPI paper lines in a shared-numbers ledger.

## Verification pass

Independently re-read every headline number from its source CSV on Cardinal (do not trust the first pass summary), confirm no output file carries a coordinate column, confirm the RD stocking-control and fuzzing-cost numbers match TRUECOORD_RESULTS_2026-07-21.md, and list any number that does not reconcile.

## Output

Write STRESS_TEST_REDTEAM_REPORT_<date>.md to active-projects/bgi-cspi-conus/v5/ with three sections (stress-test results table, red-team findings ranked by severity, prioritized next steps), plus a one-paragraph go / no-go on whether each deliverable is manuscript-ready.
