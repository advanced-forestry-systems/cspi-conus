# Self-review of CSPI v0.10b manuscript

*Internal review per manuscript-review skill, applied to Aaron's own paper after the SICOND base-age Simpson paradox correction. Self-reviews skip Module 4 citation integrity (handled in earlier session) and Module 3 AI detection (declared); focus is on Modules 1, 2, and 5 with extra weight on whether the v0.10 → v0.10b correction propagated cleanly.*

**Date:** 14 June 2026
**Reviewer:** Aaron R. Weiskittel (via Claude self-review)
**Target journal:** Forest Ecology and Management

---

## Module 1: Preliminary screen

1. **Manuscript type:** Research article with a strong conceptual reframing layer. The methods, results, and validation sections give it research-article scaffolding; the abstract and discussion give it Perspectives-style argumentative weight.
2. **Central thesis:** Forest site productivity is empirically multi-dimensional. No single operational measure substitutes for any other, and the FIA's own seven-class productivity classification (SITECLCD) tracks biomass growth more closely than site index.
3. **Methodological approach:** Five productivity measures computed at 66,433 FIA Phase 2 plots (114,587 with FIA COND join). Cross-prediction random forests, per-species and per-region correlations, FIA SITECLCD stratification, anamorphic Chapman-Richards SICOND projection, three-component composite construction, ESI v5/v6/v7/v8 model series with plot-blocked + spatial-fold CV.
4. **Stated contribution:** (a) the first CONUS-scale four-measure productivity comparison with FIA SITECLCD context, (b) the SITECLCD result quantified as a random forest R² gap, (c) the multi-dimensional composite product line (CSPI v2.0.0 at Zenodo).
5. **Scope alignment:** CLEARLY IN SCOPE for Forest Ecology and Management. Quantitative forest productivity at the continental scale with downloadable products.
6. **Author-side CoI:** None. Single-author paper.
7. **Reviewer-side CoI:** This is a self-review of the author's own work, so the normal reviewer-conflict checks are inverted. Disclosure: I am simulating an independent reviewer pass to catch issues I would catch in someone else's paper.
8. **Major strengths:**
   - Section 3.6 (SITECLCD analysis with Table 3 and Table 3a) is the strongest single section in the paper. The OOB R² = 0.808 (BGI alone) vs 0.751 (ESI alone) gap is a clean, defensible single statistic that anchors the multi-dimensional argument. It is independent of the SICOND base-age correction.
   - Section 3.5 + Table 2a (new in v0.10b) demonstrates intellectual honesty: when the underlying SICOND result was revisited under a base-age control, the paper updates rather than doubles down. Reviewers will respect this.
   - The deposit + decision-tree-figure architecture (component layers plus composite plus F11 caveat list) gives downstream users an honest path through the multi-dimensional claim rather than asking them to take it on assertion.
9. **Preliminary concerns:**
   - Abstract still leads with the cross-prediction R² range (0.70 to 0.89) and mentions the (now-corrected) raw SICOND-ESI numbers in second priority. Reorder so the SITECLCD/Table 3a headline lands first; the cross-prediction result is structurally less compelling. (PRESENTATION)
   - Table 2a uses bold on the +0.797 and +0.831 cells (good for reader attention) but the table title doesn't tell the reader WHY those are the cells to bold. Add one-line caption: "Bold values indicate SIBASE strata where SICOND tracks ESI more strongly than BGI". (PRESENTATION)
   - Section §3.5 last paragraph is a single 200-word block. Split at "What remains intact is..." into two paragraphs for readability. (PRESENTATION)
   - The §4.3 rewrite (post-Simpson) is well done but the "modest calibration shifts" claim at the end is unquantified. Either give a numerical bound (e.g., "the calibration shift on dominant-tree height predictions should be on the order of 5 to 10 percent") or remove the magnitude word. (CONCEPTUAL)
   - Conclusions section, paragraph 2, still says the SICOND-ESI correlation went from r = -0.08 to "r = +0.45 to +0.48 after base-age correction" without naming Simpson's paradox or referencing Table 2a. Add a one-clause forward reference for readers who skip §3.5. (PRESENTATION)
10. **Recommended focus for Module 2:** D1/D2 (rigor + scoring after the substantive correction), S9 (statistical reporting consistency after the numeric overhaul), V5 (does the validation match the corrected claim).

## Module 2: Methods and statistical rigor audit

**Research article checklist:**

