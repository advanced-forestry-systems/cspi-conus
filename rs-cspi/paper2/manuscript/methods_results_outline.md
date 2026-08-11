# CSPI Paper 2: Methods and Results outline (draft from session 1)

Working title: FIA-Independent Forest Productivity Surfaces for the Conterminous United States: Multi-Target Validation of a CONUS Environmental Stack.

Target journals: Remote Sensing of Environment or Biogeosciences. Cites the v3.0.0 dataset (DOI 10.5281/zenodo.20763197) as the upstream environmental stack.

## Methods (outline)

M1. Study extent and plot frame. The 61,656 FIA plot locations used in the v3.0.0 analysis serve only as a spatial sampling frame; no FIA-measured response enters any model. State the common-support count where targets overlap (35,851 plots have valid values for all six targets).

M2. Predictor stack. Restate the v3 environmental stack briefly with a citation to the v3.0.0 paper: water-balance suite (AET, DEF, PET, AI, RATIO, WD), shortwave radiation, vapor pressure deficit, wind, nitrogen deposition, distance to coast, and geologic parent material as a categorical. Eleven continuous predictors plus parent material.

M3. Satellite targets. Six targets across two productivity dimensions:
- Flux: MOD17 NPP (MOD17A3HGF mean annual), MOD17 GPP.
- Structure: GEDI L4B v2.1 gridded mean AGBD (1 km, EPSG:6933), NASA-CMS CONUS aboveground biomass (2016 level and 2005 to 2016 change), and canopy height.
Give each product's native resolution, record window, and the masking and reprojection steps (points reprojected to each target CRS; non-forest and fill values dropped).

M4. Model fitting. One ranger random forest per target, 500 trees, mtry = floor(p/3), impurity importance, predicting the target from the predictor stack. Report OOB R², OOB RMSE, and a climate-only baseline (six water-and-radiation predictors) to isolate the contribution of the non-climate predictors.

M5. Cross-target analysis. Pairwise Pearson r between target-specific predicted values at common-support plots; within-dimension and across-dimension means; per-plot dispersion across z-standardised predictions as a consensus-uncertainty proxy. Note the planned extension to full 30 m surface prediction and per-pixel CV.

M6. Ecoregion stratification. EPA Level 1 ecoregion assignment by spatial join (s2 off, geometry repaired). Per-L1 mean residual (obs − pred) per target. Head-to-head against the v3.0.0 Asym v9 FIA-target ecoregion bias profile.

## Results (outline, with session-1 numbers)

R1. Per-target predictability. Table of OOB R² by target. Flux targets predicted at 0.89 (GPP) and 0.92 (NPP), exceeding the FIA-derived Asym v9 benchmark (0.836). Structural targets lower: GEDI AGBD 0.74, CMS AGB 0.57, canopy height 0.48; biomass change weakest at 0.51. Frame the flux-vs-structure gap as the headline: climate-water-radiation forcing reproduces instantaneous flux far better than accumulated structure or change, because structure carries stand history and disturbance the environmental stack does not encode.

R2. Non-climate predictor contribution. The full stack beats climate-only for every target (ΔR² +0.009 to +0.036). Parent-material and the other non-climate predictors add consistent signal across all productivity dimensions, replicating the FIA-target finding. (Isolated parent-material ΔR² per target is a planned follow-up; this run reports the combined non-climate increment.)

R3. Cross-target agreement and triangulation. Pearson r within flux 0.85, within structure 0.63, flux vs structure 0.41, change near-orthogonal. The targets are complementary, not redundant: the same stack reproduces distinct dimensions to different degrees. This motivates a multi-dimension consensus product rather than a single surface.

R4. Ecoregion bias is shared across targets. The §3.23 NPP bias geography generalizes: essentially unbiased in the dominant forested ecoregions (Eastern Temperate Forests, NW Forested Mountains, Northern Forests), flux over-prediction in arid ecoregions, under-prediction in Marine West Coast. The cross-target consistency strengthens the claim that the bias is environmental-stack structure, not target-specific noise.

R5 (pending surfaces). 30 m single-target surfaces, multi-target consensus, and per-pixel CV map. Requires the surface-prediction step.

## Figures to build (next session)

- F1: bar chart of OOB R² by target with the Asym v9 reference line.
- F2: cross-target correlation heatmap (the 6x6 matrix), flux and structural blocks annotated.
- F3: per-L1 ecoregion residual small-multiples or bivariate panel across targets.
- F4 (pending): consensus 30 m surface and per-pixel CV map.

## Open items / honest caveats

- H1 (R² > 0.85 for all targets) is not supported as stated; it holds for flux only. Report this directly.
- Sentinel-2 greenness target not yet extracted (GEE memory limit on interactive sampling; needs Export.table.toDrive).
- CMS biomass units need confirmation from the product user guide before RMSE is reported in physical units.
- Cross-target r is computed at the plot level as a proxy; the surface-level CV is the publishable version.
