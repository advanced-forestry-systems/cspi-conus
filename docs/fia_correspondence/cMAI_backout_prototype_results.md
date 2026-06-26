# cMAI back-out prototype: results and the noise it surfaces

*25 June 2026. Complementary to Aaron's active yield-curve work; he flagged that comparing biomass increment from remeasured plots against an idealized yield curve to back out cMAI is close to what he is doing. This is a quick on-disk prototype to see how the biomass-route cMAI lines up with the FIA site class, and how much the assumed curve shape moves it.*

## Method

For each FIA plot with asymptotic biomass (Asym), current annual biomass increment (BGI), and stand age, fit a Chapman-Richards biomass curve AGB(t) = Asym (1 - exp(-k t))^p by solving k from the current increment at the current age (p fixed), then compute cMAI = max_t AGB(t)/t and the culmination age. Tested p = 2 and p = 3. The point is to recover a continuous culmination mean annual increment from the increment-versus-idealized-curve comparison, which is the biomass analog of the cubic-volume MAICF that FIA bins into SITECLCD.

## Results

Alignment with the productivity-ordered FIA site class (Spearman):

| Quantity | Spearman vs site class |
|---|---|
| backed-out cMAI (p = 3) | +0.52 |
| backed-out cMAI (p = 2) | +0.42 |
| raw biomass increment (BGI) | +0.54 |
| asymptotic biomass (Asym) | -0.39 |

Mean cMAI (p = 3) and culmination age by FIA site class:

| SITECLCD | n | mean cMAI (Mg/ha/yr) | mean culm. age |
|---|---|---|---|
| 2 | 18 | 3.14 | 48 |
| 3 | 86 | 3.08 | 47 |
| 4 | 276 | 3.06 | 48 |
| 5 | 894 | 3.14 | 48 |
| 6 | 512 | 2.38 | 65 |
| 7 | 122 | 2.09 | 74 |

## Reading (honest)

Two things stand out, and both support Aaron's caution about noise.

1. The backed-out cMAI tracks the FIA site class only moderately (Spearman +0.52 at p = 3) and does not beat the raw biomass increment (+0.54). So recovering cMAI from a single current-increment anchor plus an assumed Chapman-Richards shape adds noise rather than sharpening the signal, at least in this quick form.

2. The result is sensitive to the assumed shape parameter: p = 3 gives +0.52, p = 2 gives +0.42. That sensitivity is exactly the cross-compatibility noise Aaron is examining with the GADA site-curve and yield-curve plots. The culmination-age pattern is biologically sensible (low-productivity classes 6 to 7 culminate later, at 65 to 74 yr, with lower cMAI), but the productive classes 2 to 5 are not separated (all near 3.1 Mg/ha/yr), partly because high site classes are rare in the data (n = 18 to 894) and partly because a single-anchor back-out cannot pin the curve where increment is still near its peak.

## How this connects

This is the biomass-route version of the MAICF mechanism: FIA SITECLCD is a binning of cubic-volume cMAI, and a biomass cMAI recovered the same way tracks it at +0.52. The takeaway for the manuscript and for the cMAI work is that the increment-to-cMAI step is shape-sensitive and noisy, so a defensible cMAI layer needs either multiple remeasurement points per plot (to fit the curve rather than anchor it) or a fixed regional curve family, not a single-anchor back-out. When Aaron pushes the GADA and yield-curve plots into the repo, the next step is to refit this against the proper per-species GADA curves rather than the placeholder Chapman-Richards form, and to use observed remeasurement increments rather than the modeled BGI.

Files: `rs_validation/cMAI_vs_siteclcd.csv`, `cMAI_by_siteclass.csv`, `cMAI_backout_plots.csv` (Cardinal), script `cmai_backout_prototype.R`.
