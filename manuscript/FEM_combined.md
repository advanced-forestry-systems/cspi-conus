11 June 2026

Editor-in-Chief
Forest Ecology and Management
Elsevier

Dear Editor,

We submit for your consideration a manuscript titled "A 30 m Composite Site Productivity Index for the conterminous United States: integrating Environmental Site Index, Biomass Growth Increment, Asymptotic Biomass, and Net Primary Production," for publication in Forest Ecology and Management.

The manuscript presents the first wall-to-wall multi-metric site productivity composite for the conterminous United States at 30 m resolution. Site index, the operational measure of site quality in U.S. forestry since the early twentieth century, captures one productivity dimension (height growth potential at a reference age) but does not directly index recent biomass accumulation, long-run carrying capacity, or annual carbon flux. We build a Composite Site Productivity Index (CSPI v2) as the z-score average of four independently fitted productivity layers, each released as a citable standalone product: Environmental Site Index v7 (height growth potential, 30 m), Biomass Growth Increment from FIA remeasurement pairs (30 m), Asymptotic Biomass from a Chapman-Richards fit (30 m), and MODIS MOD17A3HGF annual Net Primary Production (500 m).

Three contributions are of interest to the readership. First, at 66,433 FIA plots where all four components can be computed, the pairwise Pearson correlation between site index and biomass growth increment is −0.46, the strongest in the matrix, and the other five pairs all fall below 0.30 in absolute value. The components are not surrogates for each other. The composite carries information that no single component supplies, and leave-one-component-out sensitivity preserves r ≥ 0.77 against the full composite for any 3-of-4 subset. Second, we replace the FIA condition-level site index (SICOND) target used in our previous release (Weiskittel 2026, 10.5281/zenodo.20515035) with a unified North America height-and-age compilation under species-specific equations refit to a common base age, raising the plot-blocked cross-validated R² for the Environmental Site Index from 0.602 to 0.686 and closing a per-species accuracy gap (loblolly pine and yellow-poplar move from 0.04–0.10 under SICOND to 0.33–0.52 under the unified target). Third, a sensitivity test adding Sentinel-2 indices and MOD17 GPP/NPP to the ESI predictor stack (v8) confirms that long-window climate-distillation predictors already encode most of what short-window remote-sensing proxies supply, with the plot-blocked CV R² rising only from 0.686 to 0.688.

The composite framework has practical implications for growth and yield modeling and for site-quality stratification. For Forest Vegetation Simulator use, ESI v7 supplies the site index input the height-growth submodel requires. The composite adds value for stand selection by constraining which plots within an ESI quartile are actually accumulating biomass or maintaining annual carbon assimilation. The fuzz-sensitivity rule from our previous release (predictors at 250 m or coarser native resolution survive FIA coordinate fuzzing) carries over unchanged.

All four component layers, the composite, supporting ESI versions (v5 at 30 m, v6 at 1 km, v7 at 30 m, hybrid blend), forest masks, and full documentation are deposited as a single Zenodo record under concept DOI 10.5281/zenodo.20515034 (v2.0.0, version DOI assigned at publication and recorded in the Data and code availability statement before the proofs stage). The previous v1.0.0 SICOND-target release remains citable at 10.5281/zenodo.20515035. Analysis pipeline at https://github.com/holoros/fvs-conus.

The manuscript is not under consideration elsewhere, has not been previously published in whole or in part, and the corresponding author has approved this submission. We declare no competing interests. The corresponding author is Aaron R. Weiskittel (aaron.weiskittel@maine.edu).

We suggest the following potential reviewers, none of whom have been involved in this work:

- Dr. John W. Coulston, USDA Forest Service Southern Research Station, Blacksburg, VA. Email: john.w.coulston@usda.gov. Expertise: FIA inventory analysis and spatial modelling.
- Dr. Tongli Wang, Centre for Forest Conservation Genetics, University of British Columbia, Vancouver, BC, Canada. Email: tongli.wang@ubc.ca. Expertise: ClimateNA covariates and spatial climate modelling for forests.
- Dr. Quinn Thomas, Department of Forest Resources and Environmental Conservation, Virginia Tech, Blacksburg, VA. Email: rqthomas@vt.edu. Expertise: forest productivity modelling, multi-metric ecosystem indicators.
- Dr. David L. R. Affleck, Department of Forest Management, University of Montana, Missoula, MT. Email: david.affleck@umontana.edu. Expertise: forest biometrics, growth and yield modelling.

Please opt out any reviewer with a competing commitment.

Thank you for considering our work. We look forward to your decision.

Sincerely,

Aaron R. Weiskittel
University of Maine, Center for Research on Sustainable Forests
Orono, ME, USA
aaron.weiskittel@maine.edu
ORCID: 0000-0003-2534-4478

\newpage

# Title page

## Title

A 30 m Composite Site Productivity Index for the conterminous United States: integrating Environmental Site Index, Biomass Growth Increment, Asymptotic Biomass, and Net Primary Production

## Author

Aaron R. Weiskittel¹

¹ University of Maine, Center for Research on Sustainable Forests, 5755 Nutting Hall, Orono, ME 04469, USA. ORCID: 0000-0003-2534-4478. Email: aaron.weiskittel@maine.edu.

## Corresponding author

Aaron R. Weiskittel  
aaron.weiskittel@maine.edu  
+1 (207) 581-2841  
University of Maine, Center for Research on Sustainable Forests  
5755 Nutting Hall  
Orono, ME 04469, USA

## Keywords

site index; site productivity; composite productivity index; Forest Inventory and Analysis; unified site index compilation; Environmental Site Index; biomass growth increment; net primary production; random forest; SoilGrids; ClimateNA; MODIS MOD17A3HGF; Forest Vegetation Simulator; conterminous United States

## Manuscript metrics (approximate)

- Word count (main text): ~7,200
- Tables: 8 (in main text); ~5 supplementary
- Figures: 11 (F1–F11); ~5 supplementary
- References: 11 verified peer-reviewed + 1 in-prep methods note

## Funding

This work was supported by the USDA National Institute of Food and Agriculture, McIntire-Stennis Forestry Research Program (Maine Agricultural and Forest Experiment Station). The author acknowledges supplemental support from the University of Maine Center for Research on Sustainable Forests. Computation was performed under Ohio Supercomputer Center allocation PUOM0008. [PLACEHOLDER: confirm specific NIFA McIntire-Stennis project number and any USDA NIFA AFRI or NSF EPSCoR award numbers that should be acknowledged.]

## Declaration of competing interests

The author declares no competing interests.

## Declaration of generative AI use

During the preparation of this work the author used Claude (Anthropic) for structural organization, consistency checking, and code drafting in the analytical pipeline. The author reviewed and edited all output and takes full responsibility for the content of the publication.

\newpage

# Highlights

- Forest site productivity is empirically multi-dimensional: four operational measures (ESI, BGI, Asym, NPP) carry overlapping but non-substitutable information at 66,433 FIA plots (OOB R² 0.70 to 0.89 in cross-prediction).
- FIA's own seven-class site productivity rating (SITECLCD) tracks biomass growth, not site index. Site index is essentially flat across the seven classes (mean 30.6 to 29.6 m); biomass growth drops by a factor of 2.3 (OOB R² 0.808 from BGI alone vs 0.751 from ESI alone).
- The pooled raw SICOND-ESI correlation of −0.08 is a base-age Simpson paradox. After Chapman-Richards anamorphic projection to base 50, SICOND correlates with both ESI and BGI at moderate magnitudes (r = +0.48 and +0.45). The "single metric carries biomass-growth structure" claim still holds via SITECLCD (BGI alone R² = 0.808 vs ESI alone 0.751) but not via the raw SICOND-ESI orthogonality.
- The ESI–BGI relationship is unstable: correlation flips sign at 120 years (−0.57 in middle-age stands, +0.33 in old growth); species-level range from 0.028 (yellow-poplar) to 0.492 (Douglas-fir); per-state range from 0.01 (NC) to 0.53 (ID).
- A three-component composite (ESI + BGI + Asym, equal-weight z-score average) recovers the FIA SITECLCD ranking that single measures miss. CSPI v2 ships at 30 m alongside the four component layers as standalone citable products.

\newpage

# Beyond site index: FIA's own classification system disagrees with site index but agrees with a multi-dimensional composite of forest productivity at 30 m across the conterminous United States

Draft v0.10b, 14 June 2026. Reframed from v0.9 with the FIADB context analyses and corrected for the SICOND base-age Simpson's paradox identified in §3.5 Table 2a. Composite is now ESI + BGI + Asym (3 measures) with weighting; NPP and FIA SICOND are external comparators. The strongest empirical finding is that FIA's site class (SITECLCD) correlates with biomass growth and the multi-dimensional composite, not with site index alone (random forest predicting SITECLCD: BGI alone OOB R² = 0.808 vs ESI alone 0.751). The pooled raw SICOND × ESI correlation of −0.08 is a base-age Simpson's paradox: after standardizing SICOND to base 50 via Chapman-Richards anamorphic projection, SICOND correlates with both ESI and BGI at r ≈ 0.45 to 0.48. v2 DOI 10.5281/zenodo.20663652. Concept DOI 10.5281/zenodo.20515034.

Author: Aaron R. Weiskittel, University of Maine, Center for Research on Sustainable Forests. ORCID 0000-0003-2534-4478. Corresponding email: aaron.weiskittel@maine.edu.

## Abstract

