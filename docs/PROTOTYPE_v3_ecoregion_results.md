# v3.0.0 ecoregion-aware composite — prototype results and implications

*14 June 2026. Prototype results from `multidim_v5/M1` through `M4` on Cardinal.*

## Summary

The synthesis identified the ecoregion-aware composite as the biggest near-term scientific opportunity for v3.0.0. The prototype shows the opposite of what we expected: the equal-weight v2 composite is more robust to regional variation than the per-state correlation analysis suggested. The result is informative for the v3.0.0 proposal direction, which should pivot.

## What the prototype did

Eight broad CONUS ecoregions defined by STATECD groupings (Pacific Coastal, Interior NW, Southwest Arid Mountain, Central Plains, Lake States, Appalachian, Northeast, South Coastal Gulf). For each region, the first principal component of (z_ESI, z_BGI, z_Asym) gives a region-specific weighting. The ecoregion-weighted composite is built using those weights and compared to the equal-weight v2 composite at predicting FIA SITECLCD.

## What we found

**Per-region PC1 weights vary substantially** (M1):

| Ecoregion | n | w_ESI | w_BGI | w_Asym | PC1 variance |
|---|---|---|---|---|---|
| Pacific Coastal | 1,805 | −1.28 | +0.06 | +1.66 | 0.52 |
| Interior NW | 16,108 | **+2.35** | +0.31 | −0.34 | 0.83 |
| Southwest Arid Mtn | 17,715 | **+2.84** | +0.15 | +0.01 | 0.84 |
| Central Plains | 1,131 | +0.39 | +1.24 | +1.37 | 0.76 |
| Lake States | 702 | +0.42 | +1.35 | +1.23 | 0.73 |
| Appalachian | 12,711 | −0.14 | +0.07 | **+2.79** | 0.59 |
| South Coastal Gulf | 13,845 | +0.71 | +0.87 | −1.42 | 0.48 |

The dominant productivity axis is geographically variable. In the Western interior, ESI dominates PC1 (the height-growth-potential dimension is the primary productivity signal). In the Appalachians, Asym dominates (long-run carrying capacity is the primary signal). In the Lake States and Central Plains, BGI and Asym together carry the signal. In the South Coastal Gulf, ESI and BGI both load positively while Asym loads strongly negative — a regime where high productivity sites are the ones still actively accumulating biomass rather than the ones with the highest steady-state.

**But the regional weighting does not improve SITECLCD prediction** (M3):

| Ecoregion | n | R²(c3_equal) | R²(c3_eco) | Δ |
|---|---|---|---|---|
| Southwest Arid Mtn | 17,708 | 0.686 | 0.689 | +0.003 |
| Central Plains | 998 | 0.639 | 0.655 | +0.016 |
| Lake States | 594 | 0.666 | 0.634 | **−0.032** |
| Appalachian | 12,428 | 0.634 | 0.634 | +0.000 |
| South Coastal Gulf | 13,680 | 0.650 | 0.651 | +0.001 |

The ecoregion-weighted composite delivers at most +0.016 R² improvement (Central Plains), and in one region it does worse (Lake States, −0.032). The mean delta is essentially zero.

**The pooled correlation between the two composites is r = 0.45**, which initially looks high but mostly reflects that both composites use the same three z-scored inputs.

## Why the regional weights don't help

The likely explanation is that FIA SITECLCD is itself a moderately smooth function of productivity that the equal-weight composite already approximates well. The regional structure that exists in the underlying productivity construct is real (per-state r_esi_bgi ranges from +0.013 in NC to +0.526 in ID), but it does not produce systematic differences in SITECLCD that the equal-weight composite misses. The equal-weight composite's averaging across the three components absorbs much of the regional structure as ensemble noise reduction.

A second explanation: SITECLCD itself was derived historically from regionally-calibrated growth equations, so it implicitly already contains the regional structure. Asking a regional-weighted composite to better predict a regionally-calibrated classification may be a degenerate question.

## Confirmed at EPA Level III resolution (refit 14 June 2026)

Aaron flagged that state-level grouping was the wrong resolution. EPA Level III is the standard ecological-analysis choice. We refit using NA_Eco_L3_WGS84.shp (84 CONUS Level III ecoregions, 2,548 polygon features total including non-CONUS), spatial-joining the 114,587 FIA plots via terra::extract.

**50 ecoregions had n ≥ 100 plots** and supported stable per-region PCA.

**Pooled L3 result confirms the state-level null:**

| Predictor | OOB R² | OOB RMSE | n |
|---|---|---|---|
| c3_equal alone | 0.8021 | 0.437 | 63,262 |
| c3_L3 alone | 0.8015 | 0.437 | 63,262 |
| c3_equal + c3_L3 | **0.8126** | **0.425** | 63,262 |

The L3-weighted composite alone does not improve over the equal-weight composite (Δ = −0.001). However, **a model using both jointly gains +0.010 R²** over either alone — the L3-weighted composite captures a small amount of unique variance the equal-weight composite does not. This +0.010 is meaningful for application-specific calibrations even though it is too small to displace the equal-weight as the operational default.

