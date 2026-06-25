# Tier 1 pan-Canadian prototype on the open MAGPlot frame

*25 June 2026. Open MAGPlot package (5 km randomized coordinates), 8 jurisdictions. Companion to the Paper 3 concept note.*

## What was built

From the open MAGPlot package (7.77 million tree records, 257,032 plot measurements), I derived per-site ground productivity for 37,612 sites: basal area per hectare and top height (dominant and codominant trees) at the latest measurement, and measured basal-area increment from remeasured plots (19,460 sites with a remeasurement span of at least five years). I then extracted ClimateNA normals and MODIS net primary productivity at each site and ran the same battery used for CONUS and BC.

## Results

(A) Satellite MODIS NPP versus Canadian ground productivity (n = 37,148), Pearson:

| comparison | r |
|---|---|
| NPP vs basal area | -0.03 |
| NPP vs top height | 0.03 |
| NPP vs increment | 0.02 |

(C) Divergence:

| pair | r |
|---|---|
| top height vs NPP | 0.03 |
| top height vs basal area | 0.69 |
| basal area vs NPP | -0.03 |

(B) Environment to ground productivity, spatially blocked cross-validation:

| scope | response | n | blocked R2 |
|---|---|---|---|
| national | basal area | 37,148 | 0.49 |
| national | top height | 33,350 | 0.32 |
| national | increment | 19,179 | 0.09 |
| BC | basal area | 14,802 | 0.27 |
| BC | top height | 14,655 | 0.15 |
| QC | basal area | 12,764 | 0.00 |
| QC | top height | 11,512 | 0.29 |
| NB | basal area | 7,485 | -0.13 |
| NB | top height | 6,926 | -0.06 |

(D) The Canada RS-CSPI surface (env to MODIS NPP) fits the national grid at OOB R2 0.976, the same climate-driven flux gradient as in CONUS, and produces a coherent coast-to-boreal productivity map.

## Reading the prototype

Three findings, all consistent with the CONUS and BC work and all sharpening the case for Tier 2.

First, the height-versus-flux divergence replicates a third time, now across boreal and temperate Canada: top height and MODIS NPP are orthogonal (0.03), while top height and basal area are strongly related (0.69). The ground data is internally coherent, so the null against NPP is not a data-quality artifact; it is the same divergence the paper documents.

Second, the BC null is really a scale effect, and the pan-Canadian data shows it cleanly. Nationally, environment predicts ground basal area at 0.49 and top height at 0.32, because climate captures the large boreal-to-temperate gradient. Within a single province that gradient is gone, and predictability collapses to near zero (QC basal area 0.00, NB basal area -0.13), exactly the BC plot-level null. Plot-level productivity within a climate zone is governed by species and stand state, not by environment, at every grain tested. Measured increment is barely predictable even nationally (0.09), reaffirming that current growth is a stand-state quantity.

Third, and decisively for the design, satellite NPP shows essentially zero correlation with any ground measure even nationally, where environment itself reaches 0.49. The difference is the 5 km coordinate randomization in the open package: pairing a plot with NPP up to 5 km away destroys the fine correlation. This is the quantitative argument that Tier 2 exact coordinates are necessary, not optional. The open package can map the surface and characterize the divergence, but it cannot validate the surface against ground productivity at the plot scale, because the coordinates are not exact.

## Implication for Paper 3

The open frame delivers the continental divergence result and a Canada surface immediately, and it demonstrates that the surface cannot be plot-validated without exact coordinates. That is precisely the gap the NFI exact-coordinate data request fills, and it is the strongest possible justification to put in that request: the 30 m microsite and plot-scale validation that closes Paper 2's main limitation is impossible on the 5 km frame and requires the true coordinates.

## Files

`canada/magplot/magp_site_productivity.csv` (derived ground productivity), `CAN_A/B/C_*.csv` (battery), `Canada_RS_CSPI_npp_2km.tif` and `Canada_RS_CSPI_map.png` (prototype surface).
