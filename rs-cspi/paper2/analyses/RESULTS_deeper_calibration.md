# Deeper calibration to FIA productivity

*23 June 2026. Predicting FIA productivity metrics from the full information (RS targets and the environmental stack) rather than the single lossy RS-CSPI composite, spatially blocked CV.*

## Result (blocked-CV R2)

| FIA response | RS targets only | environment | RS + environment |
|---|---|---|---|
| bgi (biological growth index) | 0.813 | 0.976 | 0.976 |
| asym (biomass asymptote) | 0.469 | 0.907 | 0.895 |
| SI (site index) | 0.458 | 0.600 | 0.645 |

## Interpretation, with the integrity caveats stated

The single RS-CSPI composite predicted bgi at only 0.27. The full information predicts it far better, which means the composite compresses away most of the predictive signal; for a growth-and-yield calibration the right move is to regress on the RS targets and environmental predictors directly, not on the one-number index.

Two of these responses are not clean calibration targets:
- bgi is itself an environment-derived biological growth index, so env to bgi at 0.976 is largely circular and must not be reported as a calibration success.
- asym is a smoothed Chapman-Richards biomass asymptote, so its 0.91 is inflated by the smoothness of the modeled response.

The clean, non-circular target is the FIA-measured site index, and env to SI at 0.60 matches the published CSPI v3.0.0 plot-blocked result (about 0.60 to 0.66). That is the defensible calibration number.

## What this changes

The earlier sobering conclusion (the index predicts FIA productivity weakly, 0.27) was an artifact of using the lossy single composite. The underlying RS and environmental information predicts measured site index at about 0.60, on par with established inventory-based site-index models. So a growth-and-yield-ready calibration is viable, but it should:
1. use the RS targets and environmental predictors directly, not the composite index;
2. target a genuinely measured response (FIA site index now; remeasured periodic increment from the GRM tables is the better future target);
3. avoid environment-derived proxies (bgi) and smoothed asymptotes (asym) as calibration responses, since they invite circularity.

## The definitive test: measured FIA increment (now run, the GRM blocker is resolved)

Using the FIA GRM tables directly (annual basal-area increment per acre from ANN_DIA_GROWTH and TPA, georeferenced via ENTIRE_PLOT, 119,845 plots), the measured growth calibration (blocked CV R2) is:

| predictor | R2 vs measured BAI |
|---|---|
| RS-CSPI index | -0.41 |
| RS targets | 0.20 |
| environment | 0.285 |
| RS + environment | 0.289 |

This is the honest, decisive finding. Measured current growth is only weakly predictable from environment and remote sensing (about 0.29), and the RS-CSPI index is inversely related to it (negative R2). The reason is silvicultural: current basal-area increment is dominated by stand age, density, and management, not by site potential. A young vigorous stand grows fast on a mediocre site; an old stand grows slowly on an excellent one. The RS-CSPI captures standing and potential productivity (it correlates with site index potential at about 0.60 and with flux towers at 0.66), but it does not predict the current growth rate, which requires stand state.

Conclusion for the growth-and-yield framing, stated plainly: the RS-CSPI is a site and standing productivity index, not a growth-increment predictor. It can supply the site-potential term in a growth and yield model, but the increment itself needs stand age and density, which this surface does not carry. The measured-increment calibration confirms that the index must be used as a site descriptor combined with stand state, not as a standalone growth driver.

## Blocker for the (even better) version

True measured-increment calibration needs the FIA GRM growth tables joined to the plots, but the validation plot IDs are anonymized sequential integers, not FIA PLT_CN, so the 642 MB GRM table cannot be georeferenced to the RS surface without rebuilding the plot-to-PLT_CN linkage (and even then on fuzzed coordinates). That linkage, plus the GRM net-annual-growth computation, is the follow-on study. Independent flux validation likewise needs an external FLUXNET2015 pull to grow beyond the 29 AmeriFlux towers on disk.
