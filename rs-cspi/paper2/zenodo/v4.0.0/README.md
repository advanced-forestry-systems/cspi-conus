# FIA-independent wall-to-wall multi-target forest productivity consensus for the conterminous United States (CSPI v4.0.0)

A forest productivity surface for the conterminous United States derived entirely from remote sensing and environmental predictors, with no ground inventory data anywhere in the modeling chain. Every forested cell on an environmental predictor grid is paired with co-registered wall-to-wall satellite productivity targets; a random forest is fit from the predictors to each target and predicted across all forest cells; the predicted surfaces are z-standardised and averaged into an equal-weight consensus index, with a per-cell agreement layer.

This release supersedes the FIA-target CSPI surfaces (v3.0.0, DOI 10.5281/zenodo.20763197) by removing the dependence on FIA inventory plots.

## Targets (all wall to wall remote sensing)

- MODIS MOD17 net primary productivity (flux)
- GEDI L4B v2.1 aboveground biomass density (structure)
- NASA-CMS CONUS aboveground biomass 2016 (structure)
- NASA-CMS aboveground biomass change 2005 to 2016 (change)

## Predictors

ClimateNA 1991-2020 normals (32 variables, about 1 km, elevation-adjusted) plus aligned terrain (elevation, slope, aspect), soil (bulk density, CEC, nitrogen, pH, sand, soil organic carbon), and canopy (Hansen tree cover 2000 and loss). 43 predictors total. The predictor grain caps resolution; the climate layers are the limiting factor.

## Primary product: augmented 1 km

The recommended surface is the 1 km augmented consensus. Adding terrain, soil, and canopy to the climate stack recovers the structural fit that climate alone cannot explain.

| Target | OOB R² (1 km augmented) |
|---|---|
| MODIS NPP | 0.948 |
| GEDI AGBD | 0.791 |
| CMS AGB 2016 | 0.894 |
| CMS AGB change | 0.602 |

A coarser 4.6 km companion (water-balance predictor stack) is included for reference; it has slightly higher structural R² because that stack carried water balance and coastal predictors, but it is blockier.

## Files

Surfaces (GeoTIFF, EPSG:4326):
- `WTW_consensus_productivity_idx_1km_aug.tif` — primary 1 km consensus productivity index (0 to 100)
- `WTW_consensus_agreement_sd_1km_aug.tif` — 1 km per-cell agreement (SD of z predictions; low = targets agree)
- `WTW_consensus_productivity_idx_4p6km.tif`, `WTW_consensus_agreement_sd_4p6km.tif` — 4.6 km companion

Models (R, readRDS): `m_npp_aug.rds`, `m_agbd_aug.rds`, `m_cms16_aug.rds`, `m_chg_aug.rds`, plus `predictor_names.rds` (the 43 predictor names and order).

Tables: `WTW1kmAUG_oob_summary.csv`, `WTW1km_oob_summary.csv`, `WTW1_oob_summary.csv` (per-build out-of-bag performance); `WTW2_cell_predictions.csv` (4.6 km per-cell predictions).

Validation analysis bundle (the supporting FIA-plot-frame validation): per-target OOB tables, variable importance, cross-target correlation, per-ecoregion residuals, and the analysis scripts. See `analyses/`.

## 30 m CONUS surface and microsite variability

The full conterminous 30 m consensus (`WTW_consensus_z_30m_CONUS.tif`, 18 GB cloud-optimized GeoTIFF) is included, built by tiling the same models over the aligned 30 m terrain, soil, and canopy stack with ClimateNA resampled to 30 m. It resolves microsite productivity that coarse measures discard: in dissected terrain about 32 percent of total productivity variance is at the sub-kilometer microsite scale, recovered by the 30 m surface and invisible to a plot or 1 km measure.

## Validation

Spatially blocked cross-validation (1 degree blocks, 5 folds) on the 1 km augmented fits: NPP 0.858, CMS biomass 0.862, GEDI AGBD 0.748, CMS change 0.485 (blocked R squared), versus out-of-bag 0.948, 0.894, 0.791, 0.602. Report blocked values as the headline, OOB as the upper bound (`WTW1kmAUG_blocked_cv.csv`).

## Composite construction and the SAE-refined surface

The RS-CSPI combines the three productivity-level targets (NPP, GEDI AGBD, CMS biomass); the biomass change rate is excluded as a flux. The first principal component explains 69 percent of the variance across the three standardized targets and the equal-weight and PC1 composites are nearly identical (correlation 0.995). `SAE_refined_asym_1km.tif` is an optional FIA-localized refinement: the RS-CSPI plus a spatial small-area smooth fit to FIA biomass-asymptote productivity, demonstrating that inventory plots can localize the independent surface where they exist (blocked prediction of a ground growth index rises from 0.71 to 0.94 with the spatial term).

## Caveats

- Resolution is set by the predictors. The 1 km surface carries genuine terrain-driven detail; the 30 m surface is a terrain and canopy driven downscaling of 500 m to 1 km productivity targets, not new 30 m productivity signal.
- Out-of-bag R² on a dense grid is optimistic due to spatial autocorrelation. A spatially blocked cross-validation (1 degree blocks, 5 folds) gives the conservative number, and the surface holds up: NPP 0.858, CMS biomass 0.862, GEDI AGBD 0.748, CMS change 0.485 (blocked R²), versus OOB 0.948, 0.894, 0.791, 0.602. Report the blocked values as the headline and OOB as the upper bound. Full table in `WTW1kmAUG_blocked_cv.csv`.
- Fitting target to environment and predicting back is an environmentally smoothed reconstruction of the RS surface. Its value is gap filling, a single consistent surface across four targets, attribution to drivers, and the cross-target agreement layer.

## Citation

See `CITATION.cff`. Please cite this record and the related v3.0.0 dataset (DOI 10.5281/zenodo.20763197). Computation on the Ohio Supercomputer Center Cardinal cluster, allocation PUOM0008. Funding: University of Maine Center for Research on Sustainable Forests. License: CC-BY-4.0.
