# CSPI release history

Concept DOI: 10.5281/zenodo.20515034 (always points at the latest version).

## Manuscript correction (v0.10b) — 14 June 2026

A reviewer-style robustness test of the SICOND headline result (in `analyses_v4/D1`–`D4` from SLURM job 11566914 `sicond_base50.r`) revealed that the v0.10 claim "FIA SICOND correlates with our unified-target ESI at r = −0.08, orthogonal — the field's traditional site index has been measuring biomass growth all along" is a base-age Simpson paradox. The raw pooled correlation aggregates across FIA's per-region SIBASE strata (base 50, 80, 100 yr), which occupy different parts of the SI distribution and generate a misleading pooled correlation.

Within each SIBASE stratum SICOND tracks ESI strongly (r = +0.42 at SIBASE 50, **+0.80 at SIBASE 80**, **+0.83 at SIBASE 100**). After anamorphic Chapman-Richards projection to a common base age of 50 yr (k = 0.025), the pooled SICOND–ESI correlation rises to +0.48 and SICOND–BGI drops to +0.45. Within sampling error of each other.

The corrected reading in v0.10b is that SICOND carries mixed information about both productivity dimensions at moderate magnitude, not predominantly one over the other. The earlier "SICOND has been measuring biomass growth all along while labeled as a height-growth measure" claim is walked back in §4.3.