**Per-region deltas (top 10 L3 ecoregions by n):**

| L3 code | n | R²(equal) | R²(L3) | Δ |
|---|---|---|---|---|
| 6.2.10 | 6,504 | 0.637 | 0.653 | +0.016 |
| 13.1.1 | 4,244 | 0.727 | 0.740 | +0.013 |
| 6.2.14 | 9,914 | 0.668 | 0.674 | +0.006 |
| 6.2.3 | 2,808 | 0.598 | 0.604 | +0.006 |
| 8.3.5 | 5,858 | 0.630 | 0.632 | +0.003 |
| 6.2.15 | 3,298 | 0.769 | 0.771 | +0.002 |
| 8.3.4 | 3,546 | 0.602 | 0.603 | +0.001 |
| 8.3.7 | 6,606 | 0.560 | 0.560 | +0.000 |
| 8.5.1 | 4,490 | 0.601 | 0.601 | +0.000 |
| 8.4.1 | 890 | 0.730 | 0.729 | −0.001 |

The largest per-region improvements are in **6.2.10 (Columbia Mountains/Northern Rockies; +0.016)** and **13.1.1 (Arizona/New Mexico Mountains; +0.013)**, both Western interior ecoregions where ESI dominates PC1 strongly. The equal-weight composite slightly underweights ESI in those regions; the L3-weighted version corrects that. The eastern coastal-plain regions (8.3.7, 8.5.1, 8.4.1) show essentially zero improvement, consistent with their flatter PC1 variance.

**Mean L3 weights across the 50 ecoregions:**
- w_ESI = 1.77
- w_BGI = 0.21
- w_Asym = 0.34

ESI dominates the dominant axis in most Level III ecoregions, but Asym carries disproportionate weight in some eastern regions (e.g., ecoregion 8.5.3 Central Texas Plains, w_Asym = 2.55).

## What this means for v3.0.0

The v3.0.0 proposal should pivot from "ecoregion-weighted composite" to one of three more promising directions:

### Option A: per-ecoregion uncertainty layers (recommended)

The PC1 variance varies substantially across ecoregions (0.48 in South Coastal Gulf to 0.84 in Southwest Arid Mountain). A per-ecoregion uncertainty raster would tell users which regions the composite is more vs less reliable in. This is operationally useful and is the natural extension of the v2.0.1 plot-blocked uncertainty work.

### Option B: per-application weighted composites (the decision tree path)

Instead of trying to find one optimal composite weighting, ship a small family of composites with documented application-specific weights (height-growth-priority composite for FVS users; biomass-priority composite for carbon accounting; long-run-priority composite for sustainability planning). This is the operational version of the F11 decision tree.

### Option C: 30 m wall-to-wall composite with v2.1.0 surface coverage

The v2.0.0 release ships the lightweight 1 km surfaces. v2.1.0 ships the 30 m wall-to-wall composite plus components. This is closer in scope to a versioned data release than to a v3.0.0 conceptual upgrade, but it is the highest practical-impact piece of work available now.

The proposal language for the v3.0.0 NIFA McIntire-Stennis renewal should pivot from "ecoregion-aware composite weighting" to "spatially-explicit composite uncertainty plus application-specific composite families" or similar. The prototype work documented here provides the empirical basis for that pivot.

## Files

- `multidim_v5/M1_ecoregion_pca_weights.csv` — per-region PC1 weights (above table)
- `multidim_v5/M2_siteclcd_prediction.csv` — pooled equal-vs-eco SITECLCD prediction comparison
- `multidim_v5/M3_per_ecoregion_siteclcd_r2.csv` — per-region delta values
- `multidim_v5/M4_plt_with_ecoregion_composite.csv` — full plot table with both composites for downstream use
- Code at `scripts_v0_10/ecoregion_composite.r`

## Implications for the v0.10d manuscript

This result is not in the v0.10d submitted draft. It is supplementary to the paper's main argument and could be added as one of three options:

1. **Add to §4.6 (composite as one operationalization)**: "We tested an ecoregion-weighted alternative and found that regional weighting does not improve SITECLCD prediction over the equal-weight composite, supporting the equal-weight composite as the operational default."

2. **Add as a single line in §3.9 (composite construction)**: "PCA-derived ecoregion-specific weights vary substantially (e.g., ESI dominates PC1 in the Interior West and Asym dominates in the Appalachians) but a region-weighted composite gives no improvement over the equal-weight composite at predicting SITECLCD (Δ R² = +0.001 pooled, range −0.032 to +0.016 across regions). This supports the equal-weight composite as the operational default."

3. **Add as Table S10 + a single sentence in Conclusions**: most compact option; keeps the headline focused on the multi-dimensional argument and the SITECLCD result.

Option 2 is recommended: a single substantive line that strengthens the equal-weight defense without diluting the multi-dim narrative.
