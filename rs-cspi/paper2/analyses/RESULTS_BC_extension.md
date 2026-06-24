# British Columbia extension and the BC PSPL comparison

*23 June 2026. Following the BC Provincial Site Productivity Layer (PSPL) as a comparator.*

## What was done

1. Manuscript: the BC PSPL is now the operational comparator in the Introduction (a classification- and mapping-intensive site-index product that motivates an inventory-free RS alternative) and the Discussion (the RS-CSPI is the biophysical gap-fill BC uses, done everywhere and without ecosystem polygons). Single-author throughout.

2. Transferability: the RS-CSPI was extended to British Columbia. ClimateNA covers BC, so climate-only models for the globally available targets (MODIS NPP, OOB 0.90; GEDI AGBD, OOB 0.65) were trained on the CONUS plot frame and predicted over a 1 km BC grid (2.03 million cells). The result is a plausible BC productivity gradient: high along the wet coast (Vancouver Island, coastal mainland), low through the cold interior and north. Surface at `bc/BC_RS_CSPI_climate_1km.tif`, map `bc/BC_RS_CSPI_map.png`.

## Honest caveats on the BC surface

This is exploratory, not a validated BC product. It extrapolates CONUS-trained models beyond their climate envelope (BC is colder and wetter than most of CONUS, with different species), uses climate predictors only (no BC terrain, soil, or canopy stack assembled), drops the CONUS-only CMS biomass target, and has no land or forest mask applied. It demonstrates that the method transfers and produces a sensible gradient; it is not calibrated or validated for BC.

## Benchmark against BC VRI ground data (now run; data provided)

The BC PSP data turned out to be the VRI ground-sample database (3,220 cluster plots, 14,336 top-height trees with measured site index, compiled stand basal area and volume). Benchmarking the CONUS-trained RS-CSPI transfer surface against 2,485 VRI clusters with coordinates:

| comparison | Pearson | Spearman |
|---|---|---|
| RS-CSPI vs measured site index (SI_TREE) | -0.02 | -0.06 |
| RS-CSPI vs stand basal area (m2/ha) | 0.15 | 0.11 |
| RS-CSPI vs net volume | 0.16 | 0.12 |

Two readings, both honest. First, the near-zero correlation with measured site index confirms the height-versus-flux divergence in a second jurisdiction with independent ground data: the RS-CSPI is orthogonal to height-based site index in BC just as in CONUS. Second, and more cautionary, the weak correlation with standing basal area and volume (0.15 to 0.16) shows that a CONUS-trained surface does not transfer well to BC. The likely cause is extrapolation: BC's coastal temperate rainforest and boreal interior climates and species lie well outside the CONUS training envelope, and the climate-only model has no BC ground data to anchor it. The transferability lesson is clear: the RS-as-response method is portable, but the surface must be trained within each jurisdiction; a CONUS surface should not be applied to BC off the shelf.

## BC-native model: trained inside BC, validated on held-out plots (the null)

The obvious next move was to stop transferring CONUS models and train inside BC. At the 2,485 VRI clusters I extracted ClimateNA (32 normals), MODIS NPP, and GEDI AGBD, then ran three tests. The result is a clean null, and it is the most informative outcome of the whole BC arc.

(A) Environment to VRI productivity, BC-trained, held-out spatial CV: site index R2 = -0.01, basal area 0.03, volume 0.03. To rule out a spatial-extrapolation artifact I re-ran with random (non-spatial) 5-fold CV and with in-sample OOB; both are also negative (site index random-CV -0.07, OOB -0.05; basal area -0.03, -0.02). So this is a true null, not a cross-block transfer failure: 1 km climate does not predict BC plot-level measured productivity at all, even fitting and scoring on the same plots.

(B) RS targets observed at BC plots versus VRI ground (Pearson): MODIS NPP vs site index -0.01, vs basal area 0.12, vs volume 0.12; GEDI AGBD vs all three weakly negative (-0.08 to -0.09). The flux target weakly tracks standing volume and basal area; nothing tracks site index.

(C) BC-native RS-CSPI (env to RS targets, trained and held out in BC), versus VRI ground: site index -0.01, basal area 0.01, volume 0.01. Building the composite inside BC does not help, because its ingredients (A and B) carry almost no plot-level signal.

The honest reading has two parts. First, this is a genuine vindication of the microsite premise, now shown against fully independent ground data: BC plot-level site index is dominated by species identity and stand-level factors that 1 km climate cannot resolve, so coarse environment predicts essentially none of it. Second, it is a real caution for the manuscript. The CONUS result that environment predicts FIA site index at R2 about 0.60 used the modelled, condition-level SICOND, which carries spatial structure; the BC test uses raw per-tree, species-specific site index averaged per cluster, which does not. The contrast suggests the CONUS 0.60 reflects in part the smoothed nature of SICOND rather than true plot-level predictability, and that should be stated plainly.

Net: the RS-CSPI is a regional flux and biomass productivity descriptor at 1 km, not a plot-level ground-productivity predictor, and a second jurisdiction with independent ground data confirms it. Results in `bc/BCN_A_env_to_vri.csv`, `bc/BCN_B_rstargets_vs_vri.csv`, `bc/BCN_C_bccspi_vs_vri.csv`.

## Where a real BC product would have to come from

Plot-level BC productivity needs predictors at the scale the variance lives: 30 m terrain (slope, aspect, curvature, topographic wetness from a BC DEM), soil, and canopy or spectral covariates, with species carried explicitly rather than averaged away. ClimateNA alone is the wrong grain for this target. The VRI database is extracted to `bc_vri/` and on Cardinal for that work.

## The PSPL raster (separate, still blocked on data)

The head-to-head against the BC PSPL could not be run on autopilot. The PSPL is distributed by Timber Supply Area through an ArcGIS web app or a BC Geographic Warehouse order; the data catalogue page is JavaScript-rendered and the CKAN API returned nothing usable. Obtaining the PSPL needs either a manual download of one or more TSAs, a BCGW order, or driving a browser through the Site Productivity Data Locator app.

## To complete the benchmark (next session)

1. Acquire the PSPL (one TSA or the provincial layer) as raster or polygon site index by species.
2. For a fair test, train BC-specific models on BC ground data or restrict to the climate overlap, rather than extrapolating CONUS models; and assemble a BC terrain/soil/canopy stack (SRTM, SoilGrids, Hansen are global) for the augmented predictors.
3. Compare RS-CSPI to PSPL site index by scale-invariant correlation. Expect a moderate, not high, relationship given the height-versus-flux divergence already shown against FIA site index; that is the anticipated result and the point.