What survives the correction unchanged:
- The SITECLCD result (random forest predicting FIA's 7-class classification, BGI alone OOB R² = 0.808 vs ESI alone 0.751) is independent of SICOND base-age and remains the cleanest single-statistic anchor of the multi-dimensional argument.
- The stand-age sign flip (ESI–BGI correlation −0.57 in middle-age stands to +0.33 in old growth).
- The per-species heterogeneity (yellow-poplar 0.028 to Douglas-fir 0.492).
- The East-West regime sign flip for Asym × NPP (−0.60 East, +0.57 West).
- The composite as an operationalization of the multi-dimensional view.

The v0.10b correction is logged transparently here because the v0.10 framing was already in the v2.0.0 Zenodo deposit README, the outreach package draft, and the collaborator deck. All three have been updated to match the corrected manuscript. The Zenodo README at version DOI 10.5281/zenodo.20663652 will be updated when next versioned (target v2.0.1).

## Manuscript reframe (v0.10) — 13 June 2026

The companion manuscript was reframed in v0.10 from a "we built a composite" narrative to a conceptual paper centered on the multi-dimensional structure of forest site productivity. Headline findings lead with the FIA SITECLCD result (FIA's own seven-class site productivity rating disagrees with site index but agrees with the composite) and the stand-age sign flip (ESI–BGI correlation goes from −0.57 at 60–80 yr to +0.33 at 120+ yr).

The composite was tightened from 4 components (ESI + BGI + Asym + NPP) to 3 components (ESI + BGI + Asym). NPP and FIA SICOND become external comparators against which the composite is validated. The PCA decomposition of the 3-component set shows that PC1 captures 56% of the variance with opposite-sign loadings on ESI (+0.64) and BGI (−0.75): the dominant axis of variation in the productivity construct is the ESI vs BGI trade-off.

## v2.1.0 — planned

Replaces the 1 km MIAMI climatology NPP layer in the CSPI v2 composite with the MODIS MOD17A3HGF annual NPP composite at 500 m native resolution. The 500 m MOD17 raster has already been downloaded to Cardinal (June 2026) and the surface generation will rebuild the composite using the same z-score parameters at the FIA plot set, ensuring numerical comparability across versions.

## v2.0.1 — pending v7 quantile-RF tile array completion

Adds `CSPI_V7_CONUS_30m_uncertainty.tif`, a 4-band quantile-RF uncertainty raster for ESI v7 (p05, p50, p95, width90). The all-in-one QRF surface predict in v2.0.0 timed out at the 8 h walltime ceiling; v2.0.1 ships the layer once the 40-tile array (Cardinal job 11503014) and the merge step (11503015) complete.

## v2.0.0 — pending mint, expected June 2026

Multi-metric composite headline product. Major restructuring of the CSPI release line:

- **Headline product changed.** The composite (CSPI v2 4-component, 30 m, sigma-clipped z-score average of ESI v7, BGI, Asym, and NPP) is now the primary surface. Previous releases used "CSPI" as the name for what is now called the Environmental Site Index (ESI).
- **Response variable changed.** ESI is trained on a unified North America height-and-age compilation under species-specific equations refit to a common base age, replacing the FIA condition-level site index (SICOND) target used in v1.0.0.
- **Predictor stack expanded** for ESI v7: adds four microclimate proxies (heat load index, northness, eastness, elevation squared) and a v6 1 km distillation column on top of the v5 11-covariate base.
- **Sensitivity test for remote sensing added.** ESI v8 evaluates the addition of five Sentinel-2 indices and four MOD17A3HGF terms over the v7 stack; reports +0.002 plot-blocked CV R², confirming the upper bound of what RS adds beyond a climate-distillation backbone.
- **Component layers released as standalone citable products.** BGI (30 m), Asym (30 m), MOD17 NPP mean and CV (500 m) ship as separate files so users can decompose the composite.
- **Cross-validation strengthened.** Five-axis stress test (plot-blocked CV, spatial latitude-fold CV, leave-one-set-out, per-species fits, fuzz robustness) extended to all three ESI versions independently.
- **Documentation richer.** New README with citation guidance for headline vs component use. Data dictionary with per-band metadata. CITATION.cff.
- **Retained from v1.0.0.** ESI v3 (30 m SICOND target), ESI v4 (1 km SICOND + climate target), and their forest masks and v4 quantile-RF uncertainty layers remain in the deposit for users who need the FIA SICOND target.

Files (15 total, ~235 GB on disk):

| File | Size | Description |
|---|---|---|
| CSPI_v2_4component_30m.tif | 32 GB | Headline composite (z-score avg of ESI v7 + BGI + Asym + NPP, 0–100) |
| CSPI_v2_4component_30m_forest.tif | 10 GB | Forest-masked composite |
| ESI_v5_CONUS_30m.tif | 50 GB | Soil + terrain + canopy ESI |
| ESI_v6_CONUS_1km.tif | 38 MB | v5 + ClimateNA, 1 km |
| ESI_v7_CONUS_30m.tif | 48 GB | Recommended ESI |
| ESI_v7_CONUS_30m_forest.tif | 19 GB | Forest-masked v7 |
| ESI_hybrid_CONUS_30m.tif | 46 GB | Latitude-weighted v5 + v6 blend |
| BGI_CONUS_30m.tif | 24 GB | Biomass growth from FIA pairs |
| Asym_CONUS_30m.tif | 23 GB | Asymptotic biomass (Chapman-Richards) |
| MOD17_NPP_mean_500m.tif | 130 MB | MOD17A3HGF NPP 2017–2023 mean |
| MOD17_NPP_cv_500m.tif | 149 MB | MOD17A3HGF NPP 2017–2023 CV |
| CSPI_V3_CONUS_30m.tif | 40 GB | Retained from v1.0.0 |
| CSPI_V4_CONUS_1km.tif | 30 MB | Retained from v1.0.0 |
| (+ retained v3 forest mask, v4 forest mask, v4 uncertainty raw + forest) | various | Retained from v1.0.0 |

## v1.0.0 — released 2 June 2026

Version DOI: 10.5281/zenodo.20515035

Initial CSPI release. Used FIA condition-level site index (SICOND) as the response variable. Two trained products:

- **CSPI v3 (30 m).** Random forest on 11 soil, terrain, and canopy covariates. Plot-blocked CV R² 0.602.
- **CSPI v4 (1 km).** Same predictor base plus 33 ClimateNA covariates. Plot-blocked CV R² 0.660. Per-pixel quantile-RF uncertainty included.

Both products with Hansen tree-cover forest masks. Total deposit ~40 GB.

The naming change in v2.0.0 (reserving "CSPI" for the multi-metric composite and using "ESI" for the predicted site index products) is a clarification, not a deprecation. The v1.0.0 product names remain at their minted version DOI for citation stability.
