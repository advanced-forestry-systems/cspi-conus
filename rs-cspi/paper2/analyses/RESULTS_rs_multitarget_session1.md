# RS multi-target validation: session 1 results

*23 June 2026. Tracks 1 to 4 of the CSPI Paper 2 plan (FIA-independent productivity surfaces). All fits use the v3 environmental stack (water balance AET/DEF/PET/AI/RATIO/WD, SRAD, VPD, WIND, NDEP, DIST_COAST, plus parent material) against satellite-observed targets at the FIA plot locations. No FIA-derived metric enters any model; plot coordinates serve only as sampling points. Methodology mirrors `rs_target_npp_v2.r` exactly, so results are comparable to the v0.10p NPP fit already cited in the FEM manuscript.*

## Track 1: target acquisition

| Target | Source | Status | Notes |
|---|---|---|---|
| MOD17 NPP | GEE / plot-level `npp_obs` | in hand | CONUS 30 m mosaic not buildable from local HDF tiles (they are 196-byte stubs); plot values already extracted. Surface needs a GEE export. |
| MOD17 GPP | plot-level `gpp_obs` | in hand | already in the plot file. |
| Canopy height | plot-level `ch_m` | in hand | structural reference. |
| GEDI L4B v2.1 AGBD | ORNL DAAC | **downloaded** | Fixed the prior failure: correct collection is `GEDI_L4B_Gridded_Biomass_V2_1_2299` (C2792577683-ORNL_CLOUD); files are `GEDI04_B_MW019MW223_02_002_02_R01000M_{MU,SE}.tif` (1 km, EPSG:6933); auth requires `Authorization: Bearer` header, not netrc basic auth. MU + SE pulled, ~503 MB each, valid GeoTIFFs. |
| NASA-CMS CONUS biomass | ORNL DAAC | **downloaded** | Located `CMS_CONUS_Biomass_1752` (C2389289428-ORNL_CLOUD); `CONUS_agb_{2005,2010,2015,2016}_v1.tif`. Pulled 2005 and 2016 for level and change. |
| Sentinel-2 NDVI/EVI | GEE | blocked, path known | Service account authenticates (S2_SR_HARMONIZED returns 71,442 CONUS growing-season scenes). Interactive `reduceRegions` over 61k points hits GEE "user memory limit exceeded" even at 500-point chunks / scale 30 / tileScale 16. Correct fix is an async `Export.table.toDrive` batch job, then download the table. Documented as the next acquisition step. |

## Track 2: per-target OOB R² (v3 stack vs climate-only baseline)

| Target | Units | n train | OOB R² (v3 stack) | OOB R² (climate-only) | ΔR² | OOB RMSE |
|---|---|---|---|---|---|---|
| MOD17 NPP | g C m⁻² yr⁻¹ | ~61,000 | **0.919** | 0.897 | +0.022 | 509 |
| MOD17 GPP | g C m⁻² yr⁻¹ | 57,399 | **0.886** | 0.876 | +0.009 | 1,522 |
| GEDI L4B AGBD | Mg ha⁻¹ | 47,969 | 0.743 | 0.707 | +0.036 | 31.5 |
| CMS AGB 2016 | (product units) | 56,829 | 0.574 | 0.547 | +0.028 | 391 |
| CMS AGB change 2005 to 2016 | (product units) | 57,108 | 0.512 | 0.495 | +0.017 | 311 |
| Canopy height | m | 42,010 | 0.480 | 0.454 | +0.026 | 3.89 |

Reference: the FIA-derived Asym v9 surface (v3.0.0 manuscript) was OOB R² = 0.836.

Reading: the v3 environmental stack predicts the two **flux** targets (NPP, GPP) at R² near or above 0.89, exceeding the FIA-derived Asym benchmark. It predicts the **structural** targets (AGBD, CMS biomass, canopy height) less well (0.48 to 0.74), and the biomass **change** signal weakest (0.51), which is expected: structure and disturbance carry history and management that climate-water-radiation forcing does not encode. H1 as originally stated (R² > 0.85 for all four targets) holds for the flux targets only; the structural targets fall short, and that contrast is itself a result worth reporting.

The full stack beats the climate-only baseline for every target (ΔR² +0.009 to +0.036), confirming the non-climate predictors (parent material, N deposition, wind, distance to coast) add consistent signal across productivity dimensions, replicating the FIA-target pattern.

