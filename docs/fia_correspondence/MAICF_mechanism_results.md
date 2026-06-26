# MAICF mechanism: results, and a headline-robustness flag

*25 June 2026. Run prompted by David Diaz's FIA correspondence. SITECLCD is a classification of MAICF (cubic-volume growth at culmination) derived from site index via species-specific yield equations. Tested on plt_ext_4c_plus_FIA.csv, n = 43,964 plots, 62 site-tree species. Random forest, OOB R^2 (in-sample-family). Predicts productivity-ordered FIA site class (8 - SITECLCD).*

## The mechanism is confirmed

The species-specific site-index-to-MAICF transform is real and large.

- Adding site-tree species to the reported site index raises OOB R^2 for the class from 0.499 (SICOND alone) to 0.739 (SICOND + species), a +0.240 gain. The same reported site index maps to different site classes depending on species, exactly as the yield-equation derivation implies.
- Within SICOND deciles, the mean site class spreads 1.3 to 2.0 classes across the eight most common site-tree species. A given site index can land two full productivity classes apart depending on which species the site tree is.

This is clean support for David's correspondence: the classification is a volume-growth construct produced by a strongly species-dependent transform of site index, not a relabeling of site index.

## RESOLUTION (reconciliation run, job 12026946): the headline holds

The fragility below was a subset artifact. Re-running BGI-alone vs ESI-alone on the manuscript's actual SITECLCD-complete dataset (n = 63,310, only SITECLCD + ESI + BGI required), with both out-of-bag and plot-blocked cross-validation:

| Dataset | BGI plot-CV | ESI plot-CV | gap (OOB / plot-CV) |
|---|---|---|---|
| SITECLCD-complete (manuscript, n=63,310) | 0.781 | 0.720 | +0.057 / +0.060 |
| 4-component subset (n=43,964) | 0.721 | 0.723 | +0.009 / -0.001 |

On the canonical dataset the biomass-growth advantage is +0.060 under plot-blocked CV, essentially identical to the +0.057 out-of-bag value, so it is not an OOB-optimism artifact and it reproduces the manuscript's 0.808 / 0.751. The near-tie appears only on the smaller four-component subset, which is restricted to timber plots with site trees and complete remote sensing and is therefore biased. The earlier residual-correlation finding came from that same biased subset.

Net: David's correspondence gives the mechanism (SITECLCD classifies MAICF, a cubic-volume-growth quantity, via a strongly species-dependent transform) and the reconciliation confirms the headline is robust. The mechanism now explains the headline rather than undermining it. The manuscript §4.7.1 was updated to this reconciled, accurate statement; no headline numbers needed changing.

---

## (Superseded) Earlier flag, retained for the record
## The headline gap looks fragile, and this needs a decision

| Predictor of FIA site class | OOB R^2 | gain over SICOND |
|---|---|---|
| SICOND (reported height SI) | 0.499 | 0 |
| ESI (unified height SI) | 0.766 | +0.267 |
| BGI (biomass growth) | 0.775 | +0.276 |
| Asym | 0.760 | +0.262 |
| SICOND + species | 0.739 | +0.240 |
| SICOND + ESI | 0.798 | +0.300 |
| SICOND + BGI | 0.756 | +0.258 |
| SICOND + ESI + BGI + Asym | 0.939 | +0.440 |

On this full FIA-joined table, **BGI (0.775) and ESI (0.766) recover the site class almost equally**, a gap of 0.009, not the 0.057 gap (BGI 0.808 vs ESI 0.751) the manuscript currently headlines. Two further results point the same way:

- The site-class variation left after removing the reported SICOND is explained by the unified **height** site index (residual correlation r = +0.22 with ESI) and **not** by biomass growth (r = +0.00 with BGI).
- Added to SICOND, ESI contributes more than BGI does (+0.300 vs +0.258).

The honest reading is that FIA site class is recovered comparably by biomass growth and by a clean height site index, with the clean height site index slightly ahead in the nested and residual senses. That is consistent with the MAICF mechanism (the class is a volume transform of height site index) but it does **not** support a strong "biomass growth recovers the classification better than site index" claim on this dataset.

## Why the discrepancy with the manuscript's 0.808 / 0.751

The manuscript figure came from a different subset (SITECLCD-complete n = 63,310) and possibly a different ESI version than the `esi` column in plt_ext_4c_plus_FIA (n = 43,964, four-component complete-case). The direction (BGI >= ESI) is preserved, but the magnitude of the gap is not. This is exactly the kind of subset sensitivity a reviewer would probe.

## Recommendation (needs Aaron and coauthor judgment, not an autopilot edit)

1. **Re-run the headline SITECLCD recovery on one canonical, documented dataset** (fix the ESI version, the complete-case rule, and n) and report that single number with its CV, not OOB. If the gap is ~0.01, the headline should shift from "biomass growth beats site index" to the better-supported and more interesting claim the mechanism gives: the FIA classification is a species-transformed volume-growth (MAICF) construct that no single reported value (the height site index) captures alone, and that biomass growth and a clean height site index recover comparably.
2. The MAICF mechanism, the species transform (+0.240), and the per-decile class spread (1.3 to 2.0 classes) are robust and should go in regardless.
3. This is a pre-coauthor-review catch. Better now than from a reviewer. I have added the mechanism and references to the manuscript but have left the headline numbers untouched pending this decision.