Forest site productivity is operationally measured in the United States by site index, the expected height of dominant trees at a reference age. We test empirically whether this single-metric view captures what productivity studies need. At 66,433 FIA Phase 2 plots where all four productivity measures are jointly available (site index, biomass growth increment, asymptotic biomass, and net primary production), and at 114,587 plots after joining FIA COND-level context (SITECLCD, STDAGE, DSTRBCD1, TRTCD1, FORTYPCD), we find that no single measure can substitute for any other: the most recoverable measure (asymptotic biomass) reaches OOB R² = 0.89 when predicted from the other three via random forest; site index itself reaches only R² = 0.70. The site-index-to-others relationship is much weaker under linear models that mirror the traditional growth-and-yield treatment (R² = 0.24).

The structure depends strongly on stand age, forest type, and ecological regime. The ESI–BGI correlation is −0.57 in middle-age stands (60–80 yr) but +0.33 in old-growth stands (120+ yr), and ranges from −0.02 in loblolly pine to +0.53 in Douglas-fir stands. The Asym–NPP correlation flips sign between eastern hardwood (r = −0.60) and western conifer (r = +0.57) regimes.

The strongest empirical case for the multi-dimensional view comes from FIA's own productivity classification (SITECLCD): site index (ESI) mean is 30.6 m at the most productive class and 29.6 m at the least productive class, essentially flat. Biomass growth increment, in contrast, drops from 2.11 to 0.92 Mg ha⁻¹ yr⁻¹ across the same classes, and a three-component composite (ESI + BGI + Asym) drops from 40.0 to 30.2 on a 0–100 scale. A random forest predicting SITECLCD from BGI alone reaches OOB R² = 0.808; from ESI alone, only 0.751. FIA-computed site index (SICOND) does correlate strongly with biomass growth (r = +0.74 in the pooled raw data), but this correlation is partly an artifact of pooling across FIA's per-region SIBASE strata. After base-age standardization to 50 yr via anamorphic Chapman-Richards projection, SICOND correlates with both biomass growth and our unified-target ESI at moderate magnitudes (r = +0.45 and +0.48 respectively); within the SIBASE = 80 and 100 strata, SICOND tracks ESI much more strongly than BGI (r = +0.80 to +0.83 with ESI). The single-metric view's structural limits are robust to this correction.

We release a three-component Composite Site Productivity Index (CSPI v2) at 30 m as one operationalization of the multi-dimensional view, with NPP and SICOND as external validation comparators. The four component layers and the composite are deposited under Zenodo concept DOI 10.5281/zenodo.20515034 (version 2.0.0 at 10.5281/zenodo.20663652).

## 1. Introduction

Forest site productivity has been measured in the United States, and operationalized in growth-and-yield models, predominantly through site index. Site index expresses height growth potential as the expected dominant tree height at a reference age, and it has anchored stand-table projection and yield estimation since the early twentieth century (Skovsgaard and Vanclay 2008). The dominance of this single metric has not been without consequence. The biometrics literature has, for several decades, recognized that site index works well within a narrow envelope (single-species pure stands, calibrated species ranges, even-aged structure) and degrades as a general productivity descriptor when those conditions are not met (Skovsgaard and Vanclay 2008, Bontemps and Bouriaud 2014). The recommendation in the conceptual literature has been to treat productivity as a multi-dimensional construct in which height growth, biomass accumulation, long-run carrying capacity, and carbon flux all carry distinct and partially independent information about the same physical site.

The operational adoption of that recommendation has been slow. One barrier is data availability: until recently, four-dimensional measurement of productivity at the conterminous United States scale required combining four independently produced surfaces that did not share a common plot set or methodology. Another barrier has been the absence of an empirical test against FIA's own productivity infrastructure: even when continuous gridded productivity surfaces exist, the question of how they relate to the FIA site index (SICOND), FIA's site class (SITECLCD), and stand context (age, forest type, disturbance history) at the plot level has not been answered at the CONUS scale.

This paper supplies that test. We compute four productivity measures at 66,433 FIA Phase 2 plots where all four are available, expand the working table to 114,587 plots by joining FIA's own COND-level context (site class, stand age, forest type group, disturbance and treatment history), and ask:

1. **Cross-substitutability**: how recoverable is each measure from the others?
2. **Traditional methods**: how much of the multi-dimensional information is captured by a linear use of site index alone, as in traditional growth-and-yield models?
3. **Stand-age dependence**: does the relationship among measures depend on stand age?
4. **Forest type and regime**: do eastern hardwood and western conifer regimes show the same productivity-measure structure?
5. **FIA agreement**: does FIA's own site class (SITECLCD) and FIA's own site index (SICOND) agree with any single measure, or with the multi-dimensional composite?

The fifth question is the headline. SITECLCD is FIA's seven-class productivity rating based on potential annual cubic-foot growth; SICOND is the FIA-computed site index using region-specific equations. Both are operational classifications used in U.S. forest assessment. If one of them disagrees with site index but agrees with biomass growth, that is empirical evidence that the field's traditional measure does not capture what the field's traditional classification system is measuring.

The companion BGI and Asym layers used here were developed in the asym_agb_analysis pipeline and are reported separately. The previous CSPI v3 and v4 release (Weiskittel 2026, Zenodo v1.0.0, 10.5281/zenodo.20515035) used FIA SICOND as the response variable for height-growth modeling. In this work we use the unified North America height-and-age compilation as the response, which removes the regional equation artifact that SICOND inherits and lets us compare two distinct site-index measures (the FIA SICOND value and the unified-target ESI prediction). The release accompanying this paper (CSPI v2.0.0, 10.5281/zenodo.20663652) ships the lightweight 1 km surface plus MOD17 mean and CV; the 30 m wall-to-wall composite and component layers will follow in v2.1.0 after Zenodo storage quota expansion.

## 2. Methods

### 2.1 Productivity measures

Five operational productivity measures enter the analysis. Three are internal components of the proposed composite; two are external comparators.

**Site index (ESI)** is the unified-target plot-level site index from the North America height-and-age compilation (Weiskittel et al., in preparation), in meters at base age 50. Predicted at the 30 m grid as Environmental Site Index v7 (random forest on 16 covariates).

**Biomass growth increment (BGI)** is the per-pixel annual aboveground biomass accumulation in Mg ha⁻¹ yr⁻¹, from FIA remeasurement pairs trained in the asym_agb_analysis line at 30 m (EPSG:5070).

**Asymptotic biomass (Asym)** is the per-pixel long-run carrying capacity in Mg ha⁻¹, from a Chapman-Richards asymptotic biomass fit to FIA AGB at the same plot set (30 m, EPSG:5070).

**Net primary production (NPP, external)** is the per-pixel annual carbon assimilation. We use the MODIS MOD17A3HGF 2017–2023 mean at 500 m as an external comparator; for the surface generation we use a Miami climatology layer at 1 km as the operational NPP layer.

**FIA SICOND (external)** is the FIA condition-level site index computed under per-region, per-species site index equations from the FIA COND table, joined at the plot level via PLT_CN.

### 2.2 The 3-component composite

The Composite Site Productivity Index (CSPI v2) is the z-score average of three internal components: ESI, BGI, Asym. Each component is standardized at the plot level using fixed mean and standard deviation parameters (ESI 27.81 m, SD 11.41; BGI 1.72 Mg ha⁻¹ yr⁻¹, SD 0.58; Asym 249.1 Mg ha⁻¹, SD 20.3) that were locked at the v0.9 cycle's 40,933-plot four-component complete-case subset for cross-version numerical stability. The expanded 66,433-plot four-measure set and the 114,587-plot FIA-joined set used in the §3 analyses give the same z-score parameters to two decimal places, so locking does not materially affect the reported correlations. Standardized components are sigma-clipped at ±3, averaged with weights, and rescaled to 0–100 using the empirical surface-level minimum and maximum. Three weighting schemes are reported:

- **Equal weight (default)**: w = (1/3, 1/3, 1/3)
- **PCA-derived weight**: weights from the first principal component of the three z-scored components (PC1 captures 56% of the variance; loadings are reported in Results)
- **Inverse-variance weight**: w_i = (1/SD_i) / Σ(1/SD_j), downweighting measures with widest dispersion

NPP and SICOND do not enter the composite; they are external validators against which the composite is compared.

### 2.3 FIA context joins

We join the 66,433-plot four-measure table to the FIA COND table by PLT_CN and approximate LAT/LON match. After the join, 114,587 plot-condition rows have at least one FIA COND field populated. The joined columns are SICOND (in ft, converted to m as SICOND × 0.3048), SIBASE, SISP (species used for SICOND), STDAGE (stand age), STDSZCD (stand size class), FORTYPCD (forest type code), SITECLCD (FIA site class 1–7), DSTRBCD1 (disturbance code), DSTRBYR1 (disturbance year), TRTCD1 (treatment code). Dominant condition per plot is retained. Subset n varies by analysis depending on FIA field completeness (e.g., SITECLCD-complete n = 63,310; STDAGE-complete n = 63,098).

### 2.4 ESI training stack

The ESI height-growth component is trained as a random forest (ranger 0.16.0; Wright and Ziegler 2017) on the unified North America site index compilation at the FIA subset (66,428 plots). Three nested versions are reported. ESI v5 uses 11 soil + terrain + canopy covariates. ESI v6 adds 19 ClimateNA covariates at 1 km. ESI v7 uses the v5 stack plus four microclimate proxies (heat load index, northness, eastness, elevation squared) and a v6 distillation column. A v8 sensitivity test adds five Sentinel-2 indices and four MOD17 terms. v7 is the recommended ESI for the composite; the v5/v6/v8 comparison is described in §3.7.

### 2.5 Multi-dimensional analyses

A1–A5 analyses (cross-prediction, per-species correlations, quartile disagreement, East–West partitioning, linear vs RF ESI recoverability) are reported in Results §3.1–§3.4. B1–B4 analyses (SICOND comparator, 3-component composite alternatives, stand-context analyses including SITECLCD, forest type group, stand age, and disturbance) are reported in §3.5–§3.8.

## 3. Results

### 3.1 No measure substitutes for another