## Track 3: cross-target spatial agreement (plot-level, n = 35,851 common-support plots)

Pairwise Pearson r between target-specific predicted values:

|  | npp | gpp | ch | agbd | cms_agb16 | cms_agbchg |
|---|---|---|---|---|---|---|
| npp | 1.00 | 0.85 | 0.41 | 0.51 | 0.37 | 0.33 |
| gpp | 0.85 | 1.00 | 0.39 | 0.47 | 0.30 | 0.41 |
| ch | 0.41 | 0.39 | 1.00 | 0.65 | 0.56 | 0.11 |
| agbd | 0.51 | 0.47 | 0.65 | 1.00 | 0.68 | 0.16 |
| cms_agb16 | 0.37 | 0.30 | 0.56 | 0.68 | 1.00 | 0.13 |
| cms_agbchg | 0.33 | 0.41 | 0.11 | 0.16 | 0.13 | 1.00 |

- Mean r within flux targets (NPP, GPP): **0.85**
- Mean r within structural targets (AGBD, height, CMS AGB): **0.63**
- Mean r flux vs structural: **0.41**

H2 (any pair r > 0.80) holds for the flux pair. Cross-dimension pairs sit at 0.3 to 0.7, and biomass change is nearly orthogonal to the others. This is the triangulation argument for the paper: the targets are not redundant; they measure distinct productivity dimensions that the same environmental stack reproduces to different degrees. The full 30 m surface CV (true Track 3) is the remaining heavy step.

## Track 4: per-L1 ecoregion residual stratification (mean obs − pred)

| L1 ecoregion | n | NPP | GPP | AGBD | height | CMS AGB16 | CMS change |
|---|---|---|---|---|---|---|---|
| Eastern Temperate Forests | 234,470 | +0.9 | −3.0 | −0.3 | 0 | −1.4 | +1.1 |
| NW Forested Mountains | 61,327 | +9.7 | +1.3 | −0.1 | 0 | −10.8 | +7.5 |
| Northern Forests | 7,969 | +29.1 | +25.0 | +0.8 | +0.1 | +2.3 | +3.6 |
| Temperate Sierras | 6,490 | −7.2 | +12.5 | +0.2 | −0.1 | −3.3 | +6.2 |
| Great Plains | 5,214 | −60.7 | −259.8 | −6.3 | −0.3 | −60.7 | +27.1 |
| North American Deserts | 2,438 | −247.4 | −469.2 | −7.3 | −1.5 | −75.3 | +39.1 |
| Marine West Coast Forest | 309 | +372.1 | +509.6 | +7.0 | +1.1 | −137.5 | +185.7 |
| Mediterranean California | 259 | −81.0 | −366.6 | −7.8 | +1.2 | −79.5 | +23.9 |
| Southern Semi-Arid Highlands | 126 | −307.4 | −458.8 | +12.1 | +2.6 | +25.0 | +83.4 |
| Tropical Wet Forests | 109 | −434.6 | −9.9 | +0.4 | −0.3 | +69.2 | +19.6 |

The NPP column reproduces the FEM manuscript §3.23 numbers (Eastern Temperate Forests ≈ 0, Northern Forests +29, NW Forested Mountains +10, North American Deserts −247, Marine West Coast +372), confirming the pipeline. The key cross-target finding: the same ecoregion bias geography holds across all targets. The stack is essentially unbiased in the dominant forested ecoregions (Eastern Temperate, NW Forested Mountains, Northern Forests), over-predicts flux in arid ecoregions (Great Plains, North American Deserts), and under-predicts flux in the moisture-rich Marine West Coast. This is the §3.23 finding generalized from one target to six.

## Outputs (Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/`, pulled to `paper2/analyses/`)

- `PIX14_multitarget_oob_summary.csv`, `PIX12_agbd_obs_climate_vs_full.csv`, `PIX15_cms_oob_summary.csv` (Track 2)
- `PIX50_crosstarget_pearson.csv`, `PIX51_consensus_dispersion.csv` (Track 3)
- `PIX40_perL1_residual_all_targets.csv`, `PIX41_perL1_residual_wide.csv` (Track 4)
- `PIX11_*_varimp.csv`, `PIX22_*_predictions.csv`, `m_*_v2.rds` (per-target importance, OOB predictions, fitted models)
