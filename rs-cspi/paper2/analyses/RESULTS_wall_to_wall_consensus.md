# Wall to wall, FIA free multi-target productivity consensus: results

*23 June 2026. The corrected design: drop the FIA plot frame entirely. Sample every forested cell on the environmental predictor grid, read each wall to wall remote sensing productivity target at that cell, fit environment to target, predict every forest cell, and average z standardised predictions into a consensus surface with a per cell agreement layer. No ground data enters the chain.*

## Design

- Grid: the climate to water environmental predictor stack at 0.0417 degrees (about 4.6 km), EPSG:4326. This grain is the honest resolution because the climate layers cap it; the productivity targets are finer but the predictors are not, so the consistent footprint the analysis requires is 4.6 km.
- Forest domain: 249,988 forested cells (CSPI v3 1 km forest mask resampled to the env grid); 200,487 with complete predictors.
- Predictors: 11 continuous env layers (water balance AET, DEF, PET, AI, RATIO, WD; SRAD; VPD; WIND; NDEP; distance to coast). Parent material dropped because the H4 test showed it adds under 0.01 R squared and it is the only 30 m layer.
- Targets, all wall to wall: MODIS NPP (GEE export), GEDI L4B AGBD, NASA-CMS biomass 2016, NASA-CMS biomass change 2005 to 2016.
- Models: ranger 300 trees, env to target, trained on up to 200,000 forest cells per target, predicted across all forest cells.

## Headline: gridded sampling beats the FIA plot frame on every target

| Target | OOB R² wall to wall | OOB R² FIA plot frame | gain |
|---|---|---|---|
| MODIS NPP | **0.953** | 0.919 | +0.034 |
| GEDI L4B AGBD | **0.873** | 0.743 | +0.130 |
| NASA-CMS AGB 2016 | **0.928** | 0.574 | +0.354 |
| NASA-CMS AGB change | **0.790** | 0.512 | +0.278 |

This is the central methodological result and it confirms the premise of the redesign. Pairing a co registered gridded productivity target with the environmental predictors at the same footprint predicts far better than sampling those same targets at sparse, fuzzed FIA plot coordinates. The structural targets gain the most (AGBD +0.13, biomass +0.35, change +0.28) because they suffered most from FIA plot noise and coordinate fuzzing; NPP, already smooth, gains least. The FIA plot frame was adding noise, not signal.

## Products (Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/wtw/`)

- `WTW_consensus_productivity_idx_4p6km.tif` — equal weight consensus of the four z standardised predicted surfaces, rescaled to a 0 to 100 index. The FIA independent CONUS forest productivity surface.
- `WTW_consensus_agreement_sd_4p6km.tif` — per cell standard deviation across the four z surfaces. Low where the targets agree, high where they diverge. The honest uncertainty layer for the consensus.
- `WTW_pred_{npp,agbd,cms16,chg}_4p6km.tif` — the four single target predicted surfaces.
- `WTW1_oob_summary.csv`, `WTW2_cell_predictions.csv` — fit summary and per cell predictions.
- Maps: `WTW_F1_consensus_map.png`, `WTW_F2_agreement_map.png`.

## Reading the consensus map

The consensus productivity gradient is geographically coherent: high in the Pacific Northwest coast, the Southeast coastal plain, and the Northeast; low through the arid interior West and the Rockies. The forest mask correctly excludes the Great Plains and the deserts.

## Honest caveats

- Resolution is 4.6 km, set by the climate predictors, not the targets. A finer surface requires a finer climate to water predictor stack, which is a separate effort. The targets and forest mask are 1 km; the model cannot resolve sub 4.6 km variation, so the surface is effectively 4.6 km displayed.
- Fitting target to environment and predicting back is an environmentally smoothed reconstruction of the RS surface. Its value over the raw RS rasters is gap filling, a single consistent surface across four targets, attribution to drivers, and the cross target agreement layer.
- GPP was not added this run (GEE concurrency limit on the second export); NPP represents the flux dimension. Canopy height and Sentinel-2 greenness remain as future targets.
- High OOB R squared partly reflects strong spatial autocorrelation on a dense grid; a spatially blocked CV would give a more conservative number and is the recommended next validation.
