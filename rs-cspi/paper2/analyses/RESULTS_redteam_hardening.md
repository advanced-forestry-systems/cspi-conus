# Red-team hardening results

*23 June 2026. Analyses run to answer the stress-test items. All use spatially blocked CV (1 degree blocks, 5 folds) or independent ground data.*

## H2 (resolved, with a correction). The wall-to-wall advantage is coverage, not a uniform predictability boost.

Under like-for-like spatially blocked CV:

| Target | plot frame, blocked R2 | wall to wall, blocked R2 |
|---|---|---|
| MODIS NPP | 0.86 | 0.858 |
| GEDI AGBD | 0.605 | 0.748 |

For the flux target the two frames are identical; the earlier "0.57 to 0.93" gap was out-of-bag autocorrelation inflation on the dense grid, not signal. For the structural target wall to wall is genuinely higher. Corrected claim: the wall-to-wall design buys complete spatial coverage and a real gain on structural targets, not a uniform increase in predictability. The headline must use blocked CV, not OOB.

## H1 (mitigated). The targets are not merely a climate model predicted from climate.

Plot-frame blocked CV by predictor family:

| Target | full (43) | climate only (32) | non-climate only (11) |
|---|---|---|---|
| MODIS NPP | 0.86 | 0.793 | 0.813 |
| GEDI AGBD | 0.605 | 0.417 | 0.608 |

Non-climate predictors (terrain, soil, canopy) predict NPP as well as climate does (0.81) and predict AGBD better than climate (0.61 vs 0.42). The predictability is not an artifact of MOD17 being a climate model; terrain and soil carry it. AGBD is genuinely terrain and soil driven. The MOD17 circularity remains a caveat for the flux target specifically and is stated, but it does not explain away the result.

## H3 (resolved, the key addition). Independent validation against AmeriFlux towers.

At 30 US forest flux towers (published GPP/NPP), Pearson r with the surfaces:

| Surface | r vs tower productivity (n = 29) |
|---|---|
| RS-CSPI composite | 0.66 |
| CMS biomass surface | 0.63 |
| GEDI AGBD surface | 0.60 |
| MODIS NPP surface | 0.24 |
| SAE-refined asym surface | -0.12 |

The composite tracks independent ground productivity at r = 0.66, the first validation against something other than the RS targets themselves. Tellingly, the MODIS-NPP surface tracks tower flux worst (0.24), consistent with its circularity, while the structural surfaces and the composite do well. The SAE-asym surface does not track flux (-0.12), consistent with asym being a biomass-potential, height-aligned axis that diverges from flux, the same height-versus-flux pattern.

## M1 (resolved, with a correction). The SAE gain is spatial interpolation of inventory, not the RS layer.

Blocked CV decomposition:

| Response | spatial smooth only | RS only | combined |
|---|---|---|---|
| asym | 0.796 | 0.239 | 0.799 |
| bgi | 0.946 | 0.735 | 0.948 |

The spatial smooth alone equals the combined model; the RS layer adds essentially nothing once the spatial term is in. The earlier "0.71 to 0.94" framing credited the RS backbone, but the gain is kriging-like interpolation of dense FIA. Corrected framing: where inventory is dense, spatial interpolation of inventory alone gives an excellent local surface; the RS-CSPI's role is coverage where plots are sparse, not improving the interpolation where they are dense. The two are complementary in coverage, not a backbone refined by FIA.

## Net effect on the paper

The construct survives the stress test, but three claims are corrected to their honest form: the wall-to-wall comparison must be blocked-CV (coverage plus structural gain, not a uniform boost); the SAE is inventory interpolation complemented by RS coverage; and the MODIS-NPP flux number is the least independent and is caveated. The new strength is the independent AmeriFlux validation (r = 0.66). These corrections make the paper more defensible, not less interesting.
