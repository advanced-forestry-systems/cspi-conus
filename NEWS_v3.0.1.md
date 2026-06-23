# NEWS for CSPI v3.0.1 (planning)

Composite Site Productivity Index, conterminous United States.
Concept DOI 10.5281/zenodo.20515034. Prior version DOI 10.5281/zenodo.20763197 (v3.0.0).

## v3.0.1 (planned, post v0.10m manuscript)

Point release of v3.0.0. No new raster products. New analytical addenda:

### Reforestation potential quantification

Quantified the unmasked Asym v9 surface ("REFORESTATION_CANDIDATE_30m.tif") that ships in v3.0.0 for reforestation planning use.

- 548.7 million 30 m pixels (40.2 Mha, ~99 million acres) currently non-forest in the Hansen 2000 mask carry Asym v9 > 200 Mg/ha.
- Mean Asym v9 across candidates: 251 Mg/ha (range 211 to 327).
- Histogram: 60.6 percent of candidates in the 200 to 250 Mg/ha band, 39.1 percent in 250 to 300, 0.3 percent above 300.
- Aggregate model-estimated potential biomass: 10,088 Tg dry matter.
- Aggregate model-estimated potential carbon at f = 0.47: 4,741 Tg C = **4.74 Pg C**, roughly three times current annual U.S. forest-sector net sequestration as reported in the EPA national greenhouse gas inventory.
- Framed in the v0.10m manuscript §3.20 as a model-estimated environmental ceiling, not a realizable accumulation. Downstream studies must overlay current land-cover transition feasibility, ownership, fire regime, and stakeholder priorities.

Per-state tabulation will be released as `REFORESTATION_BY_STATE.csv` (Cardinal autopilot job 11944906).

### Wind exposure null finding

Tested TerraClimate annual mean wind speed (4 km resolution) at 31,463 plots used in the v9 model fit (PM33 series CSVs on Cardinal).

- Raw bivariate: mean Asym v9 increases monotonically from 236.7 Mg/ha at lowest wind decile to 261.3 Mg/ha at the eighth wind decile.
- After conditioning on the v9 stack: residuals collapse to within ±0.88 Mg/ha, one to two orders of magnitude below the v9 OOB RMSE of 8.21 Mg/ha.
- Per-parent-material residual correlations with wind: |r| < 0.25 for all categories, strongest on Eolian (+0.229) and Colluvium (+0.226).
- Spatial pattern reproduces parent material structure; wind operates predominantly through correlated climate and terrain covariates already in the v9 stack.
- Conclusion: mean wind speed is not an independent structural axis for Asym at the continental scale. No v9 wind correction shipping in v3.0.1.

### AmeriFlux external validation

Cross-checked CSPI v7 (operational composite) against published mean annual NPP at 28 US AmeriFlux forest tower sites.

- Pooled Pearson r = 0.17 (n = 28).
- Per-site pattern is the actual finding: Pacific Northwest sites track NPP correctly (Wind River CSPI 47, NPP 715–825; Blodgett, Metolius Mature similar). Eastern broadleaf sites cluster correctly at CSPI 18–21, NPP 540–725.
- Western montane sites compress the correlation: Niwot Ridge (CSPI 35.8, NPP 350), Valles Caldera Mixed Conifer (40.3, 375), Valles Caldera Ponderosa (41.5, 350), Metolius Young (45.3, 410). At all four, high height-growth potential coexists with low published NPP, reproducing the §3.14 volcanic-substrate orthogonality at an external (non-FIA) network.
- Read as structural confirmation that the multi-dimensional argument is biological, not a FIA-measurement-chain artifact. Sample size (n = 28) too small to anchor a specific R² value.

### Episodic wind disturbance: HURDAT2 (Cardinal autopilot job 11944906, in flight)

If HURDAT2 hurricane track density at 0.25 deg cells over CONUS shows a residual signal where TerraClimate mean wind did not, it would be reported as v3.0.1 §3.21b. If null, the v0.10m wind null finding stands. Results pending.

### What is unchanged

All v3.0.0 surfaces (ASYM_V9_CONUS_30m_fm.tif, ASYM_V9_CONUS_30m.tif, parent_material_30m_CONUS_4326.tif, trained ranger model) are unchanged in v3.0.1. No new raster ships; v3.0.1 is an analytical addendum.

### Deferred to v3.1.0

- ForestGEO buffered extraction (single-pixel Asym v9 was NA at 26 of 30 sites; resolve via 90 m buffer mean).
- BGI temporal trend across remeasurement cycles (needed TREE_GRM_MIDPT national coverage).
- SDI density merge fix (745k SDI values computed but merge to plot table failed on a column-name mismatch).
- Possible NSVB biomass swap to align with Westfall et al. 2024.
- NREL Wind Toolkit hub-height wind (80 m, 2 km) as a finer-resolution wind test.
- SVRGIS tornado paths density.

### Data availability

Concept DOI: https://doi.org/10.5281/zenodo.20515034
v2.0.0 DOI:  https://doi.org/10.5281/zenodo.20663652
v3.0.0 DOI:  https://doi.org/10.5281/zenodo.20763197
v3.0.1 DOI:  pending (analytical addenda)
Analytical chain DOI: https://doi.org/10.5281/zenodo.20693106

Manuscript: Weiskittel A.R. (in preparation, Forest Ecology and Management). Draft v0.10m at holoros/cspi-conus commit 4f96be0+.

License: CC-BY-4.0.
