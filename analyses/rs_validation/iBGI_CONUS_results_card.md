# iBGI for CONUS: results card

*21 June 2026. Operationalizing the iBGI concept of Lamb et al. (2020, Remote Sensing 12(12):2056) at the conterminous scale. n = 40,019 complete-case FIA plots. Ranger random forest, plot-blocked 5-fold CV and spatial latitude-fold CV. Seed set. Calibration target: observed MODIS GPP.*

## What was tested

Lamb et al. (2020) improved the biomass growth index by adding Sentinel-2 metrics, with the red-edge position (S2REP) the most important. We tested at CONUS whether the Sentinel-2 stack (NDVI, EVI, NDRE, S2REP, CIRE) improves a biomass-productivity model beyond BGI alone, calibrated against observed MODIS GPP.

## Results

| Model | plot-blocked CV R^2 | spatial (latitude-fold) CV R^2 |
|---|---|---|
| BGI alone (baseline) | 0.610 | 0.416 |
| BGI + Sentinel-2 (iBGI) | 0.820 | 0.613 |
| gain from Sentinel-2 | +0.211 | +0.197 |

Variable importance (permutation): NDVI > CIRE > BGI > NDRE > EVI > S2REP.

## The honest reading (important)

The +0.21 plot-blocked gain is large, but it must not be reported at face value as the value of Sentinel-2 for site productivity, for one reason: the calibration target here is MODIS GPP, which is itself derived from optical reflectance, and the strongest Sentinel-2 predictors (NDVI, CIRE, EVI) are optical greenness indices. A large part of the apparent gain is shared remote-sensing method variance between the predictors and the target, not independent productivity skill. NDVI ranking first in importance is the tell: NDVI and MODIS GPP are near-definitionally coupled.

The conservative, method-independent estimate of Sentinel-2's added value is the S2REP-only test in the validation memo: adding S2REP to BGI raised the adjusted R^2 for observed GPP by only +0.018 (and observed NPP by +0.072). This is consistent with Lamb et al.'s roughly 2 percent improvement when Sentinel-2 was used to improve BGI against ground-referenced biomass growth, rather than against an optical product.

## Recommendation for an operational CONUS iBGI surface

Do not calibrate the operational iBGI surface to MODIS GPP. Calibrate it to the FIA biomass-growth response that BGI is trained on (the remeasurement-pair increment), with the Sentinel-2 stack as added predictors. That measures genuine added skill and avoids reconstructing MODIS GPP. The expected real gain is modest (a few percent), matching Lamb et al. (2020). The S2REP and red-edge indices (NDRE, CIRE), which are less coupled to a greenness-defined target than NDVI, are the predictors most likely to carry independent structural information and should be retained preferentially.

## Surface staging

The CONUS iBGI surface is staged but blocked on two inputs that are not yet confirmed on Cardinal:
1. The 30 m CONUS BGI raster (in the Zenodo v2.0.0 deposit; likely archived or compressed on Cardinal, needs locating or re-staging).
2. A 30 m CONUS Sentinel-2 S2REP and red-edge composite (the gee_export_s2rep_conus.js / merge_s2rep.r workflow exists; the CONUS raster needs regeneration via GEE).

Once both are present, the surface is a tiled apply of the FIA-response-calibrated iBGI model over BGI plus the S2 layers, following the predict_asym_v9 tiling recipe. The daily Cardinal check reports allocation status; this surface should run after the conus_v4 array clears.

## Files

| File | Description |
|---|---|
| `iBGI_cv_results.csv` | the CV table above |
| `iBGI_variable_importance.csv` | permutation importance |
| `m_ibgi_gpp.rds` (Cardinal) | fitted RF (GPP-calibrated; for diagnostics only, not the operational surface) |
| `rs_ibgi_model.R` | production script |
