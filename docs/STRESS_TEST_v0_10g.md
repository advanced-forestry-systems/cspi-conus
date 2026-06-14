# Stress test: v0.10g manuscript and the multilevel ecoregion finding

*14 June 2026. Critical review before submission. Goal: identify what could fail under peer review or operational use, and what mitigation paths exist.*

## 1. The +0.0154 R² gain — is it real?

**The finding.** Joint random forest using c3_equal + c3_L1 + c3_L2 + c3_L3 reaches OOB R² = 0.8176 vs the equal-weight alone at 0.8022 (Δ = +0.0154). The hierarchical-shrinkage `c3_hier` paired with equal gives R² = 0.8149 (Δ = +0.0127).

**Concerns:**

- **No CIs reported.** With n = 63,270 the OOB R² standard error is roughly √(1/n) × R², about 0.003. So the +0.0154 gain is about 5 SE units — likely real but tight. Bootstrap CIs on each model are the immediate next stress test.
- **OOB R² inflation in dense forests.** Random forest OOB estimates can be optimistically biased when training data has spatial structure. Plot-blocked CV would give the honest number. The +0.015 might shrink to +0.008 to +0.012 under proper spatial CV.
- **The component composites are linear functions of the SAME three z-scores.** The random forest has lots of redundant information across the four composites. Adding L1, L2, L3 may be partially capturing nonlinearity in the same construct rather than new signal.

**Mitigations:**

1. Bootstrap CIs (~5 min on login node) — sanity check the +0.015 gain
2. Plot-blocked spatial CV instead of OOB — more conservative estimate
3. Report partial R² of each composite after controlling for the others — better separation of unique contributions

## 2. The 0.447 correlation between c3_equal and c3_L3 is surprising

**The finding.** From the M output: cor(c3_equal, c3_L3) = 0.447. Both composites use the same three z-scored components; the difference is only the weights.

**Why the low correlation?** Because the L3 weights vary by ecoregion. In one ecoregion w_ESI might be 2.8 and w_Asym = 0.1; in another the reverse. Each plot's c3_L3 is its own weighted average — different plots get systematically different weights. The pooled correlation across all plots is therefore not driven by component-level structure but by the spatial pattern of which plots are in which ecoregion. This is interpretable but worth stating: **the ecoregion-weighted composite is not just a "tilted" equal composite, it's a spatially-coordinated reweighting**.

**Manuscript implication.** Add a one-line note to §3.9: "The low pooled correlation between c3_equal and c3_L3 (r = 0.45) reflects that the ecoregion-weighted composite is a spatially-coordinated reweighting rather than a global tilt: each plot's weights are inherited from its ecoregion's PC1 loadings."

## 3. Shrinkage hyperparameters were picked ad hoc

**Concerns.** tau_3 = 200 and tau_2 = 500 were chosen by intuition. A different choice would give different results. The shrinkage formula is empirical Bayes-flavored but is not the actual Bayes estimator.

**Mitigations:**

1. Sensitivity grid: tau_3 ∈ {50, 100, 200, 500, 1000}, tau_2 ∈ {200, 500, 1000, 2000}
2. Report the choice as "we chose tau values that produce intermediate shrinkage at the median region n; results are robust to ±50% changes"
3. Or: use cross-validation to tune tau (more rigorous but adds complexity)
4. Acknowledge: the c3_hier composite is one operational choice; the gain it captures could likely be replicated by any reasonable smoothing of the L3 weights

## 4. FIA-on-FIA validation concern

**The biggest scientific stress.** Our SITECLCD prediction target is itself FIA-derived. Our ESI v7 training set, BGI, and Asym are also FIA-derived. The +0.015 R² gain from regional weighting could partly reflect FIA's own ecoregional calibration of SITECLCD rather than a genuinely independent productivity signal.

**Concerns:**

