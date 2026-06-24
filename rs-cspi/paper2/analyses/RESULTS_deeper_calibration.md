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

## Blocker for the best version

True measured-increment calibration needs the FIA GRM growth tables joined to the plots, but the validation plot IDs are anonymized sequential integers, not FIA PLT_CN, so the 642 MB GRM table cannot be georeferenced to the RS surface without rebuilding the plot-to-PLT_CN linkage (and even then on fuzzed coordinates). That linkage, plus the GRM net-annual-growth computation, is the follow-on study. Independent flux validation likewise needs an external FLUXNET2015 pull to grow beyond the 29 AmeriFlux towers on disk.