| Item | Status | Note |
|---|---|---|
| G1 Reproducibility | MET | Pipeline at github.com/holoros/fvs-conus; multidim_v2/v3/v4 CSVs deposited; Zenodo concept DOI 10.5281/zenodo.20515034. |
| G2 Software versions | PARTIAL | ranger 0.16.0 named; data.table not versioned in Methods; nlme would be needed for true GADA refit (not yet done; deferred to follow-up). |
| G3 Random seeds | PARTIAL | set.seed(47) in multidim_v3 C5 only. SLURM scripts for v5/v6/v7 RF model fits in fvs-conus repo handle seeds; manuscript §2.4 does not name them. |
| S1 Statistical tests appropriate | MET | Pearson r for continuous-continuous; random forest for nonlinear cross-prediction; both appropriate. |
| S2 Sample size justified | MET | n = 66,433 to 114,587 depending on analysis. Not an underpowered design. |
| S2b Spatial autocorrelation | PARTIAL | §4.7 names this as a limitation; plot-blocked and latitude-fold CV partly addresses; Moran's I diagnostic on per-fold residuals named as future work. |
| S3 Assumptions tested | PARTIAL | RF makes few; OLS in §3.2 doesn't report residual diagnostics. Acceptable for the §3.2 use as a single-number gap comparison; would not be acceptable for an inferential OLS use. |
| S4 Effect sizes | MET | R², r, mean differences, all reported. |
| S5 Multiple comparison correction | NOT APPLICABLE | Paper is descriptive, not hypothesis-testing. Per-species and per-state correlations are descriptive structure exploration. |
| S6 Confidence intervals | NOT MET | No CIs on any r or R². Add at minimum bootstrap CIs on Table 1 and Table 3a R² values. (REVIEWER VERIFY: priority depends on FEM convention.) |
| S7 Practical vs statistical | MET | The whole paper is about practical / structural significance, not p-values. |
| S8 Replication level | MET | Plots are the unit; analyses respect that. |
| S9 Reporting consistency | **NEEDS CHECK** | After the v0.10b correction, verify that every numerical reference to the SICOND-ESI orthogonality has been updated. The grep in the FEM combined file showed 4 remaining instances in the v0.5 v2 supplements section, which is fine for the supplements (they describe the older 4-component analysis state) but worth a final pass before submission. |
| S10 Pseudoreplication / effective n | MET | Cross-sectional plot-level analysis; no time-series confound. |
| S11 Equivalence / null acceptance | NOT APPLICABLE | No equivalence claim. The "within sampling error of each other" claim for SICOND-ESI vs SICOND-BGI in §3.5 should be quantified by reporting the 95% CIs on each r (linked to S6). |
| M1 Equation numbering | MET | Few equations; CSPI = z-score average is described in §2.2 prose, no formal numbering needed. |
| M2 Parameter estimates with SEs | NOT APPLICABLE | No fitted parameters in the headline analyses. RF doesn't have classical SEs. |
| M3 Notation consistency | MET | ESI, BGI, Asym, NPP, SICOND, CSPI consistent throughout. |
| V1 Independent validation | MET | Plot-blocked + spatial latitude-fold CV. |
| V2 Validation metrics | MET | R², RMSE, OOB R² all reported. |
| V3 Residual diagnostics | PARTIAL | F4 shows CV R² across versions; supplements have residual maps. |
| V4 Validation sample size | MET | Folded CV across 66k+ plots. |
| V5 Validation matches claim | MET | The claim is about cross-measure structure at the plot level; the analyses test exactly that. |

**Presentation and distillation:**

- PD1 Figure/table budget: 11 main figures (F1-F11) + 4 main tables. Inside the 6 to 8 guideline if we trim. Recommend moving F4 (CV bar versions) and F5 (variable importance) to Supplementary; both are diagnostic. Keep F1, F2, F3, F7, F8, F9, F10, F11 as the main set. (8 figures, on target.)
- PD2 Redundancy: F1 (correlation heatmap) overlaps slightly with Table 2 information. Consider merging F1 into Table 2 caption visual, or moving F1 to supplements.
- PD3 One-fact exhibits: Table 3a has 7 rows, each a meaningful comparison. Not a one-fact exhibit. Table 4 stand-age table similarly multi-fact. Good.
- PD4 Orphaned exhibits: none after the v0.10b correction.
- PD5 Distillation toward key findings: lead with Table 3 + Table 3a (SITECLCD result) as the strongest single piece. Table 2 + Table 2a (SICOND correction) is the second strongest. Tables 1 and 4 are supporting.

## Module 5: Scoring scaffold