- SITECLCD is computed from regionally-calibrated growth equations (per-FIA-region SI tables map to SITECLCD bands). If FIA's regional structure mirrors EPA Level III, the L3 composite captures FIA's own regional decisions, not site quality.
- An honest assessment: we are showing a **representation** result, not a **prediction** result. The composite better represents what FIA SITECLCD is, but it does not predict an independent ground truth.

**Mitigations:**

1. Validate against an independent target (e.g., long-term carbon sequestration rates from FIA remeasurement pairs that are NOT in the SITECLCD calibration set, or NPP from satellite that has no FIA dependency)
2. Reframe the manuscript claim: "Our composite recovers FIA's SITECLCD ranking better than single measures" rather than "Our composite predicts site productivity better than single measures"
3. Acknowledge this explicitly in §4.7 limitations

## 5. Manuscript scope has grown

**The growth path:** v0.5 (4-component composite) → v0.9 (multi-dimensional reframe) → v0.10b (SICOND correction) → v0.10c (SSURGO) → v0.10d (GADA) → v0.10g (multilevel ecoregion).

**Concerns:**

- The manuscript now has Tables 1, 2, 2a, 2b, 2c, 3, 3a, 4, 5, 6 + bootstrap CIs + multilevel
- 9 main figures + 4 supplementary = 13 figures
- Three substantive empirical reframings layered on each other
- Word count is approaching 12,000 words (FEM typical is 8,000)

**Mitigations:**

1. **Split into two papers.** Paper 1: the multi-dimensional argument + SITECLCD result + SICOND correction + GADA validation. Paper 2: the multilevel ecoregion analysis (full treatment in its own paper, with the v3.0.0 surface direction).
2. **Or trim aggressively.** Move SSURGO, GADA, and multilevel to supplementary, keep only the v0.10 multi-dimensional + SITECLCD + Simpson correction in main text.
3. **Or repackage for a different venue.** A Forest Ecology and Management split: Paper 1 to FEM, Paper 2 to Methods in Ecology and Evolution or Forest Science.

**Recommendation:** Split. The multilevel analysis is strong enough to stand alone and would dilute the SITECLCD headline if kept in the same paper.

## 6. Operational complexity of multilevel composite

**Concerns.**

- Shipping the multilevel composite requires shipping per-ecoregion weight tables (50 L3 + 17 L2 + 9 L1) plus the shapefile plus a per-pixel ecoregion assignment for the 30m surface
- Users would need GIS chops to apply the weights correctly
- The decision-tree framing (F11) doesn't currently cover the multilevel option

**Mitigations:**

1. Ship the multilevel composite as a pre-computed 30m surface (no GIS computation needed on user side)
2. Add the multilevel option as a leaf in the F11 decision tree, with the caveat "use pre-computed multilevel surface; per-pixel reweighting requires regional shapefile + weight tables"
3. Keep equal-weight composite as the headline default; multilevel as the opt-in upgrade

## Recommended next steps (ranked by value)

1. **Bootstrap CIs + spatial CV** on the multilevel R² values (1-2 hours) — gives the honest +0.010 to +0.015 range and removes the OOB-bias objection
2. **Reframe the SITECLCD claim** to "representation" not "prediction" (1 hour manuscript edit)
3. **Decide on paper split** (executive call) — if split, this becomes v0.11 (main paper) + v0.12 (multilevel paper)
4. **Tau hyperparameter sensitivity** (30 min compute) — adds one sentence to §3.9
5. **Operational packaging** as a pre-computed surface (deferred to v3.0.0 release)

## Overall assessment

The v0.10g work is methodologically strong on the multi-dimensional and SITECLCD findings. The multilevel ecoregion finding is exciting but borderline overscoped for one paper and has the FIA-on-FIA validation concern that needs explicit acknowledgment. The honest path forward is bootstrap CIs + spatial CV + reframe + split. Manuscript is currently submittable; with the four mitigations above it becomes peer-review-robust.
