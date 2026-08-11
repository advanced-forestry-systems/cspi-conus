# Editorial self-review: RS-CSPI manuscript (Paper 2)

*25 June 2026. Manuscript-review lens (Modules 1, 2, 5) applied to Aaron's own paper before submission to Remote Sensing of Environment. Quantitative Claims and Scaling Audit (Q1 to Q13) is the core of the assessment because the paper builds a wall-to-wall map product and makes scaling claims from it.*

## Module 1: preliminary screen

Type: research article. Thesis: treating remote sensing productivity as the response and environment as the predictor yields an inventory-independent, microsite-resolving composite productivity index for CONUS that diverges from height-based site index. Contribution: the response-side reframing, the wall-to-wall fine-resolution product, and the height-versus-flux divergence confirmed in independent ground data. Scope: clearly in scope for RSE (a continental remote sensing product with independent validation and an uncertainty layer). Figure budget: 4 figures, 0 tables in main text, well under the 6 to 8 rule of thumb (PD1 met); consider promoting one results table (blocked CV by target) for reader convenience.

## Quantitative Claims and Scaling Audit (the part that matters)

| item | verdict | basis |
|---|---|---|
| Q1 internal accuracy as validation | handled | OOB declared optimistic; all headline numbers spatially blocked (Sec 3.1, 3.3); AmeriFlux is the independent check |
| Q7 uncertainty | handled | per-pixel 90 percent prediction-interval layer, Figure 4 |
| Q8 resolution / MAUP | handled well | explicit 1 km vs 30 m vs 10 m sweet-spot sweep (Sec 3.9); claims stated conditional on grain |
| Q10 circular validation | handled | MODIS NPP circularity stated; structural targets and AmeriFlux (r 0.66 vs MODIS 0.24) carry the independent signal |
| Q12 use/scale not validated | mostly handled | 30 m microsite structure flagged as not independently validated against fine-scale ground productivity; the BC null bounds the ground-prediction claim |
| Q13 in-sample vs out-of-sample | handled, and a strength | the BC cross-jurisdiction test is a real out-of-sample probe; it returned a null for ground site index, now reported honestly, and AmeriFlux is the positive out-of-sample |
| Q11 design-based benchmark | n/a by construction | the composite is not an FIA quantity, so there is no design-based estimate of the same thing; the FIA site-index comparison is the closest and is reported |

The audit verdict: this is a competent product whose claims have already been pulled back to what the validation supports. The two prior overreaches (the wall-to-wall OOB gain and the SAE sharpening) were corrected in the numbers audit and now read honestly in the abstract, results, and discussion.

## Residual items (addressed in this pass)

1. **Reproducibility (G2, G3).** Methods named ranger and 500 trees but did not state the seed, the R version, or that grid and cross-validation models used 300 trees. Fixed in Sec 2.4.
2. **Figure 3 caption mismatch.** The caption described "RS-CSPI versus site index," but the rebuilt Figure 3 is the plot-level divergence (site index vs NPP and GPP). Caption updated to match, and the figure itself was regenerated so it no longer shows the superseded change-inclusive surface correlation.
3. **Microsite limitation crispness.** Made explicit that the one-third microsite variance is a property of the predicted surface, and that the 10 m sweet-spot test (only 1.3 percent added) is the evidence it is structured signal rather than predictor noise, while independent fine-scale ground validation remains future work.

## Residual items (flagged, not blocking)

4. **Figure 2 CI annotation.** The panel shows the 95 percent bootstrap CI as [0.38, 0.85] from a fresh resample; the registered value in the deposit and text is [0.35, 0.85]. Within Monte Carlo error; reconcile to the registered seed in the camera-ready.
5. **Title verb.** "resolves microsite variability" is defensible in the spatial-resolution sense and is now scoped in the text; a strict reviewer may still read it as a ground-validation claim. Kept, with the discussion scoping it explicitly.

## Module 5: indicative scoring (self-assessment, [REVIEWER VERIFY])

Originality 5, significance 4, methodological rigor 4, statistical appropriateness 4, reproducibility 4 (after the methods fix), model validation 4, literature coverage 3 (a fuller remote-sensing-productivity and site-productivity-mapping reference set would strengthen the intro), interpretation 4 (honest, well bounded), writing 4, figures 4.

Indicative recommendation if this arrived for review: **Minor to Major Revision**, the Major end driven only by reviewers wanting independent fine-scale validation of the 30 m microsite claim, which the paper already frames as future work. No design or analysis flaw blocks the central claim, and the claims now match the validation. The honest BC null and the AmeriFlux independent validation are the features that make it defensible.

*Prepared with AI assistance for structural organization and consistency checking. All scientific judgments are the author's.*
