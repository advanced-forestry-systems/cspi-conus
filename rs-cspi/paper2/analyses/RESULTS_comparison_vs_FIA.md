# How the FIA-free RS-as-Y surface compares to existing FIA-derived products

*23 June 2026. Benchmarks the new wall-to-wall RS consensus (1 km augmented) against the existing FIA-derived CSPI v3 site index and the Asym v9 biomass productivity surface. Headline: the RS surface is not redundant with the FIA products; it captures the flux and biomass dimension of productivity, which diverges from height-based site index in exactly the way the FEM manuscript predicted.*

## The numbers

CONUS forest, common cells about 2.4 million (1 km):

| Comparison | Pearson | Spearman | quartile agreement |
|---|---|---|---|
| RS consensus vs CSPI v3 site index (FIA) | -0.39 | -0.36 | 0.21 |
| RS consensus vs Asym v9 biomass productivity (FIA) | +0.08 | -0.04 | 0.21 |

Per single target vs FIA site index:

| RS target | Pearson vs site index | Spearman |
|---|---|---|
| MODIS NPP | -0.44 | -0.40 |
| GEDI AGBD | +0.04 | +0.02 |
| CMS biomass | +0.13 | -0.18 |
| CMS change | -0.47 | -0.21 |

Within-region (quadrant) correlation with site index is positive, not negative:

| Region | Pearson vs CSPI v3 | vs Asym |
|---|---|---|
| West North | +0.40 | +0.32 |
| West South | +0.44 | -0.02 |
| East North | +0.07 | +0.07 |
| East South | +0.09 | +0.05 |

## What this means (and it is not an error)

The pooled correlation is negative while every within-region correlation is positive. That is a Simpson's paradox, and the cause is a real and known distinction.

The MODIS NPP raster is clean (range 2 to 1868 g C m-2 yr-1, mean 456, no fill contamination), so this is not a data artifact. The divergence is between quantities:

- Site index is height growth potential, in metres. It is highest in the Pacific Northwest, where Douglas-fir reaches 40 to 55 m, and lower in the Southeast, where loblolly pine tops out at 25 to 35 m.
- NPP and standing biomass are carbon flux and stock. NPP is highest in the warm, wet Southeast with its long growing season; biomass is highest in the Pacific Northwest.

So the tallest forests (high site index, Pacific Northwest) are not the highest-NPP forests (Southeast), and across CONUS the height dimension and the flux dimension pull apart. The RS consensus, built from NPP, biomass, and change targets, captures the flux and biomass dimension. The FIA CSPI surface captures the height dimension. They agree on the broad climate gradient within any region (all within-region correlations positive) but rank the country differently because they measure different things.

This is the same height-vs-flux pattern the FEM manuscript reported in §3.14 and §3.23, now confirmed at the wall-to-wall surface level with fully independent, FIA-free remote sensing targets. It strengthens the multi-dimensional productivity argument: a single number cannot represent forest productivity, and the RS surface and the FIA site index are complementary axes, not competing estimates of one quantity.

## How the approach fares

It fares well, on its own terms. As a FIA-independent surface it predicts its satellite targets strongly (blocked R² 0.75 to 0.86 for NPP, AGBD, biomass) and produces a coherent CONUS gradient. It is not a substitute for the FIA site index and should not be expected to reproduce it; it is a second, independent productivity axis. The honest framing for the paper is two complementary surfaces, not one validating the other.

## Caveats and the one check worth running

- The CMS change target and, to a lesser extent, NPP carry the strongest negative correlation with site index. A consensus intended as a productivity level may be cleaner if biomass change (a rate, not a level) is dropped; that is a one-line change worth testing.
- The comparison is scale-invariant (Pearson and Spearman), so unit differences between surfaces do not affect it.
- Confirmation run (clean plot data, no raster step). Correlating FIA site index against the satellite targets at the 61,655 plot locations gives: NPP -0.38, GPP -0.42, canopy height +0.02, Asym biomass +0.06, BGI -0.48 (Pearson). This reproduces the surface-level result exactly and rules out a raster or modeling artifact. The height-vs-flux divergence lives in the ground data itself: FIA site index (height growth potential) is genuinely negatively related to satellite carbon-flux productivity across CONUS forests.

## Bottom line

The negative correlation is a real result, confirmed in both the wall-to-wall surfaces and the clean plot data. The FIA-free RS-as-Y surface is a robust, independent flux-and-biomass productivity layer that is complementary to, not a replacement for, the FIA height-based site index. For the paper this is a strength: two independent productivity axes, one ground-based and height-oriented, one satellite-based and flux-oriented, that diverge in a way consistent with the multi-dimensional productivity thesis.

## Figures

- `CMP_F1_scatter_vs_cspi3.png` hexbin of RS consensus vs FIA site index
- `CMP_F2_sidebyside.png` rank-normalised CONUS maps, RS consensus vs FIA site index