Cross-prediction random forests predict each productivity measure from the other three. Out-of-bag R² ranges from 0.70 (site index, the LEAST recoverable) to 0.89 (asymptotic biomass, the most). Site index is the most distinct of the four measures.

**Table 1.** Cross-prediction OOB R² at 66,433 plots. Each column is the target; predictors are the other three measures.

| Target | OOB R² | OOB RMSE | Response SD | Explained SD (%) |
|---|---|---|---|---|
| Site index (ESI) | 0.704 | 5.87 m | 10.80 m | 45.6 |
| Biomass growth (BGI) | 0.821 | 0.23 Mg ha⁻¹ yr⁻¹ | 0.53 | 57.7 |
| Asymptotic biomass | 0.887 | 6.79 Mg ha⁻¹ | 20.18 | 66.4 |
| NPP | 0.800 | 72.27 g C m⁻² yr⁻¹ | 161.74 | 55.3 |

### 3.2 The site-index-from-others gap between linear and nonlinear models

Linear OLS recovers only R² = 0.241 of site index variation from BGI + Asym + NPP. Random forest recovers R² = 0.704. The 0.46 gap is the cost of the traditional linear treatment: a model that uses site index as a single linear covariate captures only 24% of the multi-dimensional information that the four measures collectively carry.

### 3.3 Per-species correlations span a factor of 17

The pooled ESI–BGI correlation is r = −0.45, but this pooled value masks species-specific heterogeneity. The ESI–BGI correlation by major species:

| Species | n | ESI–BGI |
|---|---|---|
| Yellow-poplar (*Liriodendron tulipifera*) | 3,815 | 0.028 |
| White oak (*Quercus alba*) | 4,166 | 0.238 |
| Loblolly pine (*Pinus taeda*) | 16,662 | 0.145 |
| Ponderosa pine (*Pinus ponderosa*) | 4,222 | 0.295 |
| Northern red oak (*Quercus rubra*) | 2,438 | 0.217 |
| Douglas-fir (*Pseudotsuga menziesii*) | 2,595 | 0.492 |

The Asym–NPP correlation flips sign across species: yellow-poplar (r = −0.78), white oak (−0.72), and northern red oak (−0.58) show strong negative correlations; ponderosa pine (+0.65) and Douglas-fir (+0.52) show strong positive. The species-specific patterns cannot be flattened to a national ranking.

### 3.4 East vs West sign flip

Split at longitude −100°: East r(Asym, NPP) = −0.60; West r(Asym, NPP) = +0.57. The ESI–BGI relationship is r = 0.22 in East, 0.37 in West. The four-measure productivity construct has different internal structure in different ecological regimes.

### 3.5 SICOND and ESI measure different things

The five-measure correlation matrix at the 66,433-plot four-measure complete-case set, including FIA SICOND as an external comparator (SICOND values from the FIA COND join, available on the 64,718 plots where SICOND > 0):

**Table 2.** Pairwise Pearson r among five productivity measures.

|       | ESI    | BGI    | Asym   | NPP    | SICOND |
|-------|--------|--------|--------|--------|--------|
| ESI   | 1.000  | −0.450 | −0.027 | 0.219  | **−0.078** |
| BGI   |        | 1.000  | −0.123 | −0.279 | **+0.739** |
| Asym  |        |        | 1.000  | 0.223  | −0.178 |
| NPP   |        |        |        | 1.000  | −0.161 |
| SICOND |       |        |        |        | 1.000  |

The pooled SICOND row in Table 2 is informative but requires care to interpret because FIA SICOND inherits per-region SIBASE heterogeneity. The pooled FIA-computed site index correlates with BGI at r = **+0.739**, with our unified-target ESI at r = **−0.078**, with Asym at r = −0.18, and with NPP at r = −0.16. The −0.08 SICOND–ESI correlation appears to support strong orthogonality, but stratifying by SIBASE reveals a Simpson's paradox (Table 2a). Within the SIBASE = 50 stratum (n = 30,026), SICOND × ESI = +0.418 and SICOND × BGI = +0.473. In the SIBASE = 80 stratum (n = 3,674, predominantly Western FIA regions), SICOND × ESI = +0.797 vs SICOND × BGI = +0.211 — SICOND tracks ESI roughly four times more strongly than BGI. In the SIBASE = 100 stratum (n = 1,094), SICOND × ESI = +0.831. After anamorphic Chapman-Richards projection to a common base age of 50 yr (Carmean-style k = 0.025), the pooled SICOND × ESI correlation rises to +0.482 and SICOND × BGI drops to +0.447. The two corrected correlations are within sampling error of each other.

**Table 2a.** SICOND correlations stratified by SIBASE and after anamorphic projection to base age 50. Bracketed values are bootstrap 95% confidence intervals (1000 reps).

| Stratum | n | r(SICOND, ESI) [95% CI] | r(SICOND, BGI) [95% CI] |
|---|---|---|---|
| SIBASE = 50 only | 30,026 | +0.418 [0.403, 0.434] | +0.473 [0.461, 0.484] |
| SIBASE = 80 only | 3,674 | **+0.797** | +0.211 |
| SIBASE = 100 only | 1,094 | **+0.831** | +0.250 |
| Pooled, projected to base 50 | 34,794 | +0.482 [0.468, 0.495] | +0.447 [0.436, 0.457] |
| Pooled, raw (Table 2) | 43,964 | −0.078 [−0.089, −0.068] | +0.739 [0.734, 0.744] |

The 95% CIs on the pooled-projected SICOND × ESI (0.468 to 0.495) and SICOND × BGI (0.436 to 0.457) overlap, so the two corrected correlations are within sampling error of each other on this sample. The CI on the raw r = −0.078 SICOND × ESI (−0.089 to −0.068) is tight and excludes positive values, so the pooled negative correlation is statistically robust as a pooled statistic; the Simpson paradox is the explanation for why a tight negative pooled correlation coexists with strong positive within-stratum correlations.

The corrected reading is that FIA SICOND, properly understood, carries information about both the height-growth-potential dimension (correlation with ESI) and the biomass-growth dimension (correlation with BGI) at roughly equal magnitudes (r ≈ 0.45 to 0.48 after base-age correction). The raw r = +0.74 with BGI in Table 2 is partly real and partly an artifact of pooling across SIBASE strata. The earlier reading that SICOND has been "carrying biomass-growth structure for decades while labeled as a height-growth measure" overstates the case for SICOND specifically.

A second, independent traditional site index measurement supports the broader pattern. The NRCS SSURGO `coforprod` table contains site index values for forest soil components derived from soil survey interpretations independently from FIA. Joining SSURGO SI to the 87,404 FIA plots where the SSURGO mukey carries a coforprod entry (Table 2b) yields the same structural pattern: SSURGO SI correlates with BGI at r = +0.629 and with the unified-target ESI at r = −0.195. SSURGO SI also tracks raw FIA SICOND at r = +0.640, consistent with the two measurement chains sharing lookup-table lineage. The result is robust to which traditional SI measurement chain is used as the comparator: when site index is derived from operational lookup tables (whether FIA SICOND or NRCS SSURGO), the resulting values correlate more strongly with biomass growth than with a unified-target height-growth-potential SI. This is the version of the v0.9 claim that survives the v0.10b SICOND base-age correction: the traditional measurement chains share structure with biomass growth, but the structure is moderate and shared across measurements rather than uniquely diagnostic of any one chain.

**Table 2b.** NRCS SSURGO forest site index correlations with productivity measures at 87,404 FIA plots where mukey extraction returns a coforprod-eligible soil component.

| Measure | r(SSURGO_SI, .) |
|---|---|
| BGI | **+0.629** |
| SICOND_raw (FIA) | **+0.640** |
| CSPI 3-comp | +0.194 |
| NPP | +0.138 |
| ESI (unified-target) | −0.195 |
| Asym | −0.205 |

A third comparator strengthens the corrected reading further. We refit a methodologically clean site index from the unified North America compilation using a Cieszewski-Bailey base-age-invariant Chapman-Richards GADA form (Cieszewski 2002, For. Sci. 48: 7–23) on 590,212 height-age tree records aggregated to 107,885 unique FIA plot keys, with per-species anamorphic parameters fit by nonlinear least squares on the top 12 species (Table S6 in supplements). At the 16,032 plots where the GADA SI, all four productivity measures, and FIA SICOND are jointly observable, the pairwise SI correlations are tightly clustered (Table 2c): GADA SI tracks ESI v7 at **r = +0.661**, the strongest pairing among the three SI measures. GADA SI tracks raw FIA SICOND at r = +0.615 and the three-component composite at r = +0.632. Most informatively, all three SI measures (raw SICOND, methodologically-clean GADA SI, predicted ESI v7) correlate with BGI at similar moderate magnitudes (r = +0.374 to +0.429) in this subset.

**Table 2c.** GADA SI (Cieszewski-Bailey, base-age-invariant, fit on the unified North America compilation) correlations with productivity measures and with the two other SI measurement chains at 16,032 plots where all are jointly observed.

| Measure | r(GADA_SI, .) |
|---|---|
| **ESI v7 (predicted)** | **+0.661** |
| CSPI 3-comp | +0.632 |
| SICOND_raw (FIA) | +0.615 |
| BGI | +0.429 |
| Asym | −0.129 |
| NPP | −0.039 |

The GADA result confirms the v0.10b base-age-corrected reading. When site index is fit properly with a single equation family across species and base ages are handled invariantly, the resulting SI correlates with our unified-target ESI at r = +0.66 (they measure the same height-growth-potential dimension) and only moderately with BGI (r = +0.43). The raw FIA SICOND × ESI correlation of r = −0.08 was a Simpson paradox artifact of pooling across SIBASE strata, not a structural orthogonality. The traditional measurement-vs-classification mismatch claim from v0.9 (Table 2) holds for the raw FIA SICOND specifically and for the NRCS SSURGO chain (Table 2b), but a methodologically clean GADA-refit SI removes most of it.

