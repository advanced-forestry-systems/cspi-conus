# NEWS for CSPI v3.0.0

Composite Site Productivity Index, conterminous United States.
Concept DOI 10.5281/zenodo.20515034.

## v3.0.0 (in preparation, 2026-06-15)

Version 3.0.0 extends the v2.0.0 multi-dimensional composite with three new products motivated by the geologic-axis analysis in the v0.10j manuscript.

### New products (v3.0.0)

**Asym v9 corrective surface at 30 m (two variants).** Refit asymptotic biomass random forest on the v3 environmental predictor stack (SoilGrids 0 to 5 cm: sand, soil organic carbon, bulk density, cation exchange capacity, nitrogen, pH; SRTM 30 m: elevation, slope, aspect; Hansen tree cover and loss-year) plus gSSURGO parent material category as a 10-class categorical predictor. Out-of-bag R² = 0.836 versus the v7 climate-only baseline of 0.828 (delta R² = +0.0078). Out-of-bag RMSE drops from 8.40 to 8.21 Mg ha⁻¹. The pm_factor predictor ranks 8 of 12 by impurity importance, between bdod_0_5 and slope. Both files are LZW-compressed BigTIFF with predictor=3 and tiled internal layout (COG-compatible).

- `ASYM_V9_CONUS_30m_fm.tif` (forest-masked, headline product for existing forest assessment). Forest pixels are defined by the CSPI v7 forest mask (Hansen tree cover 2000 ≥ 30%); non-forest pixels are set to the raster nodata value.
- `ASYM_V9_CONUS_30m.tif` (unmasked, full CONUS, including non-forested land). Provided for reforestation planning use cases: pixels currently classified as non-forest in the Hansen tree cover layer carry a model-estimated asymptotic biomass value that represents the potential mature carrying capacity of that location given its environmental conditions. Users can overlay non-forest land covers (current cropland, pasture, abandoned agricultural land) on this surface to identify locations where reforestation would establish stands with the highest long-run carbon storage potential.

**Parent material 30 m CONUS overlay.** Substituted the gSSURGO mukey raster with the dominant parent material category per map unit, grouped via gSSURGO `copmgrp.pmgroupname` into 10 broad classes (Residuum, Alluvial, Marine, Glacial, Colluvium, Eolian, Other, Organic, Volcanic, Lacustrine). 1.4 billion pixels covering CONUS, 307 MB compressed (LZW, tiled, BigTIFF). Intended as a separately citable overlay layer for users who want to stratify their own productivity analyses geologically. Output file: `parent_material_30m_CONUS_4326.tif`.

### Deferred to v3.0.1

**Delta Asym = v9 − v7 difference layer at 30 m.** Streaming pipeline ran into write conflicts on the multi-step job and is being rebuilt as a standalone job. Will ship in v3.0.1 once the 90,000 × 212,400 pixel difference layer completes. Users who want to see where parent material reorganizes asymptotic biomass predictions can either wait for v3.0.1 or compute the layer locally from the released v7 baseline (`Asym_on_esi_grid.tif` 1 km in v2.0.0) and the v3.0.0 ASYM_V9_CONUS_30m_forestmasked surface.

### Continued from v2.0.0

ESI v7 at 30 m: site-index height-growth potential surface, climate-driven random forest on the unified North America compilation. Retained as the headline height-growth productivity layer. The v3.0.0 release does not ship a v9 ESI corrective surface because the marginal information from adding parent material to ESI is negligible at plot resolution (mean |ΔESI| = 0.22 m on a 28 m scale; only Organic peatlands show meaningful structural reorganization).

BGI at 30 m: biomass growth increment, FIA pair-derived. Retained from v2.0.0; not refit on PM because the marginal gain is small (ΔR² = +0.0009) and the v2.0.0 BGI layer is already operationally good (OOB R² = 0.959).

Asym v7 at 30 m: asymptotic biomass, baseline climate-driven prediction. Retained as the reference layer that the v9 corrective surface is compared against.

NPP MOD17A3HGF at 500 m and CV layer: retained from v2.0.0.

3-component CSPI v2 composite at 30 m (ESI + BGI + Asym, equal-weight z-score average): retained from v2.0.0 as the operational composite. The v0.10j manuscript analysis confirms that free 3-component weights produce a small gain over equal weights (OOB R² 0.800 to 0.817 for SITECLCD recovery, +0.016) but per-PM stratified weights overfit small categories and adding PM as an additive categorical predictor on top of free weights adds no operational gain (ΔR² = +0.0003). The equal-weight composite remains the recommended default.

### Methodological convention change

ESI v9 and Asym v9 models drop LAT and LON from the predictor stack. LAT and LON in the v7 plot-level fit dominated impurity importance and contributed approximately 0.004 R² to ESI v7. The structural reading is that coordinate predictors let a random forest short-circuit through geographic position rather than forcing climate and substrate covariates to do the explanatory work. The no-coordinates convention is appropriate for understanding the substrate drivers of site productivity and is what the v3.0.0 models adopt. The v2.0.0 surfaces are unchanged.

### Data availability

Concept DOI: https://doi.org/10.5281/zenodo.20515034
v3.0.0 DOI: pending Zenodo deposit
v2.0.0 (previous): https://doi.org/10.5281/zenodo.20663652
Analytical chain DOI: https://doi.org/10.5281/zenodo.20693106

v3.0.0 DOI: https://doi.org/10.5281/zenodo.20763197

License: CC-BY-4.0. Companion manuscript: Weiskittel A.R. (in preparation, Forest Ecology and Management).

Pipeline repo: https://github.com/holoros/cspi-conus