| Dimension | Score | Confidence | Justification |
|---|---|---|---|
| D1 Originality | 4 | H | First CONUS-scale four-measure productivity comparison with FIA SITECLCD as comparator. The Table 3a SITECLCD random-forest result is novel as a single defensible statistic, even though the multi-dimensional argument has antecedents in Bontemps and Bouriaud (2014). |
| D2 Significance to field | 4 | H | The SITECLCD result and the SICOND base-age correction both have direct practical implications for FVS calibration and for SITECLCD-trained models. The decision-tree figure (F11) gives downstream users a usable framework. |
| D3 Methodological rigor | 4 | H | Cross-prediction RF + SIBASE stratification + Chapman-Richards anamorphic projection are appropriate methods. The Simpson paradox catch and correction in v0.10b is a sign of rigor. |
| D4 Statistical appropriateness | 3 | M | Lack of CIs on r and R² (S6) is the main weakness. Bootstrap CIs would add 1 to 2 days of compute and remove this objection. |
| D5 Reproducibility | 4 | H | Full pipeline in fvs-conus repo; data deposited at Zenodo with concept DOI for long-term stability; analysis CSVs (multidim/multidim_v2/multidim_v3/multidim_v4) ship as supplementary data. |
| D6 Model validation | 4 | H | Plot-blocked + spatial latitude-fold CV; sensitivity test with v8 (remote sensing add-on); ESI v7 used for the composite is the conservative choice. |
| D7 Literature coverage | 3 | M | Citation list is short (about 10 references). Skovsgaard and Vanclay (2008), Bontemps and Bouriaud (2014) are the conceptual anchors; would benefit from one or two more recent (post-2020) multi-metric productivity studies if they exist. (REVIEWER VERIFY: scan recent FEM/Forestry/JFR for multi-metric productivity reviews 2022-2026.) |
| D8 Interpretation quality | 4 | H | The v0.10b rewrites are mature in tone. The "what survives the correction" framing in NEWS.md is good practice and could be echoed in a §4.7 paragraph titled "What is robust to the SICOND correction." |
| D9 Writing clarity | 4 | M | Generally clear. Some §3.5 paragraphs are dense (200+ words). Few hyphens (compliant with author preference). The Simpson paradox terminology in §4.3 helps readers anchor the correction. |
| D10 Figures and tables | 3 | M | 11 figures is at the upper end of the 6 to 8 guideline. F4 and F5 are diagnostic and should move to supplements; F1 considered for supplements. Main set then drops to 8 figures, on target. |

**Indicative recommendation:** **Minor Revision** at the level of the Diagnostic 1 to 4 calibration anchors.

- Diagnostic 1 (Reject question): No revisions to data collection or fundamental re-framing required. The existing data fully support the central claim after the v0.10b correction.
- Diagnostic 2 (Score pattern): No D1 to D10 scores at 2 or below. D4, D7, D10 at 3 are revision items, not Reject drivers.
- Diagnostic 3 (Constructive Reject): N/A.
- Diagnostic 4 (Identity check): The corrected v0.10b preserves the title, the central thesis, and the SITECLCD headline. The Simpson paradox correction reshaped one paragraph in the abstract and §4.3, but the paper's identity is intact.

## Items for human verification (Aaron's pass)

1. **Confirm Table 2a numbers against multidim_v4/D-series CSVs**: already done in this session, but the manuscript should state which raw CSV underlies each row of Table 2a. Add a footnote: "Source CSVs: D1_sicond_by_sibase, D3_sicond_base50_projected, multidim_v4/." (REVIEWER VERIFY)
2. **Bootstrap CIs for Table 1, Table 3a, Table 2a r values**: ~1 day of additional compute. Consider whether reviewers will demand. FEM convention is forgiving but not universal. (REVIEWER VERIFY)
3. **Citation breadth (D7)**: scan post-2020 multi-metric productivity literature; add 2 to 3 references if found. (REVIEWER VERIFY)
4. **F4 and F5 to supplements**: editorial decision; the choice is between 11 figures (current) and 8 figures (recommended). (REVIEWER VERIFY)
5. **§4.3 "modest calibration shifts" claim**: quantify or remove the magnitude word. (REVIEWER VERIFY)

## Confidential editorial notes (self)

The v0.10b correction was the right call. Catching the Simpson paradox before submission rather than as a reviewer comment after is a clear win. The "what survives the correction" list in NEWS.md is reusable as a §4.7 limitation paragraph if you want to make the rigor visible to reviewers.

The remaining items above are all true Minor Revision items: bootstrap CIs, citation update, figure trim, one paragraph quantification. All are completable in 2 to 3 days of work without affecting the manuscript's identity or claims.

---

**Disclosure:** This self-review was prepared via the manuscript-review skill applied to the author's own work. The structural and consistency checks are automated; all scientific judgments and the recommendation verb are the author's responsibility. The manuscript was processed within a confidential session and was not uploaded to external services.