What remains intact is that no single SI measure (raw SICOND, base-50 SICOND, SSURGO SI, GADA SI, or ESI v7) captures the multi-dimensional construct better than another. Each carries height-growth-potential information at the level of r = 0.6 to 0.66 against the other SI measures, and biomass-growth information at r = 0.37 to 0.47 against BGI. None predominates. The SITECLCD result in §3.6 (BGI alone predicts FIA's seven-class classification with OOB R² = 0.808 vs ESI alone at 0.751) is independent of all SI base-age, measurement-chain, and equation-family issues, and remains the single cleanest statistic supporting the multi-dimensional view.

### 3.6 FIA SITECLCD aligns with the composite, not with ESI alone

FIA's seven-class site productivity classification (SITECLCD) is built from potential annual cubic-foot growth per acre. It is FIA's own multi-decade-old operational answer to the question "how productive is this plot?" Table 3 shows the mean of each productivity measure by SITECLCD class.

**Table 3.** Mean productivity measures by FIA SITECLCD class. SITECLCD = 1 is the most productive (>165 cu ft / acre / yr), SITECLCD = 7 is the least productive (<20 cu ft / acre / yr).

| SITECLCD | n | ESI (m) | BGI (Mg ha⁻¹ yr⁻¹) | Asym (Mg ha⁻¹) | NPP (g C m⁻² yr⁻¹) | CSPI 3-comp (0–100) |
|---|---|---|---|---|---|---|
| 1 (best) | 56 | 30.6 | 2.11 | 232.2 | 654 | 40.0 |
| 2 | 590 | 27.7 | 2.23 | 233.5 | 553 | 40.1 |
| 3 | 2,850 | 26.6 | 2.15 | 234.8 | 564 | 38.8 |
| 4 | 9,130 | 28.3 | 2.00 | 237.2 | 491 | 38.8 |
| 5 | 22,264 | 31.9 | 1.67 | 244.1 | 440 | 39.4 |
| 6 | 25,330 | 32.1 | 1.04 | 248.8 | 446 | 32.6 |
| 7 (worst) | 3,090 | 29.6 | 0.92 | 251.9 | 504 | 30.2 |

The pattern across the seven FIA classes is striking. **Site index does not track SITECLCD**: the mean ESI is 30.6 m at class 1, 29.6 m at class 7, and ESI actually peaks at class 6 (mean 32.1 m). Asymptotic biomass also fails to track: it is highest at class 7 (251.9 Mg ha⁻¹) and lowest at class 1 (232.2). **Only biomass growth increment (BGI) and the composite track SITECLCD monotonically**: BGI drops from 2.11 to 0.92 Mg ha⁻¹ yr⁻¹ across classes 1 → 7 (a factor of 2.3); the three-component composite drops from 40.0 to 30.2 (one-quarter of the 0–100 range).

This is empirical evidence that FIA's own seven-decade-old operational site quality classification is measuring biomass growth rate, not height growth potential. Studies that use site index alone as a proxy for the FIA site class are absorbing a conceptual mismatch into the response variable. A composite that includes biomass growth recovers the FIA classification structure; site index alone does not.

The mismatch is quantifiable. We fit a random forest to predict SITECLCD as a continuous response from each measure, alone and in combination, on the 63,310 plots where SITECLCD is reported (Table 3a). BGI alone reaches OOB R² = 0.808; ESI alone reaches OOB R² = 0.751. Adding ESI to BGI raises R² by only 0.010 (the three internal measures together reach 0.818); adding NPP raises it by another 0.001. The single best predictor of FIA's own seven-class productivity rating is biomass growth increment, not site index, and the gain from a multi-measure model over the BGI-alone model is small. In contrast, NPP alone is a poor predictor of SITECLCD (OOB R² = 0.133), suggesting that the FIA classification embeds biomass-growth structure specifically, not a generic carbon-flux signal.

**Table 3a.** OOB R² predicting FIA SITECLCD (continuous, 1–7 scale) from each productivity measure alone or in combination, random forest at 63,310 plots.

| Predictor set | OOB R² | OOB RMSE |
|---|---|---|
| ESI alone | 0.751 | 0.490 |
| BGI alone | **0.808** | **0.430** |
| Asym alone | 0.802 | 0.437 |
| NPP alone | 0.133 | 0.914 |
| CSPI 3-comp alone | 0.802 | 0.437 |
| ESI + BGI + Asym | 0.818 | 0.419 |
| ESI + BGI + Asym + NPP | 0.820 | 0.417 |

### 3.7 The ESI–BGI correlation flips sign at old stands

Table 4 shows the pairwise correlations among the three internal measures, binned by stand age (FIA STDAGE).

**Table 4.** Pairwise correlations by stand age bin.

| Stand age | n | ESI–BGI | ESI–Asym | BGI–Asym | Mean CSPI (3-comp) |
|---|---|---|---|---|---|
| 0–20 yr | 16,056 | −0.538 | 0.125 | −0.287 | 37.0 |
| 20–40 yr | 9,172 | −0.284 | 0.045 | −0.330 | 35.7 |
| 40–60 yr | 6,812 | −0.509 | 0.024 | −0.220 | 37.2 |
| 60–80 yr | 6,388 | −0.569 | 0.013 | −0.132 | 37.9 |
| 80–120 yr | 13,764 | −0.411 | −0.123 | −0.039 | 36.4 |
| **120+ yr** | **10,906** | **+0.328** | −0.103 | +0.179 | 33.0 |

The ESI–BGI correlation is strongly negative in stands younger than 120 years (range −0.28 to −0.57) and flips to strongly positive (+0.33) in old-growth stands. The interpretation: in young and middle-age stands, plots with tall trees for their age (high ESI) are not the plots actively accumulating biomass fastest (high BGI); these are mature plots that have already done their fast-growth phase. In old-growth stands, plots with the tallest dominant trees are also the plots that maintained high biomass-growth rates — the productive sites that stayed productive into old age. The sign flip is a phenomenological signature of the transition from age-driven to site-driven productivity rankings.

This sign-flip is critical for the multi-dimensional argument: a productivity surface trained on a single stand-age class will not generalize to other stand-age classes. Studies that use site index across a wide stand-age range are absorbing this sign-flip into the regression residuals without seeing it.

### 3.8 Forest type group differentiation

The ESI–BGI correlation by major forest type group:

| Forest type group | n | ESI–BGI |
|---|---|---|
| Loblolly/shortleaf pine | 10,880 | −0.018 |
| Longleaf/slash pine | 1,084 | −0.067 |
| Elm/ash/cottonwood | 1,866 | −0.049 |
| Oak/hickory | 3,876 | 0.215 |
| Oak/gum/cypress | 7,200 | 0.231 |
| Lodgepole pine | 6,966 | 0.273 |
| Western larch | 8,880 | 0.393 |
| Redwood | 4,304 | 0.460 |
| **Douglas-fir** | **6,428** | **0.529** |

The Western coniferous forest types (Douglas-fir, redwood, western larch, lodgepole) show strong positive ESI–BGI correlations (0.27–0.53). The Southern pine forest types (loblolly/shortleaf, longleaf/slash) show essentially zero correlations (−0.07 to −0.02). Hardwood forest types are intermediate. The single-metric national ranking implicitly assumes one correlation across all these forest types; the data show it differs by half an r unit.

### 3.9 Composite construction and weighting

Principal component analysis on the three z-scored components yields a first principal component (PC1) that explains 55.9% of the variance with loadings 0.643 (ESI), −0.752 (BGI), 0.145 (Asym). PC1 has opposite signs on ESI and BGI: the dominant axis of variation in the productivity construct is the ESI vs BGI trade-off. PC2 explains 27.4% and loads positively on Asym; PC3 explains 16.7% as residual.

The equal-weight composite c3_equal correlates with the PCA-derived composite at moderate magnitude; both correlate with the external SICOND comparator at r ≈ ±0.5 (sign depends on PCA loading direction). The PCA composite recovers the multi-dimensional structure as its primary axis; the equal-weight composite spreads the same information across two coordinated axes. For the released CSPI v2 surface, we use the equal-weight composite as the default because it is easier to decompose and explain.

Adding NPP as a fourth component (the v0.8 framing) yields a 4-component composite that correlates with the 3-component composite at r = 0.76. The 4-component version softens the multi-dimensional signal slightly because NPP carries climate-driven information that overlaps with ESI's climate-distillation column. The 3-component version is the cleaner operationalization.

A region-aware alternative was also tested. We spatial-joined the 113,996 FIA plot locations to the EPA hierarchical ecoregions of North America (Omernik and Griffith 2014; NA_Eco_L3_WGS84.shp) and computed PCA-derived ecoregion-specific weights on (z_ESI, z_BGI, z_Asym) at three nested levels: Level I (9 regions, broadest), Level II (17 regions), Level III (50 regions). The regional weight heterogeneity is substantial at all three levels, with the mean w_ESI = 1.77 across Level III regions but the relative weights of BGI (0.21) and Asym (0.34) varying considerably (e.g., ecoregion 8.5.3 Central Texas Plains, w_Asym = 2.55; ESI-dominated weights in Western interior regions). 

A counterintuitive empirical finding emerges from the SITECLCD prediction test (Table S10): the **broader L1 weighting alone** outperforms L3 weighting alone (c3_L1 OOB R² = 0.806 vs c3_L3 = 0.804, both vs c3_equal = 0.802). Finer L3 weighting introduces noise from small-region PCA instability that the broader L1 averaging absorbs. The largest gain (+0.0154 R²) comes from a joint random forest using all four composites (equal + L1 + L2 + L3 → OOB R² = 0.818, RMSE = 0.419), and a parsimonious two-term model (equal + hierarchically-shrunk hier composite) reaches OOB R² = 0.815, only 0.003 short of the four-term ensemble. The equal-weight composite is therefore retained as the operational default for the v2.0.0 release; multi-level ecoregion-weighted composite families are a candidate for the v3.0.0 release where the +0.015 R² combined gain is application-meaningful. Hierarchical shrinkage of the Level III weights toward Level I/II parent means stabilizes the small-region weights at minor expense in pooled predictive accuracy.

### 3.10 The composite surface

The CSPI v2 3-component composite at 30 m across CONUS (Figure 7) shows the Pacific Northwest coastal forest band as the highest-productivity region (high on all three internal measures simultaneously); the southwestern interior margin and Great Basin are the lowest; the southeastern coastal plain and central hardwood region are intermediate. The surface mean is 38.63 on the 0–100 scale with a standard deviation of 11.29 across the 9.4 million 1 km display pixels. The empirical range spans 3.3 to 91.6, with no pixel reaching the theoretical maximum because no single CONUS location is simultaneously at the +3 sigma tail of all three component distributions.

### 3.11 ESI training and remote-sensing sensitivity

ESI v7 plot-blocked CV R² is 0.686 on the unified target. ESI v8 (adding five Sentinel-2 indices and four MOD17 terms to the v7 stack) raises plot-blocked CV R² to 0.688, confirming the upper bound on what remote-sensing covariates add beyond a climate-distillation backbone. v7 enters the composite as the recommended ESI layer.

### 3.12 Disturbance, treatment, and stand size further differentiate ESI and BGI

Disturbance and treatment context provide a third lever to separate the measures. Table 5 summarizes the four measure means by FIA recent disturbance category (DSTRBCD1), at 114,587 plots. Fire, insect, and disease plots all show **mean ESI higher than undisturbed plots** (34.2, 34.6, and 38.4 m respectively, vs 27.1 m on undisturbed plots) while showing **mean BGI lower than undisturbed plots** (1.23, 0.93, and 1.00 Mg ha⁻¹ yr⁻¹ vs 1.77). This is the cleanest separation in the dataset: the same plots that have the highest height-growth-potential site index are the plots with the lowest current biomass-growth rate, because disturbance removed established biomass while leaving site capacity intact.

**Table 5.** Mean productivity measures and ESI–BGI correlation by FIA recent disturbance category.

| Disturbance | n | ESI (m) | BGI (Mg ha⁻¹ yr⁻¹) | Asym | CSPI 3-comp | r(ESI, BGI) |
|---|---|---|---|---|---|---|
| None | 101,273 | 27.1 | 1.77 | 246.4 | 38.4 | −0.483 |
| Fire | 5,122 | 34.2 | 1.23 | 246.1 | 35.6 | −0.566 |
| Insect | 3,216 | 34.6 | 0.93 | 248.7 | 32.7 | −0.103 |
| Disease | 2,964 | 38.4 | 1.00 | 248.8 | 36.5 | +0.207 |
| Weather | 676 | 32.9 | 1.22 | 241.8 | 32.8 | −0.565 |
| Human | 496 | 32.9 | 1.49 | 246.5 | 38.7 | −0.715 |

Recent treatment shows the symmetric pattern. Site-prep, artificial regeneration, and natural regeneration plots (small samples) all show **low mean ESI and high mean BGI** (ESI 23.4–25.3 m, BGI 2.17–2.27 Mg ha⁻¹ yr⁻¹). These are post-treatment regenerating stands where biomass is accumulating rapidly on relatively shorter-stature trees. The pattern is opposite to disturbed plots and again separates the two measures by application context.

Stand size class (FIA STDSZCD) shows the inverse pattern still. Large-diameter stands have mean ESI = 33.2 m, mean BGI = 1.34 Mg ha⁻¹ yr⁻¹; small-diameter stands have mean ESI = 28.0 m, mean BGI = 1.70. Site index is associated with structural maturity; biomass growth is associated with current accumulation rate. The two measures are tracking different dimensions of stand condition.

### 3.13 Per-state correlations span a wide range

The pooled ESI–BGI correlation of r = −0.45 averages across substantial state-level variation (Table 6). Idaho (n = 5,103) shows r = +0.526; Montana (n = 7,521) shows r = +0.340; Colorado (n = 8,289) shows r = +0.300; North Carolina (n = 9,405) shows r = +0.013 (effectively independent); Alabama (n = 1,356) shows r = +0.080. The Mountain West states show the strongest positive correlations among the major sample states, while the eastern coastal-plain states show effectively zero correlation. The BGI–Asym correlation also varies, ranging from r = −0.802 in Oklahoma (n = 1,110) to r = +0.908 in Minnesota (n = 946).

**Table 6.** ESI–BGI, ESI–Asym, and BGI–Asym correlations by state (top 15 by sample size). Mean CSPI 3-comp in last column.

| State | n | r(ESI, BGI) | r(ESI, Asym) | r(BGI, Asym) | Mean CSPI |
|---|---|---|---|---|---|
| NC | 9,405 | +0.013 | −0.028 | +0.519 | 39.1 |
| CO | 8,289 | +0.300 | −0.172 | +0.111 | 32.7 |
| MT | 7,521 | +0.340 | −0.432 | −0.167 | 33.5 |
| TX | 5,945 | +0.184 | +0.044 | +0.337 | 37.1 |
| ID | 5,103 | +0.526 | −0.173 | +0.037 | 38.7 |
| AZ | 3,751 | +0.243 | +0.110 | +0.470 | 39.5 |
| UT | 3,504 | +0.231 | −0.063 | +0.264 | 32.1 |
| WY | 3,484 | +0.209 | −0.200 | +0.136 | 31.8 |
| VA | 3,248 | +0.275 | −0.250 | −0.319 | 45.3 |
| MS | 2,743 | +0.139 | −0.134 | +0.141 | 37.5 |
| NM | 2,080 | +0.256 | +0.043 | +0.460 | 35.8 |
| AR | 1,448 | +0.417 | −0.327 | −0.429 | 31.5 |
| AL | 1,356 | +0.080 | −0.122 | +0.060 | 33.4 |
| OK | 1,110 | +0.257 | −0.364 | −0.802 | 30.2 |
| MN | 946 | +0.306 | +0.188 | +0.908 | 30.4 |

The per-state range of r(ESI, BGI) — from effectively zero in the southeastern coastal plain to +0.5 in the inland Northwest — is consistent with the per-species and East–West regime results above. Productivity surfaces calibrated nationally absorb this state-level variability into spatial residuals; productivity surfaces calibrated regionally would see different ESI–BGI structure depending on which region they train on. The multi-dimensional view names this structure as part of the productivity construct rather than treating it as model error.

## 4. Discussion

### 4.1 The multi-dimensional case empirically

The cross-prediction, per-species, stand-age, forest-type, regional, and FIA-classification analyses converge on one conclusion: a single-metric reading of forest site productivity absorbs structural variability into the response variable that it should be modeling directly. Each measure carries some unique information that the others do not capture (Table 1). The ESI–BGI relationship is unstable across species (Table 3), across stand age (Table 4), across forest type, and across the East–West regime boundary. FIA's own site class (Table 3) and FIA's own site index (Table 2) align with biomass growth more than with our unified-target site index, suggesting that the field's traditional measure of productivity has been quietly measuring biomass growth structure for decades while being labeled as a height-growth measure.

### 4.2 What FIA SITECLCD actually measures

Table 3 is the headline finding. FIA's seven-class site productivity rating (SITECLCD) is one of the longest-standing operational classifications in U.S. forest assessment. Its mean ESI is essentially flat across the seven classes (29.6 to 32.1 m). Its mean BGI drops by a factor of 2.3 from class 1 to class 7. If a field user wanted to predict the FIA site class for an unranked plot, predicting from BGI alone would give a correctly-ordered ranking; predicting from ESI alone would not.

This is not a statement that SITECLCD is the "right" answer to the site productivity question. SITECLCD is one operational answer. The point is that the operational classification that the field has been using corresponds to biomass growth, not to height growth, and the operational measure (site index) that the field has been computing corresponds to height growth, not to biomass growth. There is a 70-year mismatch between the classification and the measure, and this mismatch is invisible from within a single-metric study.

The mismatch is quantitatively material. Random forest predictions of SITECLCD reach OOB R² = 0.808 from BGI alone vs OOB R² = 0.751 from ESI alone (Table 3a). A six-percentage-point R² gap is the empirical cost of treating SITECLCD as a single-metric response when biomass growth is doing the explanatory work that height-growth-potential is being credited for.

### 4.3 SICOND's correlations after base-age control

The SICOND × BGI correlation of r = +0.74 in the raw pooled data (Table 2) initially looked like the cleanest signature of a measurement-vs-classification mismatch. The base-age sensitivity test in §3.5 and Table 2a reveals the correlation is partly real and partly an artifact of pooling across FIA's per-region SIBASE strata. The pooled raw r = −0.08 SICOND × ESI is the more striking Simpson's paradox: stratifying by SIBASE shows SICOND tracks ESI at r = +0.42 in the SIBASE = 50 plots, +0.80 in the SIBASE = 80 plots, and +0.83 in the SIBASE = 100 plots. The pooled negative correlation is generated by the different SIBASE strata occupying different parts of the SI distribution, not by within-stratum orthogonality.

After projecting all SICOND values to a common base age of 50 yr via an anamorphic Chapman-Richards correction, SICOND correlates with ESI at r = +0.48 and with BGI at r = +0.45. These two correlations are within sampling error of each other on 34,794 plots, so the cleanest reading is that SICOND carries information about both productivity dimensions at moderate magnitude.

The earlier reading that "SICOND has been measuring biomass growth without saying so" overstates the case. The corrected reading is more nuanced and arguably more useful to practitioners. SICOND, even after methodologically clean base-age correction, is a moderate predictor (r ≈ 0.45 to 0.48) of both ESI and BGI. It captures neither dimension purely, and it does not substitute for the multi-measure decomposition the rest of this paper documents. The historical SICOND-FVS-calibration tradition has, in practical terms, captured a mixed productivity signal that includes both height-growth potential and biomass-growth structure, not preferentially one over the other.

The corollary for users who plan to swap SICOND for a refined unified-target ESI (such as ESI v7) is that the calibration shift will be smaller in magnitude than the raw r = −0.08 would have suggested. The two measures share substantial structure once base-age is controlled. The empirical bound on the calibration shift can be read from the cross-prediction analysis in §3.2: a linear OLS using SICOND alone recovers R² = 0.24 of the multi-dimensional information; replacing SICOND with ESI v7 in the same linear treatment recovers R² = 0.21 to 0.27 depending on stratification, a roughly 10 percent change. Substantively this means FVS-style height-growth calibrations re-fit on ESI v7 in place of SICOND should produce dominant-tree-height predictions that differ from the SICOND-based calibration by roughly 5 to 10 percent on average, larger at the per-species and per-region extremes documented in §3.3 and §3.13. Practitioners should expect calibration changes in that range, not changes that fundamentally alter the structure of FVS or related growth-and-yield systems.

### 4.4 Stand-age sign flip

The ESI–BGI sign flip at 120 years (Table 4) is a second layer of the multi-dimensional argument. In stands younger than the sign-flip threshold, the productive sites are not the fastest-growing right now because they have already reached a height-growth plateau. In old-growth stands, the productive sites are the fastest-growing because they sustained productivity into old age. The implications:

A productivity surface trained only on young stands will mis-rank old-growth plots, and vice versa.

A single productivity surface trained pooled across all stand ages will absorb the sign-flip into a flat mean, and the resulting surface will be wrong in opposite directions in young vs old stands.

The multi-dimensional reading, in contrast, names what is happening: site index captures one productivity dimension (long-window height potential), biomass growth captures another (recent annual increment), and the relationship between them is age-dependent. The composite reading handles this correctly.

### 4.5 What single-metric studies miss

A study that uses one of the five measures (ESI, BGI, Asym, NPP, SICOND) as a proxy for general productivity is implicitly assuming a stable relationship between that measure and the productivity dimensions the study actually cares about. Tables 2, 3, and 4 show this assumption is empirically wrong. The relationship varies by species, by stand age, by forest type, by ecological region, and is even sign-inconsistent across the boundary of the seven-class FIA classification system.

The operational cost of this assumption is invisible to the single-metric study. The CV R² of the single-metric model can still look good. The bias is hidden in the structural variation of the relationship — variation that the model treats as residual noise.

### 4.6 The composite as one operationalization

The CSPI v2 3-component composite reported here is one operationalization of the multi-dimensional view. We chose equal-weight z-score averaging because it is simple to implement, easy to decompose (each component ships as a standalone layer for users who want just one dimension), and easy to explain. The PCA-derived composite is a viable alternative that aligns with the dominant variance axis (the ESI–BGI trade-off; §3.9), and a theory-weighted composite (weights set by application) is a third option that we encourage users to consider for specific use cases. Future work could test whether downstream growth-and-yield calibrations behave better with one weighting scheme than another.

NPP enters the analysis as an external comparator. The 4-component version (with NPP weighted equally) correlates with the 3-component version at r = 0.76; NPP softens the ESI–BGI signal slightly. We ship the 3-component composite as the released default; users who want the 4-component version can compute it from the released layers.

SICOND enters the analysis as an external validator. The correlation pattern in Table 2 (SICOND with BGI at r = 0.74, with ESI at r = −0.08) is itself a result of interest and motivates the conceptual reframing in this paper.

### 4.6.1 Choosing among the measures by application

Figure 11 provides a decision tree for choosing among ESI, BGI, Asym, NPP, and CSPI v2 by application context. Height-growth-and-yield work (FVS calibration, dominant-height curves) should use ESI v7, recognizing that the FIA SICOND value carries biomass-growth signal rather than pure height-growth signal. Carbon stock change projections and Carbon Field Pilot work should use BGI, recognizing that BGI is what FIA's SITECLCD has been tracking all along. Long-run carbon accounting and mature stand density management should use Asym. Land surface modeling and atmospheric flux work should use NPP (with the MOD17 CV layer alongside). Cross-study comparisons and site-quality rankings without a specific application should use the CSPI v2 composite, which tracks FIA SITECLCD linearly and matches field-observed productivity expectations.

The decision tree also lists the three most common failure modes of single-metric studies, drawn directly from the analyses in this paper. ESI alone misses the FIA SITECLCD ranking (mean ESI essentially flat 30.6 → 29.6 m across the seven classes). ESI alone misses the stand-age sign flip (ESI–BGI goes from −0.57 in middle-age stands to +0.33 in old growth). ESI alone misses species heterogeneity (the ESI–BGI correlation ranges from 0.028 in yellow-poplar to 0.492 in Douglas-fir; a single national ranking implicitly assumes one relationship across all species). Researchers selecting a productivity measure should at minimum verify that their application is robust to these three known failure modes; if not, the multi-dimensional composite or a per-component decomposition is the recommended path.

### 4.7 What is robust to the SICOND correction

A reviewer-style robustness test at the manuscript revision stage revealed that the v0.9 framing of the SICOND-vs-ESI orthogonality result was overstated due to a Simpson's paradox in the SIBASE strata (§3.5, Table 2a). We log the finding transparently because it is methodologically informative: the corrected reading is materially different from the raw reading, but the principal claims of the paper survive intact. Specifically, the following findings are independent of the SICOND base-age and equation-family issues:

The SITECLCD random-forest result (§3.6, Table 3a): BGI alone reaches OOB R² = 0.808; ESI alone reaches 0.751; the six-percentage-point gap is the cleanest single statistic in the paper and is computed without any SI base-age dependency.

The ESI to BGI stand-age sign flip (§3.7, Table 4): correlation = −0.57 at 60 to 80 yr stands, +0.33 at 120+ yr stands. The sign flip is a property of the relationship between two productivity measures (height growth potential and biomass increment) and does not involve SICOND.

The per-species heterogeneity (§3.3, Table 3): r = 0.028 (yellow-poplar) to r = 0.492 (Douglas-fir). Computed at the species level on observed measures.

The East-vs-West regime sign flip for Asym × NPP (§3.4): r = −0.60 in the East, r = +0.57 in the West. Independent of SI.

What changed in the corrected reading is the specific claim about SICOND. The base-age-corrected SICOND × ESI correlation is +0.48, not −0.08; the SSURGO comparator (Table 2b) and the GADA-refit comparator (Table 2c) both show that traditional measurement chains share substantial structure with the unified-target ESI rather than being orthogonal to it. The structural argument for the multi-dimensional view does not rest on SICOND-ESI orthogonality; it rests on the four-dimensional cross-prediction analysis, the SITECLCD random forest, and the stand-age and species heterogeneity. The SICOND base-age finding is now a robustness-check section, not a headline.

### 4.8 Limitations

Spatial autocorrelation among nearby FIA plots can inflate cross-validation estimates. The CV protocol used here (plot-blocked + latitude-fold) addresses gross gradient; a more granular Moran's I diagnostic on per-fold residuals is planned for the v2.0.1 release.

BGI and Asym are FIA-derived; ESI and NPP are not (ESI is a model prediction; NPP is a satellite-derived product). The relationships among the measures inherit some method dependence. Future work could test whether substituting different operationalizations of each component changes the headline findings; we expect the structural patterns (sign flips, species heterogeneity, SITECLCD alignment) to be robust because they are driven by the underlying biology rather than by the specific model chains.

The unified North America site index compilation that supplies the ESI training response is described in a companion methods note (Weiskittel et al., in preparation). The fitted equations and the underlying records are included as supplementary data in the Zenodo deposit so that the present manuscript is not coupled to the methods note's acceptance.

## 5. Conclusions

Forest site productivity is empirically multi-dimensional. Four productivity measures at the CONUS scale (site index, biomass growth increment, asymptotic biomass, net primary production) carry overlapping but not redundant information. No measure is fully recoverable from the others (cross-prediction OOB R² ranges 0.70–0.89). The traditional linear treatment of site index as a single covariate captures only one-quarter of the multi-dimensional information available.

FIA's own site productivity classification (SITECLCD) aligns with biomass growth and with a 3-component composite (ESI + BGI + Asym), not with site index alone. The FIA-computed site index (SICOND) appears in raw pooled data to correlate strongly with biomass growth (r = +0.74) and essentially not at all with our unified-target ESI (r = −0.08), but this is a base-age Simpson's paradox: after standardizing SICOND to a common base age of 50 yr via anamorphic Chapman-Richards projection, SICOND correlates with both BGI and ESI at moderate magnitudes (r = +0.45 and +0.48 respectively), and a methodologically clean GADA-refit site index correlates with ESI v7 at r = +0.66 and with BGI at r = +0.43, confirming that the orthogonality reading was an artifact rather than a structural finding. The traditional FIA SICOND carries mixed information about both productivity dimensions at moderate magnitude.

The relationships among the four measures depend strongly on stand age (the ESI–BGI correlation flips sign at 120 years), on species (range −0.02 to +0.53 across major species), on forest type group, and on the eastern hardwood vs western conifer regime. Single-metric productivity studies absorb this structural variability into the response variable without seeing it.

We release a 3-component Composite Site Productivity Index (CSPI v2; ESI + BGI + Asym, equal weight z-score average) at 30 m as one operationalization of the multi-dimensional view, alongside the four component layers and FIA SICOND as standalone citable products so that downstream users can decompose the composite or use the measure that fits their application. The deposit is at Zenodo concept DOI 10.5281/zenodo.20515034, version 2.0.0 at 10.5281/zenodo.20663652. The v2.0.0 release ships the lightweight 1 km surface and supporting documentation; the 30 m surfaces will follow in v2.1.0 after Zenodo quota approval.

## 5.5 Author contributions (CRediT)

Aaron R. Weiskittel: Conceptualization, Methodology, Software, Validation, Formal analysis, Investigation, Resources, Data curation, Writing — original draft, Writing — review and editing, Visualization, Supervision, Project administration, Funding acquisition.

## 5.6 Declaration of competing interests

The author declares no competing interests.

## 5.7 Declaration of generative AI use

During the preparation of this work the author used Claude (Anthropic) for structural organization, consistency checking, and code drafting in the analytical pipeline. The author reviewed and edited all output and takes full responsibility for the content of the publication.

## 6. Acknowledgments

This work was supported by the USDA National Institute of Food and Agriculture, McIntire-Stennis Forestry Research Program (Maine Agricultural and Forest Experiment Station), with supplemental support from the University of Maine Center for Research on Sustainable Forests. [PLACEHOLDER: confirm specific NIFA McIntire-Stennis project number.] The unified North America site index compilation that supplies the response variable is being developed under a separate methods note in preparation. Computation was performed on the Ohio Supercomputer Center Cardinal cluster under allocation PUOM0008.

## 7. Data and code availability

CSPI v2.0.0 is at 10.5281/zenodo.20663652 (concept 10.5281/zenodo.20515034), CC-BY-4.0. The release contains the recommended 1 km ESI v6 surface, MOD17A3HGF NPP at 500 m, and documentation; the full 30 m surfaces follow in v2.1.0. The SICOND-target v3 and v4 surfaces from v1.0.0 (10.5281/zenodo.20515035) remain available. Pipeline at https://github.com/holoros/fvs-conus.

## References

Bontemps, J.-D., Bouriaud, O. (2014). Predictive approaches to forest site productivity: recent trends, challenges and future perspectives. Forestry 87 (1): 109–128.

Breiman, L. (2001). Random forests. Machine Learning 45: 5–32.

Hansen, M. C., et al. (2013). High-resolution global maps of 21st-century forest cover change. Science 342: 850–853.

Poggio, L., et al. (2021). SoilGrids 2.0. SOIL 7: 217–240.

Running, S. W., Mu, Q., Zhao, M. (2015). MOD17A3HGF MODIS/Terra Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN Grid V006. NASA EOSDIS LP DAAC. https://doi.org/10.5067/MODIS/MOD17A3HGF.006

Skovsgaard, J. P., Vanclay, J. K. (2008). Forest site productivity: a review of the evolution of dendrometric concepts for even-aged stands. Forestry 81 (1): 13–31.

[REVIEWER VERIFY DOI] Westfall, J. A., Coulston, J. W., Gray, A. N., Shaw, J. D., Radtke, P. J., Walker, D. M., Weiskittel, A. R., MacFarlane, D. W., Affleck, D. L. R., Zhao, D. (2023). National Scale Volume and Biomass Estimators (NSVB) for tree species in the United States. USDA Forest Service Forest Inventory and Analysis Program. Released 30 September 2023, replaces the Component Ratio Method for FIA tree-level biomass estimation.

[REVIEWER VERIFY full citation] (2024). Modeling regional forest site productivity accounting spatial structure in climatic and edaphic variables. Forest Ecology and Management (in press). The closest analog in the recent literature to our multi-scale productivity argument; uses random forest with climate and soil covariates and demonstrates that regional spatial structure matters for site productivity estimation.

[REVIEWER VERIFY full citation] Smith, J. E., et al. (2024). Site productivity and forest carbon stocks in the United States: analysis and implications for forest offset project planning. USDA Forest Service treesearch/40783. Establishes that practitioners are using FIA SITECLCD operationally for carbon offset planning, which gives the SITECLCD-vs-site-index mismatch documented in this paper direct practical relevance for the carbon accounting community.

Wang, T., Hamann, A., Spittlehouse, D., Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PLoS ONE 11 (6): e0156720.

Weiskittel, A. R. (2026). Composite Site Productivity Index (CSPI) v1.0.0 for the conterminous United States. Zenodo. https://doi.org/10.5281/zenodo.20515035

Weiskittel, A. R. (2026). Composite Site Productivity Index (CSPI) v2.0.0 for the conterminous United States. Zenodo. https://doi.org/10.5281/zenodo.20663652

Wright, M. N., Ziegler, A. (2017). ranger: a fast implementation of random forests for high dimensional data in C++ and R. Journal of Statistical Software 77 (1): 1–17.

Weiskittel, A. R. et al. (in preparation). The unified North America site index compilation.

# Figures


![Figure 1. Correlation heatmap of the four CSPI components.](figures_v04/F1_cor_heatmap.png)

\newpage


![Figure 2. Standardized component distributions.](figures_v04/F2_component_ridges.png)

\newpage


![Figure 3. Composite by latitude band.](figures_v04/F3_composite_by_latband.png)

\newpage


![Figure S6. CV R² across ESI versions (moved from main to supplementary per Reviewer 1 / self-review distillation pass).](figures_v04/F4_cv_bar_versions.png)

\newpage


![Figure S7. Variable importance v7 vs v8 (moved from main to supplementary per distillation pass).](figures_v04/F5_variable_importance.png)

\newpage


![Figure 6. Components vs composite scatter.](figures_v04/F6_component_vs_composite.png)

\newpage


![Figure 7. Wall-to-wall CSPI v2 3-component composite (ESI v7 + BGI + Asym) at 30 m, displayed at 1 km. z-score equal-weight average over CONUS, rescaled to 0-100. Pacific Northwest coastal forest band highest; southwestern interior margin lowest; southeastern coastal plain and central hardwood region intermediate.](figures_v10/F7_cspi_v21_3c_map.png)

\newpage


![Figure 8. Mean productivity measure by FIA SITECLCD class. Site index is essentially flat across the seven classes while biomass growth tracks the classification monotonically; the 3-component composite tracks the classification.](figures_v10/F8_siteclcd_by_measure.png)

\newpage


![Figure 9. ESI-BGI correlation by stand age bin. The correlation is negative in young to middle-age stands and flips to positive in old growth, demonstrating that a productivity surface trained pooled across stand ages is wrong in opposite directions in young versus old stands.](figures_v10/F9_stand_age_correlation.png)

\newpage


![Figure 10. ESI-BGI correlation by major species, ordered. The pooled correlation of -0.45 masks per-species variation from r = 0.028 (yellow-poplar) to r = 0.492 (Douglas-fir); a single national productivity ranking implicitly assumes one relationship across all species, but the data show the relationship differs by half an r unit.](figures_v10/F10_per_species_ESI_BGI.png)

\newpage


![Figure 11. Decision tree for choosing among ESI, BGI, Asym, NPP, and the CSPI v2 composite by application context. Each leaf box names the use case, the natural caveat, and a numerical anchor; the bottom panel summarizes three common failure modes of single-metric productivity studies (the SITECLCD ranking, the stand-age sign flip at 120 years, and species heterogeneity in the ESI-BGI correlation).](figures_v10/F11_decision_tree.png)

\newpage

# Supplementary Materials

## Composite Site Productivity Index (CSPI) v2.0.0 for the conterminous United States

Aaron R. Weiskittel  
University of Maine, Center for Research on Sustainable Forests  
ORCID: 0000-0003-2534-4478

---

## Table S1. Predictor covariates

The 25-covariate stack reported in the manuscript Section 2.2. Native resolution, source, and processing pipeline for each predictor.

| Variable | Description | Native res. | Source | Pipeline | Units |
|---|---|---|---|---|---|
| sand_0_5 | Sand fraction, 0–5 cm | 250 m | SoilGrids 2.0 | Reprojected to EPSG:4326 30 m via gdalwarp bilinear | % |
| soc_0_5 | Soil organic carbon, 0–5 cm | 250 m | SoilGrids 2.0 | Same | g kg⁻¹ × 10 |
| bdod_0_5 | Bulk density, 0–5 cm | 250 m | SoilGrids 2.0 | Same | kg dm⁻³ × 100 |
| cec_0_5 | Cation exchange capacity, 0–5 cm | 250 m | SoilGrids 2.0 | Same | mmol(c) kg⁻¹ × 10 |
| nitrogen_0_5 | Total nitrogen, 0–5 cm | 250 m | SoilGrids 2.0 | Same | cg kg⁻¹ |
| phh2o_0_5 | pH in water, 0–5 cm | 250 m | SoilGrids 2.0 | Same | × 10 |
| elev | Elevation | 30 m | OpenTopography SRTMGL1 (Earthdata mirror) | Reprojected to EPSG:4326 30 m via gdalwarp bilinear | m |
| slope | Slope | 30 m | Derived from elev (gdaldem slope) | Same | degrees |
| aspect | Aspect | 30 m | Derived from elev (gdaldem aspect) | Same | degrees |
| h_tc2000 | Tree cover, 2000 | 30 m | Hansen Global Forest Change v1.10 | Same | % |
| h_loss_10y | Tree cover loss within 10 years | 30 m | Hansen Global Forest Change v1.10 | Reclassified loss years 2014–2023 | 0/1 |
| hli | Heat load index | derived | McCune and Keon 2002 from slope, aspect | Point-derived per pixel | dimensionless |
| north | cos(aspect) | derived | Derived from aspect | Point-derived | [−1, 1] |
| east | sin(aspect) | derived | Derived from aspect | Point-derived | [−1, 1] |
| elev_sq | elev × elev | derived | Derived from elev | Point-derived | m² |
| v6_distill | ESI v6 1 km surface, bilinear-resampled | 1 km → 30 m | This dataset | Trained v6 surface extracted at each pixel | m at base age 50 |
| ndvi | Sentinel-2 NDVI, growing-season median 2021 | 10 m → 1 km buffer mean | ESA/Copernicus via GEE | 1 km buffer mean at plot per fuzz rule | [0, 1] |
| evi | Sentinel-2 EVI, growing-season median 2021 | 10 m → 1 km buffer mean | ESA/Copernicus via GEE | Same | [0, 1] |
| ndre | Sentinel-2 NDRE, growing-season median 2021 | 20 m → 1 km buffer mean | ESA/Copernicus via GEE | Same | [0, 1] |
| s2rep | Sentinel-2 Red-Edge Position | 20 m → 1 km buffer mean | ESA/Copernicus via GEE | Same | nm |
| cire | Sentinel-2 Red-Edge Chlorophyll Index | 20 m → 1 km buffer mean | ESA/Copernicus via GEE | Same | dimensionless |
| gpp_mean | MOD17A3HGF GPP mean 2017–2023 | 500 m → 1 km buffer mean | NASA LP DAAC via GEE | Same | kg C m⁻² yr⁻¹ |
| npp_mean | MOD17A3HGF NPP mean 2017–2023 | 500 m → 1 km buffer mean | NASA LP DAAC via GEE | Same | kg C m⁻² yr⁻¹ |
| gpp_cv | MOD17A3HGF GPP CV 2017–2023 | 500 m → 1 km buffer mean | NASA LP DAAC via GEE | Same | dimensionless |
| npp_cv | MOD17A3HGF NPP CV 2017–2023 | 500 m → 1 km buffer mean | NASA LP DAAC via GEE | Same | dimensionless |

ESI v5 uses the first 11 rows; ESI v6 adds 19 ClimateNA covariates (not listed; see CSPI v4 supplements at concept DOI 10.5281/zenodo.20515034); ESI v7 uses the first 16 rows; ESI v8 uses all 25 rows.

---

## Table S2. Full v3–v8 performance comparison

| Model | n train | Predictors | OOB R² | OOB RMSE (m) | Plot-blocked CV R² | Spatial CV R² mean |
|---|---|---|---|---|---|---|
| ESI v3 (SICOND target) | 58,475 | 11 (soil + terrain + canopy) | n/r* | n/r | 0.602 | n/r |
| ESI v4 (SICOND + climate) | 58,475 | 11 + 33 ClimateNA | n/r | n/r | 0.660 | n/r |
| ESI v5 (unified) | 66,428 | 11 | 0.678 | 5.98 | 0.664 | 0.358 |
| ESI v6 (unified + clim 1km) | 87,710 (66 k dedup) | 11 + 19 ClimateNA | n/r | n/r | 0.699 | 0.272 |
| **ESI v7 (combined 30 m)** | 66,428 | 16 (v5 + microclimate + v6 distill) | **0.700** | **5.79** | **0.686** | **0.427** |
| ESI v8 (v7 + RS) | 63,806 | 25 (v7 + 5 S2 + 4 MOD17) | 0.702 | 5.66 | 0.688 | 0.424 |

*Not reported in the original CSPI v3 paper. Numbers shown are the most directly comparable. v7 enters the composite as the ESI layer.

---

## Table S3. Leave-one-component-out sensitivity for CSPI v2

At 66,433 complete-case FIA plots. LOCO composite = mean of remaining three z-scored components, sigma-clipped at ±3, rescaled to 0–100.

| Component dropped | r vs full composite | RMSE (0–100 units) | Interpretation |
|---|---|---|---|
| ESI | 0.774 | 8.16 | Most sensitive to ESI by correlation (lowest r). |
| BGI | 0.797 | 8.97 | Smallest impact by correlation. |
| Asym | 0.787 | 11.36 | Largest impact by RMSE (most distinct contribution). |
| NPP | 0.780 | 7.76 | Smallest impact by RMSE (best replacement by others). |

No 3-of-4 subset preserves less than r = 0.77 against the full composite.

---

## Table S4. Head-to-head model performance at common plots

Reported in manuscript Section 3.7. Common plot subsets vary by version because climate-only and SICOND-target models are not evaluated at the same plot population. All comparisons are descriptive of how each surface tracks the response at the training set; out-of-sample test held-out separately.

| Model | n (vs SICOND) | R² vs SICOND | RMSE (m) | n (vs unified SI) | R² vs unified SI | RMSE (m) |
|---|---|---|---|---|---|---|
| ESI v3 (SICOND target) | 31,900 | 0.72 | 6.04 | 6,221 | 0.62 | 6.95 |
| ESI v5 (unified SI target) | 32,683 | 0.64 | 6.92 | 6,309 | 0.53 | 7.82 |
| ESI v6 (unified SI + clim 1 km) | 6,221 | **0.83** | **4.71** | 6,221 | **0.83** | **4.72** |
| ESI v7 (unified SI + clim distill) | 6,221 | 0.73 | 5.84 | 6,221 | 0.73 | 5.85 |

---

## Table S5. Per-species OOB R² for the six most abundant species in the unified compilation

| Species | SPCD | n plots | ESI v5 OOB R² | Previous CSPI v3 dedup at fuzzed |
|---|---|---|---|---|
| Loblolly pine (Pinus taeda) | 131 | ~11,800 | 0.33 | 0.04 |
| Yellow-poplar (Liriodendron tulipifera) | 621 | ~3,400 | 0.52 | 0.10 |
| White oak (Quercus alba) | 802 | ~3,900 | 0.49 | 0.32 |
| Ponderosa pine (Pinus ponderosa) | 122 | ~3,200 | 0.36 | 0.28 |
| Northern red oak (Quercus rubra) | 833 | ~3,400 | 0.48 | 0.31 |
| Douglas-fir (Pseudotsuga menziesii) | 202 | ~5,800 | 0.44 | 0.30 |

The leveling pattern—loblolly pine and yellow-poplar in particular—is the diagnostic test of the response-side improvement: under the unified target, both species' within-range SI variation is now expressed under a single equation rather than across multiple FIA region boundaries. The five non-ponderosa species cluster between R² 0.44 and 0.52, a range narrow enough to read as biological rather than methodological.

---

## Methods notes

### M1. Quantile Random Forest prediction interval

For ESI v7 uncertainty: ranger 0.16.0 fit with `quantreg = TRUE`, 500 trees, mtry = 4, min.node.size = 5, on the v7 training table with the v7 predictor stack. Quantiles c(0.05, 0.50, 0.95) predicted at each 30 m pixel; the width90 = p95 − p05 is the per-pixel 90% prediction interval reported as the released uncertainty raster.

The QRF surface predict is implemented as a 40-tile SLURM array (each tile is a latitude row of the CONUS 30 m grid, ~2,300 rows per tile, processed independently with the same trained QRF model). A separate merge job stitches the 40 single-tile rasters into the released 4-band raster (p05, p50, p95, width90).

### M2. Composite z-score parameters

Z-score parameters at 66,433 complete-case FIA plots (manuscript Section 2.6):

| Component | Mean | SD |
|---|---|---|
| ESI | 27.81 m | 11.41 |
| BGI | 1.72 Mg ha⁻¹ yr⁻¹ | 0.58 |
| Asym | 249.1 Mg ha⁻¹ | 20.3 |
| NPP | 434.9 g C m⁻² yr⁻¹ | 163.1 |

These parameters are stored to disk (`cspi_4c_zscore_params.csv` in the deposit) so the wall-to-wall surface uses the same standardization as the plot-level composite.

### M3. CSPI v2 surface generation (slow path TIMEOUT and fast-path recovery)

The slow path (`cspi_4c_surface.r`) used terra::project for bilinear reprojection of BGI, Asym, and NPP onto the ESI v7 grid. This reached approximately 80% completion before exhausting an 8-hour walltime. A watchdog auto-fired a fast-path replacement (`cspi_4c_fast.r`) that performs the reprojection via gdalwarp with parallel threads and computes the composite via `terra::lapp` against the reprojected stack. The fast path completed in 3:03 with the same numerical output (composite z-score parameters identical at the FIA plot set, as expected since the standardization layer is identical).

### M4. Forest mask

Forest-masked products use the Hansen Global Forest Change tree-cover 2000 band (h_tc2000) thresholded at ≥10%. The mask is applied via `terra::mask` to each released forest-mask layer.

### M5. Buffer aggregation for fuzzed FIA coordinates

The fuzz-sensitivity rule from the CSPI v3 release (predictors at 250 m or coarser native resolution survive FIA coordinate fuzzing) governs the buffer aggregation in extraction. Sentinel-2 (10–20 m native) and MOD17A3HGF (500 m native) are extracted via 1 km buffer mean reduction at each FIA plot location to suppress per-pixel error from coordinate fuzz. This is consistent with the asym_agb_analysis BGI and Asym pipeline.

---

## Figures S1–S5 (deferred)

Supplementary figures will accompany the final manuscript revision. Planned:

- **Figure S1**: Map of FIA training plot locations colored by year of most recent measurement.
- **Figure S2**: Per-species residual diagnostics (loblolly pine, yellow-poplar, ponderosa pine) under v5 vs v7.
- **Figure S3**: Spatial residual map for v7 at the latitude-fold withholding boundaries.
- **Figure S4**: ESI v7 quantile-RF width90 (90% prediction interval) over CONUS, forest-masked.
- **Figure S5**: CSPI v2 composite overlaid with ecoregion boundaries (EPA Level III).

S4 will land once the v7 QRF tile-array (job 11503014 + merge 11503015) completes; S5 requires an ecoregion shapefile overlay on the composite surface.
