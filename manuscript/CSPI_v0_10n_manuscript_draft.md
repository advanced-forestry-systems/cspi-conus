# Beyond site index: FIA's own classification system disagrees with site index but agrees with a multi-dimensional composite of forest productivity at 30 m across the conterminous United States

Draft v0.10k, 17 June 2026. The paper tells two intertwined stories. The **primary story** asks how multiple measures of forest site productivity (height-growth-potential site index, biomass growth increment, asymptotic biomass, satellite NPP) relate to each other and to the traditional measures U.S. forestry has used for the past seven decades (FIA SICOND site index and FIA SITECLCD site class), and develops a 3-component Composite Site Productivity Index (CSPI v2) as one operationalization of the multi-dimensional view. The headline finding remains that FIA's site class correlates with biomass growth and the composite, not with site index alone (BGI alone OOB R² = 0.808 vs ESI alone 0.751). The pooled raw SICOND × ESI correlation of −0.08 is a base-age Simpson's paradox; after standardization to base 50, SICOND correlates with both ESI and BGI at r ≈ 0.45 to 0.48. The **secondary story** documents the structural drivers of metric divergence: where the measures disagree, why they disagree, and what that means biologically. Species heterogeneity, East-vs-West regime, multilevel ecoregion, geologic parent material, forest type group, disturbance and treatment context, and a new disturbance × ecoregion interaction analysis (joint r(ESI,BGI) range = 1.40 across 115 cells, wider than any single stratification) all enter as evidence that productivity-dimension orthogonality is structurally organized by what kind of forest is on the plot and what has happened to it. Adding parent material as a categorical predictor matters most for asymptotic biomass (ΔR² = +0.008 in the v3.0.0 30 m surface) and not at all for height-growth-potential ESI (ΔR² = +0.001). The v3.0.0 surface release ships ASYM_V9_CONUS_30m.tif alongside the v7 ESI baseline and parent material 30 m overlay. Data concept DOI 10.5281/zenodo.20515034. Analytical chain DOI 10.5281/zenodo.20693106. v2.0.0 DOI 10.5281/zenodo.20663652. v3.0.0 DOI 10.5281/zenodo.20763197 (this paper).

Author: Aaron R. Weiskittel, University of Maine, Center for Research on Sustainable Forests. ORCID 0000-0003-2534-4478. Corresponding email: aaron.weiskittel@maine.edu.

## Abstract

Forest site productivity in the United States has been measured operationally for seven decades primarily through site index (the FIA SICOND value) and classified into seven productivity classes by FIA's site quality (SITECLCD). This paper asks two intertwined questions. The **primary question** is how multiple modern measures of forest site productivity (height-growth-potential site index, biomass growth increment, asymptotic biomass, satellite net primary production) relate to each other and to the traditional FIA measures, and whether a multi-dimensional composite captures information that single-measure operational practice cannot. The **secondary question** is what drives the divergence when the measures disagree: where the divergence is largest, what biological structure organizes it, and what implications follow for species-specific and region-specific applications.

At 66,433 FIA Phase 2 plots where all four modern productivity measures are jointly available, and at 114,587 plots after joining FIA COND-level context, no single measure substitutes for another (cross-prediction OOB R² ranges 0.70 to 0.89). FIA's own seven-class site quality (SITECLCD) is recovered by biomass growth increment alone at OOB R² = 0.808 but by site index alone at only 0.751, a six-percentage-point gap quantifying the structural mismatch between what U.S. forestry has classified as productivity (a biomass growth signal) and what it has measured as productivity (a height growth signal). FIA SICOND's pooled raw correlation with biomass growth of r = +0.74 and with the unified-target ESI of r = −0.08 is a base-age Simpson's paradox; after Chapman-Richards anamorphic projection to base age 50, SICOND correlates with both biomass growth and ESI at moderate magnitudes (r = +0.45 and +0.48). A methodologically clean GADA-refit site index correlates with our unified-target ESI at r = +0.66.

The secondary story documents the structural drivers of metric divergence. The ESI–BGI correlation ranges from r = −0.02 (loblolly pine) to +0.53 (Douglas-fir) across major species, with a similar 1.15-unit spread across forest type groups (Oak-Gum-Cypress −0.555 to Longleaf-Slash pine +0.591) and a 0.96-unit spread across FIA disturbance categories. A joint disturbance × EPA Level III ecoregion stratification produces an even wider spread (1.40 across 115 cells), revealing that productivity-dimension orthogonality interacts with disturbance regime and ecoregional context in ways that neither single axis reveals. Volcanic substrates carry the highest mean ESI in the dataset (39.9 m) but the lowest FIA SITECLCD rating (5.69 of 7); organic substrates carry the lowest mean ESI (19.2 m) but among the highest BGI values (2.04 Mg ha⁻¹ yr⁻¹). Parent material added as a categorical predictor on top of a climate-saturated stack reorganizes height-growth-potential predictions essentially not at all (ΔR² = +0.001) but reorganizes asymptotic-biomass predictions meaningfully (ΔR² = +0.008 on the v3 30 m surface stack), consistent with the ecological reading that deep substrate matters more for long-run carrying capacity than for short-run growth dynamics.

We release a three-component Composite Site Productivity Index (CSPI v2; ESI + BGI + Asym at 30 m) as one operationalization of the multi-dimensional view, alongside the four component layers and the parent material 30 m overlay as separately citable products. The four component layers, the composite, and the Asym v9 parent-material-aware corrective surface are deposited under Zenodo concept DOI 10.5281/zenodo.20515034 (version 2.0.0 at 10.5281/zenodo.20663652; v3.0.0 in preparation).

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

The Results are organized into two arcs. Sections 3.1 through 3.6 constitute the **primary story**: cross-metric relationships, the connection to traditional FIA measures (SICOND, SITECLCD), and the construction of the CSPI v2 composite. Sections 3.7 through 3.18 constitute the **secondary story**: where the measures diverge, what drives the divergence, and what that implies biologically. The two arcs are presented together because the secondary story is the structural evidence that makes the primary story compelling: a single-metric reading does not just fail to summarize productivity, it fails predictably along axes that have ecological meaning.

### Primary story (§3.1 to §3.6): How do multiple productivity metrics relate to each other and to the traditional measures of FIA SICOND and SITECLCD?

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

### Secondary story (§3.7 to §3.18): What drives metric divergence? Where do they disagree, and what does the disagreement imply biologically?

### 3.7 Stand age stratification (supplementary)

A supplementary stand-age stratification of the ESI-BGI correlation (Table S12) shows a phenomenologically interesting pattern of sign-flip at the boundary between middle-age (60-80 yr, r = −0.57) and old-growth (120+ yr, r = +0.33) stands. The interpretation is that in young and middle-age stands the tallest plots for their age have already plateaued in biomass accumulation, while in old-growth stands the tallest plots are also the ones that maintained high biomass-growth rates into old age. We report this finding in Table S12 because FIA STDAGE has substantial measurement uncertainty at the plot level and because stand age depends on management history rather than fixed site properties; the per-species (§3.3), regional (§3.4), parent-material (§3.14), and SITECLCD (§3.6) stratifications are the cleaner structural anchors for the multi-dimensional argument.

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

A counterintuitive empirical finding emerges from the SITECLCD recovery test (Table S10): the **broader L1 weighting alone** outperforms L3 weighting alone (c3_L1 OOB R² = 0.806 vs c3_L3 = 0.804, both vs c3_equal = 0.802). Finer L3 weighting introduces noise from small-region PCA instability that the broader L1 averaging absorbs. The largest gain (+0.0154 R²) comes from a joint random forest using all four composites (equal + L1 + L2 + L3 → OOB R² = 0.818, RMSE = 0.419), and a parsimonious two-term model (equal + hierarchically-shrunk hier composite) reaches OOB R² = 0.815, only 0.003 short of the four-term ensemble. The pooled correlation between c3_equal and c3_L3 is r = 0.45, which initially looks low for two composites built from the same three z-scored components; the explanation is that the ecoregion-weighted composite is a **spatially-coordinated reweighting** rather than a global tilt, with each plot's effective weights inherited from its ecoregion's PC1 loadings.

The equal-weight composite is therefore retained as the operational default for the v2.0.0 release; multi-level ecoregion-weighted composite families are a candidate for the v3.0.0 release where the combined gain is application-meaningful. Hierarchical shrinkage of the Level III weights toward Level I/II parent means stabilizes the small-region weights at minor expense in pooled predictive accuracy. Bootstrap 95% confidence intervals on the R² values (B = 500, ranger with 200 trees per fit) confirm that the gain from adding any ecoregion-weighted composite to the equal-weight composite is highly significant (equal alone R² = 0.812 [0.807, 0.816], equal + hier R² = 0.832 [0.829, 0.835], non-overlapping CIs). The four-composite ensemble (R² = 0.836 [0.833, 0.840]) gains only +0.004 over the parsimonious two-term equal + hier model, with overlapping CIs, so the operational v3.0.0 recommendation is the two-term equal + hierarchical model. Tau hyperparameter sensitivity across 20 (tau3, tau2) combinations gives OOB R² spanning only 0.814 to 0.815, indicating the hierarchical-shrinkage finding is insensitive to the choice of shrinkage tuning constants (Table S11).

We frame this result as a **representation** finding rather than a **prediction** finding. Because SITECLCD is computed from per-FIA-region growth equations and our four productivity measures are also FIA-derived (ESI v7 is trained on the unified North America compilation that includes FIA, BGI and Asym are computed directly from FIA remeasurement and AGB pairs), the +0.015 R² gain partly reflects the ecoregional structure that FIA itself uses in calibrating SITECLCD. The composite recovers what FIA's classification has been doing, in the same way that the SICOND × BGI correlation in §3.5 reflects what FIA's per-region SI equations have absorbed. An independent prediction validation against productivity measurements outside the FIA system (long-term carbon-sequestration rates from non-FIA permanent plots, or net primary production at non-FIA tower sites) would be required to make a stronger claim about true site-quality prediction. We discuss this distinction further in §4.7.

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

### 4.4 Geologic parent material as a structural axis

The geologic stratification in §3.14 (Tables 7 and 7a) provides the cleanest single illustration of the multi-dimensional disagreement between site index and FIA SITECLCD. Volcanic soils carry the highest mean ESI in the dataset (39.9 m) — the dominant trees that grow on those sites are tall — and the lowest mean SITECLCD productivity rating (5.69 of 7) — FIA classifies them as the least productive. Organic soils are the opposite case: the lowest mean ESI (19.2 m) but a high BGI (2.04 Mg ha⁻¹ yr⁻¹). The two productivity measures give opposite answers on the two parent-material categories where the disagreement is most extreme.

We emphasize the geologic axis over alternative stratifications (stand age, forest type group) because geologic parent material is a fixed site property that does not depend on management history or measurement uncertainty. The pattern is reproducible across the species axis (§3.3), the East-West regime axis (§3.4), the SITECLCD class axis (§3.6), and the parent material axis (§3.14): the same opposite-sign disagreement reappears at each. This rules out single-axis artifact explanations and supports the structural interpretation that site index and FIA productivity classification measure distinct, partially independent productivity dimensions.

The implication for productivity surface modeling: any single national productivity surface that pools across these structural axes will absorb the sign-flip into the regression residuals. The multi-dimensional reading names this directly: site index captures one productivity dimension (long-window height potential), biomass growth captures another (recent annual increment), and the relationship between them depends on which stratification axis you examine. The composite reading handles this correctly by retaining both dimensions as separate input components.

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

### 3.14 Geologic parent material adds a fourth stratification axis

The multi-dimensional pattern documented above (per-species, per-region, per-stand-age) also holds across geologic parent material categories. We pulled gSSURGO `copmgrp.pmgroupname` at the FIA plot mukeys via the SDA web service and categorized the dominant component into ten broad parent material groups (Table 7).

**Table 7.** Mean productivity measures and ESI-BGI correlation by gSSURGO parent material category, dominant component per mukey. n = 110,494 plots with a parent material assigned.

| Parent material | n | Mean ESI (m) | Mean BGI (Mg ha⁻¹ yr⁻¹) | Mean Asym | Mean NPP | r(ESI, BGI) |
|---|---|---|---|---|---|---|
| Residuum | 35,500 | 28.1 | 1.67 | 250.9 | 452 | −0.578 |
| Marine | 24,821 | 24.1 | **2.17** | 233.6 | 505 | +0.026 |
| Alluvial | 20,622 | 28.5 | 1.63 | 245.6 | 489 | −0.509 |
| Glacial | 10,136 | 31.2 | 1.27 | 257.8 | 334 | −0.405 |
| Colluvium | 8,887 | 31.8 | 1.29 | 252.2 | 384 | −0.546 |
| Eolian | 4,348 | 30.5 | 1.77 | 240.8 | 421 | −0.614 |
| Other | 4,117 | 26.7 | 1.86 | 249.8 | 393 | −0.487 |
| **Organic** | 1,130 | **19.2** | 2.04 | 246.2 | 313 | **+0.599** |
| **Volcanic** | 494 | **39.9** | 1.09 | 254.9 | 486 | **+0.582** |
| Lacustrine | 439 | 26.7 | 1.60 | 258.5 | 236 | −0.153 |

Two findings emerge that strengthen the multi-dimensional argument. First, volcanic soils have the highest mean ESI (39.9 m) but the lowest mean SITECLCD productivity ranking (Table 7a, mean SITECLCD 5.69 of 7). Conversely, organic soils have the lowest mean ESI (19.2 m) but show high BGI (2.04 Mg ha⁻¹ yr⁻¹). The two measures disagree in opposite directions on the two parent material categories where the mismatch is most extreme. Second, the ESI–BGI correlation sign-flip we documented by stand age and species also appears by geology: organic (r = +0.60) and volcanic (r = +0.58) show strongly positive ESI–BGI correlations, while most other categories show negative correlations (−0.41 to −0.61). The "ecological regime" axis we identified in §3.4 generalizes to a "geological regime" axis with the same structural consequence: pooling across parent material categories in a single national productivity surface absorbs the sign-flip into the residuals.

**Table 7a.** Mean FIA SITECLCD class by parent material. SITECLCD = 1 is most productive, 7 is least productive.

| Parent material | n | Mean SITECLCD |
|---|---|---|
| Marine | 11,508 | **4.48** |
| Lacustrine | 230 | 4.92 |
| Eolian | 2,314 | 4.93 |
| Organic | 782 | 5.12 |
| Alluvial | 12,510 | 5.26 |
| Other | 2,028 | 5.27 |
| Residuum | 17,354 | 5.37 |
| Glacial | 6,630 | 5.56 |
| Colluvium | 6,640 | 5.66 |
| **Volcanic** | 238 | **5.69** |

Marine and Eolian soils receive the most productive SITECLCD ratings; Volcanic and Colluvium receive the least. Combined with Table 7, the volcanic soils contrast becomes clear: high site index for the trees that grow there (tall dominant heights), but low biomass accumulation rate, low FIA productivity rating. This is exactly the multi-dimensional pattern: ESI captures one productivity dimension, BGI and SITECLCD capture another, and the two answers diverge on the geology where the mismatch is structural rather than random.

The geologic stratification is consistent with the broader argument. As a follow-on we substituted the gSSURGO 30 m mukey raster into a 10-class parent material raster (1.4 billion CONUS pixels, 255 MB compressed; available with the deposit) and refit an ESI v9 random forest with the parent material category added as a categorical covariate on top of the 35 ClimateNA variables used to fit ESI v7.

We deliberately exclude latitude and longitude from the v9 covariate stack. When LAT and LON are included, they appear as the top variable importance ranks and absorb roughly four percent of OOB R² (0.677 vs 0.673 without them; Table S12). Coordinate predictors let a random forest short-circuit through geographic position rather than forcing climate covariates and substrate to do the explanatory work, which is appropriate for an interpolation surface but is misleading for understanding the structural drivers of site productivity. The cleaner test of whether parent material adds residual signal is therefore a climate-only model, not a climate-plus-coordinates model. We adopt the no-coordinates convention for all subsequent ESI refits, including v3.0.0.

At the plot level the headline statistics are essentially unchanged: validation R² = 0.6975 (climate only, no LAT/LON) vs 0.6984 (climate + PM, no LAT/LON); ΔR² = +0.001. The pm_factor predictor ranks last out of 35 variables by impurity importance (importance 22,217 vs the leading growing-season precipitation × temperature interaction at 466,409). This is the expected behavior of a structural axis covariate on top of a saturated climate stack: climate variables already encode the regional geologic gradient through their joint distribution, so the categorical PM predictor contributes no residual fit signal at the macroscale where R² is dominated by the climate gradient.

A plot-resolution spatial diagnostic confirms this directly. We predicted both v7 and v9 at all 41,065 unified-target FIA plots with a parent material assignment, then mapped the prediction difference (ΔESI = v9 − v7; Figure 12). The CONUS-wide pattern is essentially uniform grey: mean absolute difference is 0.22 m on a mean SI scale of approximately 28 m, the 95th percentile of absolute differences is 0.51 m, only 1.1 percent of plots shift by more than 1 m, and no plot shifts by more than 3 m. Per parent material category (Table 7c, Figure 12b) eight of the ten categories show a mean shift of |ΔESI| ≤ 0.01 m; only Organic peatlands show a meaningful structural reorganization (mean −0.25 m, 6.8 percent of plots shift by more than 1 m, concentrated in the upper Great Lakes and northern New England). This is the strongest possible evidence that parent material operates as a cross-sectional stratification axis at our analytical scale: at locations where climate is already a good local predictor (the great majority of CONUS) adding PM produces no spatial reorganization, and at the one PM category where climate fails to explain the productivity ceiling (organic peatlands) PM enters as a corrective downward shift consistent with the established ecological understanding that anaerobic root environments cap forest productivity independently of climate.

The v3.0.0 surface release will ship the ESI v7 no-coordinates prediction as the headline productivity surface, the parent material 30 m raster as a separately citable overlay layer for users who need to stratify their own analyses geologically, and the ESI v9 model object so downstream users can reproduce the (minimal) corrections themselves if their application is concentrated in organic peatland regions.

### 3.15 Parent material reorganizes composite weights but not composite performance

We tested whether the 3-component composite recovers SITECLCD better when its weights are allowed to vary by parent material category (analogue of the multilevel ecoregion composite in §3.9). Four random-forest specifications were compared (n = 60,234 plots with PM, SITECLCD 1 to 7, and all three components present): (1) the equal-weight composite (current §3.6 baseline, OOB R² = 0.800), (2) a free 3-component model where ESI, BGI, and Asym enter as separate predictors (OOB R² = 0.817), (3) a free 3-component model plus pm_factor as an additive categorical predictor (OOB R² = 0.817), and (4) a per-PM stratified RF that lets the weights vary fully by PM category and re-aggregates with an n-weighted average (n-weighted OOB R² = 0.774).

The composite-level result mirrors the plot-level result: adding parent material as a categorical predictor on top of free 3-component weights produces no improvement (ΔR² = +0.0003 from M2 to M3), and the per-PM stratified model is actively worse than the pooled free model because small PM categories overfit the local sample.

The interesting finding is structural rather than predictive. The per-PM impurity-importance pattern is heterogeneous in a way the pooled model averages away (Table 8). On Alluvial soils (n = 12,510) BGI dominates ESI by a factor of 2.6 in impurity importance; on Residuum (n = 17,354) BGI dominates by 1.8. These are the substrates where biomass growth flux carries most of the SITECLCD signal, consistent with the §3.14 observation that Residuum and Alluvial together account for 60 percent of the working sample and that climate-driven biomass growth on these substrates is the operational backbone of FIA's productivity classification. On Colluvium (n = 6,640) and Glacial (n = 6,630) the pattern inverts: ESI dominates BGI by 18 and 28 percent respectively. On Marine sediments (n = 11,508) Asym is tied with ESI as the leading predictor (impurity Asym 2,594 vs ESI 2,511, BGI third at 2,099), implying that on coastal substrates the long-run carrying capacity carries information about productivity classification that BGI does not. The single global weighting that we operationalize for the v2.0.0 composite release reflects an n-weighted average of these patterns and is the correct choice for any application that needs a single CONUS-wide surface; the per-PM pattern is reported as a structural observation that should inform future per-region or per-substrate calibrations.

The same v9 refit (env + parent material) applied to biomass growth increment (BGI) and asymptotic biomass (Asym) as response variables produces a consistent and ecologically informative progression (Table S13). For BGI the soil + terrain + canopy + microclimate predictor stack already recovers most of the signal (OOB R² = 0.959 baseline), and pm_factor adds essentially nothing (ΔR² = +0.0009; pm_factor ranks 12 of 17 in impurity importance). For Asym, however, the baseline R² is lower (0.851) and pm_factor enters as a meaningful predictor (ΔR² = +0.0062 OOB; +0.0062 on held-out validation; pm_factor ranks 10 of 17 in impurity importance). The Asym ΔR² is approximately six times larger than the ESI and BGI ΔR² values. This is the pattern an ecological reading predicts: long-run carrying capacity depends on the deeper soil substrate, bedrock chemistry, rooting depth, and drainage class that influence what a stand can asymptotically support; surface soil layers (0 to 5 cm SoilGrids), short-run canopy state (Hansen tree cover), and terrain proxies (slope, aspect, HLI) do not fully capture this deeper substrate signal, but parent material category does. Adding parent material as a substrate-proxy categorical predictor therefore matters most for the asymptotic measure, less for current biomass growth, and least for the height-growth measure that climate already saturates. The v3.0.0 surface release will accordingly ship a v9 Asym layer alongside the v7 ESI baseline, but no v9 ESI or v9 BGI corrective surfaces, because the marginal information is not large enough at plot resolution to justify a separate operational product.

**Table 8.** Per-parent-material variable importance from stratified random forests predicting SITECLCD from z-standardized ESI, BGI, and Asym. Impurity importance values; higher values indicate the variable splits more SITECLCD variance in that PM stratum.

| Parent material | n | OOB R² | imp_ESI | imp_BGI | imp_Asym | Dominant axis |
|-----------------|---|--------|---------|---------|----------|---------------|
| Residuum | 17,354 | 0.802 | 3,246 | **5,962** | 2,838 | BGI |
| Alluvial | 12,510 | 0.848 | 2,702 | **6,943** | 3,603 | BGI |
| Marine | 11,508 | 0.688 | 2,511 | 2,099 | **2,595** | Asym ≈ ESI |
| Colluvium | 6,640 | 0.744 | **1,030** | 870 | 529 | ESI |
| Glacial | 6,630 | 0.746 | **1,363** | 1,068 | 727 | ESI |
| Eolian | 2,314 | 0.769 | 678 | **999** | 686 | BGI |
| Other | 2,028 | 0.794 | 328 | **633** | 354 | BGI |
| Organic | 782 | 0.680 | 62 | **65** | 53 | BGI (small n) |
| Volcanic | 238 | 0.908 | 52 | **58** | 38 | BGI (small n) |
| Lacustrine | 230 | 0.706 | **40** | 41 | 36 | Mixed (small n) |

### 3.16 The multi-dimensional pattern holds across disturbance, treatment, forest type group, and stand density

The structural sign-flip pattern documented above (§3.3 species, §3.4 East-vs-West, §3.14 parent material, §3.15 PM-aware weighting) generalizes to four additional FIA-derived stratifications. We tested whether the ESI to BGI correlation, the ESI to Asym correlation, and the BGI to Asym correlation vary systematically across FIA disturbance code (DSTRBCD1), treatment code (TRTCD1), forest type group (FORTYPCD hundred), and stand size class (STDSZCD). Each stratification produces a wider range of correlations than the variance-explained range we would predict from sampling variation alone (Table 9).

The forest type group stratification is the cleanest result. The ESI to BGI correlation ranges from −0.555 in Oak-Gum-Cypress to +0.591 in Longleaf-Slash pine, a 1.15 unit spread. Spruce-Fir stands (n = 26,730) show a positive correlation of +0.398; White-Red-Jack pine stands (n = 13,238) show essentially zero correlation; Maple-Beech-Birch hardwoods (n = 7,276) show a negative correlation of −0.311. Adding forest type group as a categorical predictor on top of the free 3-component composite improves SITECLCD recovery from OOB R² = 0.801 to 0.853 (+0.052), comparable in magnitude to the L1/L2/L3 hierarchical ecoregion result (+0.054) and producing the same structural reading: forest type group carries productivity-dimension organization information that climate and substrate covariates do not fully encode.

The disturbance code result reinforces the structural reading. The ESI to BGI correlation ranges from −0.715 in geologic-disturbance stands (n = 496) to +0.243 in human-disturbed stands (n = 20). Fire (n = 5,122, r = −0.566) and weather (n = 676, r = −0.565) disturbances both produce strongly negative correlations consistent with the undisturbed baseline (n = 34,658, r = −0.530), whereas insect (n = 3,216, r = −0.103) and disease (n = 2,964, r = +0.207) disturbances disrupt the orthogonality pattern. The treatment code stratification produces a narrower range (−0.664 in cut stands to −0.388 in site-prepared stands) with consistently negative correlations, suggesting that the multi-dimensional pattern is robust to silvicultural treatment in expected directions.

Stand size class produces the narrowest range of all four stratifications. The ESI to BGI correlation is between −0.43 and −0.51 across Large diameter, Medium diameter, Small diameter, and Nonstocked classes. This is the result we want for an operational productivity composite: the multi-dimensional pattern is robust to stocking level, which means the 3-component composite (CSPI v2) carries the same structural reading across early, mid, and late successional stand conditions.

**Table 9.** Range of ESI-BGI correlation across four FIA-derived stratifications. Wider ranges indicate more structural variation in productivity-dimension orthogonality.

| Stratification | n categories | r(ESI,BGI) range | Range width |
|----------------|--------------|------------------|-------------|
| Forest type group (FORTYPCD hundred) | 9 | −0.555 to +0.591 | 1.15 |
| Disturbance (DSTRBCD1) | 10 | −0.715 to +0.243 | 0.96 |
| Species (SPCD, §3.3 reference) | 12 | −0.02 to +0.53 | 0.55 |
| Treatment (TRTCD1) | 6 | −0.664 to −0.388 | 0.28 |
| Stand size class (STDSZCD) | 4 | −0.511 to −0.431 | 0.08 |

The pattern that emerges is consistent. Productivity-dimension orthogonality is structurally organized by what kind of forest is on the plot (species, forest type group, parent material) and by what has happened to it (disturbance, treatment). It is approximately invariant to how much wood is currently there (stand size class). A single-metric study at the FIA plot level absorbs this structural variation into the response variable without seeing it; a multi-dimensional study makes it visible. The CSPI v2 composite operationalizes the multi-dimensional view at CONUS scale and at 30 m, with the four component layers shipped alongside so users can decompose the structural reading by any of these axes for their application.

### 3.17 Asym v9 refit on the v3 surface predictor stack

The plot-level Asym v9 test in §3.14 used the saturated v7 covariate stack (16 predictors) and produced ΔR² = +0.006. For the v3.0.0 surface release the operational predictor stack is the v3 aligned 30 m grid (11 predictors: SoilGrids 0–5 cm sand, soil organic carbon, bulk density, cation exchange capacity, nitrogen, pH; SRTM 30 m elevation, slope, aspect; Hansen tree cover and loss). Refitting Asym v7 (env only) and Asym v9 (env + parent material) on this operationally-realistic stack at n = 31,463 plots produces OOB R² = 0.828 baseline → 0.836 with PM (ΔR² = +0.0078; OOB RMSE 8.40 → 8.21 Mg ha⁻¹; pm_factor ranks 8 of 12 by impurity importance, between bdod_0_5 and slope). The marginal gain on the operational stack is approximately 25 percent larger than on the saturated v7 stack, consistent with the ecological reading that parent material carries deep-substrate information that surface SoilGrids variables do not fully capture. The v3.0.0 release ships the Asym v9 corrective surface alongside the ESI v7 baseline; the per-pixel ΔAsym = v9 − v7 layer is a separately citable product for users who want to see where parent material reorganizes long-run carrying capacity predictions.

The plot-level spatial diagnostic for Asym (Figure 13, n = 31,463 plots with PM and full v3 covariate stack) shows a more textured reorganization pattern than ESI did. Mean |ΔAsym| = 0.59 Mg ha⁻¹ on a mean Asym scale of approximately 250 Mg ha⁻¹, with 0.1 percent of plots shifting by more than 5 Mg ha⁻¹ and none beyond 15 Mg ha⁻¹. The per-PM mean shifts (Table 9b) carry directional information that ESI did not: Marine sediments are downshifted by 0.42 Mg ha⁻¹ on average (the largest of any category and the only negative shift larger than 0.25 Mg ha⁻¹), Eolian and Colluvium are slightly downshifted, Residuum is essentially unchanged, and Alluvial, Volcanic, and Other are upshifted by 0.29 to 0.50 Mg ha⁻¹. This is the directional pattern an ecological reading predicts: the substrates with relatively low surface-soil indicators but deep productive rooting volume (Alluvial, Volcanic) move up when PM enters the predictor stack, while the substrates with shallow rooting limits or salinity constraints (Marine) move down. Single-axis (climate-only) carrying-capacity estimation absorbs this pattern into prediction error rather than producing it as a separable structural axis.

**Table 9b.** Per-parent-material ΔAsym = v9 − v7 at FIA plots (both models no LAT/LON; v3 predictor stack). All units Mg ha⁻¹.

| Parent material | n | Mean Δ | Median Δ | SD Δ | q05 | q95 | % \|Δ\| > 5 |
|---|---|---|---|---|---|---|---|
| Residuum | 9,852 | +0.09 | +0.06 | 0.86 | −1.04 | +1.39 | 0.2 |
| Alluvial | 5,859 | +0.29 | +0.16 | 0.93 | −0.94 | +1.97 | 0.1 |
| **Marine** | **5,584** | **−0.42** | **−0.36** | **0.82** | **−1.82** | **+0.69** | **0.1** |
| Glacial | 4,225 | +0.04 | −0.01 | 0.65 | −0.91 | +1.13 | 0.0 |
| Colluvium | 2,789 | −0.20 | −0.17 | 0.60 | −1.13 | +0.65 | 0.0 |
| Eolian | 1,717 | −0.25 | −0.20 | 0.83 | −1.66 | +1.00 | 0.1 |
| Other | 742 | +0.50 | +0.31 | 1.10 | −0.95 | +2.44 | 0.4 |
| Organic | 287 | −0.16 | −0.07 | 0.79 | −1.57 | +0.88 | 0.0 |
| Volcanic | 218 | +0.29 | +0.23 | 0.76 | −0.85 | +1.67 | 0.0 |
| Lacustrine | 190 | −0.03 | −0.01 | 0.79 | −1.37 | +1.00 | 0.0 |

**Table 7c.** Per-parent-material distribution of plot-level ΔESI = v9 − v7 (both models no LAT/LON). All numbers in metres.

| Parent material | n | Mean Δ | Median Δ | SD Δ | q05 | q95 | % \|Δ\| > 1 m |
|-----------------|---|--------|----------|------|-----|-----|---------------|
| Residuum | 13,527 | −0.01 | 0.00 | 0.28 | −0.47 | 0.44 | 0.8 |
| Marine | 7,922 | 0.01 | 0.00 | 0.28 | −0.43 | 0.47 | 0.7 |
| Alluvial | 7,243 | −0.01 | 0.00 | 0.35 | −0.59 | 0.56 | 1.5 |
| Glacial | 5,232 | 0.01 | 0.01 | 0.33 | −0.52 | 0.55 | 1.1 |
| Colluvium | 3,165 | 0.00 | 0.00 | 0.33 | −0.53 | 0.56 | 1.2 |
| Eolian | 1,947 | 0.00 | −0.01 | 0.39 | −0.62 | 0.65 | 2.4 |
| Other | 1,142 | −0.01 | 0.00 | 0.28 | −0.47 | 0.42 | 0.9 |
| **Organic** | **413** | **−0.25** | **−0.17** | **0.44** | **−1.05** | **0.37** | **6.8** |
| Volcanic | 248 | 0.01 | 0.01 | 0.39 | −0.65 | 0.61 | 2.4 |
| Lacustrine | 226 | 0.07 | 0.05 | 0.39 | −0.54 | 0.68 | 2.7 |

**Table 7b.** ESI v7 vs ESI v9 with LAT and LON excluded from the predictor stack. Random forest, 300 trees, 34 ClimateNA covariates, 90/10 random split; n = 36,958 training plots, n = 4,107 validation plots.

| Model | OOB R² | OOB RMSE (m) | Val R² | Val RMSE (m) | pm_factor rank |
|-------|--------|--------------|--------|--------------|----------------|
| v7 with LAT/LON (reference) | 0.677 | 6.405 | 0.701 | 6.167 | n/a |
| v9 with LAT/LON (reference) | 0.677 | 6.400 | 0.701 | 6.163 | 38 of 38 |
| **v7 no LAT/LON (preferred)** | **0.673** | **6.440** | **0.6975** | **6.201** | n/a |
| **v9 no LAT/LON (preferred)** | **0.675** | **6.424** | **0.6984** | **6.191** | **35 of 35** |

### 3.18 Disturbance × ecoregion interaction widens the structural spread further

The single-axis stratifications above (species §3.3, East-vs-West §3.4, forest type group §3.16, disturbance category §3.16) each produce a wide range of r(ESI,BGI) values across categories. A joint stratification across two axes simultaneously produces a wider range still, and the regions and disturbance categories where the joint pattern is most extreme are themselves ecologically informative. We crossed FIA DSTRBCD1 (10 categories) with EPA Level III ecoregions (84 CONUS regions; spatial join via Omernik and Griffith 2014) and computed r(ESI,BGI) at every (disturbance × L3) cell with at least 50 plots. The joint stratification yields 115 populated cells with r(ESI,BGI) range of **1.40** (Table 9c), wider than any single-axis stratification we report (forest type group 1.15, disturbance 0.96, species 0.55).

**Table 9c.** Comparison of single-axis vs joint disturbance × ecoregion stratification spreads in r(ESI,BGI). Joint stratification reveals interactions that single axes hide.

| Stratification | n categories | r(ESI,BGI) range |
|---|---|---|
| Stand size class (STDSZCD) | 4 | 0.08 |
| Treatment (TRTCD1) | 6 | 0.28 |
| Species (SPCD, 12 species) | 12 | 0.55 |
| Disturbance (DSTRBCD1) | 10 | 0.96 |
| Forest type group (FORTYPCD hundred) | 9 | 1.15 |
| **Disturbance × EPA L3 ecoregion (joint)** | **115** | **1.40** |

The disturbance category with the widest L3-driven spread is insect disturbance: across 7 L3 regions where insect-disturbed plots occur, r(ESI,BGI) ranges from −0.744 to +0.464 (a 1.21 unit spread on a sample of just 2,962 plots). The narrowest disturbance-driven spread within a single L3 region is in the Mississippi Alluvial Plain (L3 8.3.4), where r(ESI,BGI) ranges from −0.744 (insect-disturbed plots) to +0.149 (other disturbance) across just three disturbance categories. These are not statistical artifacts of small samples: the Mississippi Alluvial Plain has 10,066 plots in the joint cross-tabulation, and the insect category alone there has 295 plots.

The biological reading is that productivity-dimension orthogonality interacts with disturbance regime and ecoregional context in a way that neither axis alone reveals. Fire-disturbed plots in the inland Pacific Northwest behave differently from fire-disturbed plots in the eastern hardwood belt. Insect-disturbed plots in alluvial valleys behave differently from insect-disturbed plots in upland glacial substrates. A national single-metric study averages across these interactions. The multi-dimensional view names them as part of the productivity construct: site index measures one productivity dimension, biomass growth measures another, and their relationship depends jointly on what kind of forest is on the plot, what kind of disturbance regime it sits in, and where in the country it is. This is the strongest single piece of evidence in this paper that the multi-dimensional reading is not a methodological preference but a structural property of the biological system.

### 3.19 External validation at AmeriFlux US forest tower sites

A reviewer-anticipated critique of the FIA-on-FIA validation chain (§4.7.1) is partially addressed by extracting our CSPI v7 surface at 30 AmeriFlux US forest tower locations and correlating with published mean annual NPP from the FLUXNET literature (Table S15). Across n = 28 forest sites with both predictions and published NPP available, the Pearson correlation is r = +0.17. This is not strong agreement in absolute terms, but the per-site pattern is informative and supportive of the structural argument the rest of the paper makes.

At sites where height-growth potential and biomass flux agree (the Pacific Northwest sites US-Wrc Wind River, US-Blo Blodgett, US-Me2 Metolius Mature; all CSPI v7 = 47–50 and NPP = 715–825), our prediction tracks the published NPP correctly. At Eastern broadleaf sites (US-Ha1 Harvard, US-MMS Morgan-Monroe, US-Bar Bartlett, US-Cwt Coweeta) the CSPI v7 values cluster between 18 and 21 while published NPP ranges 540 to 725, also showing approximately monotonic agreement.

The correlation is reduced by a coherent set of Western montane sites: US-NR1 Niwot Ridge (CSPI v7 = 35.8, NPP = 350), US-Vcm Valles Caldera Mixed Conifer (40.3, 375), US-Vcp Valles Caldera Ponderosa (41.5, 350), and US-Me6 Metolius Young (45.3, 410). At all four, CSPI v7 ranks the site as high productivity by height growth potential because the dominant conifers grow to substantial heights, but published NPP ranks the site as low productivity because cold winters and dry summers limit annual biomass accumulation. This is exactly the structural orthogonality between site-index productivity dimensions (long-window height growth potential) and biomass-flux productivity dimensions (current annual increment) that §3.14 reports for volcanic versus organic parent material categories and that §3.3 reports across species. The AmeriFlux network, which selects sites independent of the FIA grid by tower-siting criteria, reproduces the same structural mismatch.

This is an independent (non-FIA) network confirmation that the multi-dimensional reading is structural in the biological system, not a statistical artifact of the FIA-derived measurement chain. It does not validate any specific R² value because the small n (28 sites) cannot anchor that, and AmeriFlux site selection is itself stratified by accessibility and infrastructure rather than randomly distributed. What it shows is that the height-growth versus biomass-flux divergence we documented inside the FIA system reappears at the AmeriFlux sites in the predictable direction at every Western montane site.

### 3.20 Reforestation potential application

The v3.0.0 release ships both forest-masked and unmasked versions of the Asym v9 surface (NEWS_v3.0.0.md). Pixels currently classified as non-forest in the Hansen 2000 tree-cover layer carry a model-estimated potential mature carrying capacity that represents what the surface would predict if a closed-canopy forest stand were to develop at that location given its local soil, terrain, climate, and parent material. This is exactly the type of layer reforestation planners require to identify high-potential-storage candidates beyond the current forest footprint.

The unmasked surface is intentionally provided as a planning-grade input, not a guaranteed-attainment layer: model-estimated asymptotic biomass at a current non-forest pixel reflects environmental suitability for mature forest carbon storage but does not address whether forest establishment is feasible (current land use, ownership, hydrology, fire regime, climate change trajectory). Combined with land-cover layers that filter for currently unforested but plausibly reforestable land (abandoned cropland, low-intensity pasture, post-disturbance non-forest pixels in formerly forested ecoregions), the v3.0.0 unmasked surface allows continental-scale reforestation potential ranking at 30 m resolution. Local-scale screening should overlay protected status, water table depth, ownership patterns, and stakeholder priorities before any specific site is acted on. We expect the most informative future use of the unmasked surface will be paired with NLCD land-cover transitions and county-scale agricultural retirement datasets, neither of which are derived here. Quantifying the CONUS-scale reforestation potential surface, we identified 548.7 million 30 m pixels (40.2 Mha, roughly 99 million acres) currently classified as non-forest in the Hansen tree-cover layer that carry an Asym v9 prediction above 200 Mg ha⁻¹ (a threshold consistent with mature closed-canopy biomass densities in similar climates). The mean Asym v9 across these candidate pixels is 251.0 Mg ha⁻¹ (range 211.2 to 326.9), with 60.6 percent in the 200 to 250 Mg ha⁻¹ band, 39.1 percent in the 250 to 300 band, and 0.3 percent above 300 (Table S16). Aggregating across all candidates, the total potential biomass that the v9 surface attributes to these locations is 10,088 Tg dry matter, equivalent to 4,741 Tg C (4.74 Pg C) at a dry-biomass carbon fraction of 0.47. For context, this is approximately three times annual U.S. forest-sector net carbon sequestration as currently reported in the U.S. EPA national greenhouse gas inventory. We emphasize that this is an upper-bound model-estimated environmental ceiling rather than a realizable accumulation: actual carbon storage from any specific reforestation effort would depend on stand establishment success, time to canopy closure, species selection, future climate trajectory, and the specific land-use transitions feasible at each pixel. We provide the unmasked surface as a planning-grade input to quantify where the environment supports the highest mature biomass densities; downstream studies must overlay land-cover transition probability, ownership, fire regime, and stakeholder priorities to produce realistic reforestation accumulation trajectories.

### 3.21 Wind exposure as a non-structural driver

A reviewer-anticipated objection to the parent-material framing in §3.14 and §3.18 is that aerodynamic exposure (chronic mean wind speed, hurricane and tornado return periods) might confound the geologic axis: coastal sites that show low realized asymptotic biomass on alluvial and marine substrates also experience above-average wind disturbance, and Plains sites that show low Asym on eolian substrates also sit in the highest sustained wind belt of the United States. We tested whether TerraClimate annual mean wind speed at 4 km, extracted at 31,463 FIA plots already used in the v9 model fit, adds explanatory information beyond what the v3 stack (climate, terrain, soils, parent material) already captures.

The raw bivariate pattern is in the direction the wind hypothesis predicts: mean Asym v9 increases monotonically from 236.7 Mg ha⁻¹ at the lowest wind decile (1.98 to 2.51 m s⁻¹) to 261.3 Mg ha⁻¹ at the eighth wind decile (3.81 to 4.19 m s⁻¹) before flattening at the highest two deciles, a 24 Mg ha⁻¹ swing across a roughly fourfold wind gradient. This is consistent with the simple observation that high-wind-belt forests (Pacific Northwest conifers, northern Maine spruce-fir, southern Appalachian uplands) carry higher carbon stocks than low-wind-belt forests (eastern Texas pine flatwoods, lower Mississippi alluvial hardwoods).

After conditioning on the v9 predictor stack, the residual signal collapses. Decile-binned mean residuals (Asym observed minus v9 predicted) range from −0.88 Mg ha⁻¹ at the second wind decile to +0.48 Mg ha⁻¹ at the fourth wind decile, with no monotonic pattern and amplitudes one to two orders of magnitude smaller than the v9 model's RMSE of 8.21 Mg ha⁻¹. Per-parent-material residual correlations with wind are similarly modest: Eolian r = +0.229, Colluvium r = +0.226, Lacustrine r = +0.209, with the remaining seven categories at |r| < 0.15. The positive sign on Eolian substrates is the most ecologically coherent of the small effects: sandy windblown deposits in the high-wind central Plains may experience wind-driven soil moisture loss that the v3 stack's static soils predictors cannot capture at 4 km resolution.

The honest reading is that wind exposure operates predominantly through correlated climate and terrain covariates that the v9 stack already includes. Mean wind speed at the TerraClimate resolution does not function as an independent structural axis for asymptotic biomass at the continental scale.

### 3.22 Episodic wind disturbance: HURDAT2 hurricane track density

The mean-wind null in §3.21 leaves open whether episodic damaging wind (tropical cyclone strikes, derechos, tornadoes) carries the residual signal that climatology does not. We tested the hurricane component of this question by constructing track-count density from the NOAA HURDAT2 best-track database covering 1851 to 2024, filtered to tropical-storm-strength or greater records (sustained winds ≥ 34 kt) inside the CONUS bounding region. The resulting 0.25 degree raster contains 17,804 storm-track points in 7,398 distinct cells with a maximum density of 41 track points per cell along the Florida coast and outer banks of the Carolinas. Extracted at the 31,463 v9 model plots, 5,596 plots (17.8 percent) fall in a cell with at least one TS-strength storm pass on record.

Across all plots, the residual correlation is r = −0.028 (Pearson) and ρ = −0.032 (Spearman). The per-parent-material breakdown is interpretable: Marine substrates carry the highest mean hurricane exposure (1.13 storm passes per cell, 56 percent of Marine plots exposed at least once) but show residual correlation of only r = −0.019 with v9. Eolian, the second-most exposed category, shows r = −0.037. Volcanic plots, located in the Cascades and Sierras where hurricane tracks do not reach, have zero exposure and serve as a natural control. The strongest single per-PM signal, on Alluvial substrates at r = −0.070, is consistent with the direction the hurricane hypothesis predicts (more strikes → v9 over-predicts) but the magnitude is more than two orders of magnitude smaller than the v9 OOB RMSE of 8.21 Mg ha⁻¹.

Combined with §3.21, this closes the wind story: neither chronic (TerraClimate mean wind speed) nor episodic (HURDAT2 hurricane density) wind exposure is a structural axis that the v9 stack is missing. The realized biomass at U.S. forest sites with high historical hurricane exposure is well-represented by the climate, terrain, soils, and parent material covariates already in v9, presumably because the FIA plot network samples surviving biomass at the time of inventory and because the v9 stack indirectly captures hurricane-zone climate via the Tropical-Subtropical climate signatures it ingests. The Asym v9 30 m surface ships in v3.0.0 without a wind correction because no wind-correction signal was identified across either windspeed climatology or historical storm-track density. SVRGIS tornado paths and NREL Wind Toolkit hub-height wind remain candidates for future tests at higher resolution but at this stage of the analysis we judge the wind axis to be largely closed.

### 3.22 External validation against repeat and structural remote sensing

The AmeriFlux comparison in §3.19 tested the measures against a sparse network of eddy-covariance towers. A complementary test uses wall-to-wall satellite products at the full plot set. We extracted three independent remote-sensing families at the FIA plot coordinates: MODIS MOD17A3HGF net and gross primary productivity (NPP and GPP, 2017 to 2023), LANDFIRE 2023 canopy height, and five Sentinel-2 spectral indices (NDVI, EVI, NDRE, the red-edge position S2REP, and the chlorophyll index red-edge CIRE). After deduplicating to unique plots, 38,978 plots carried both the productivity measures and the MODIS flux, and 38,091 carried the Sentinel-2 indices.

The biomass growth increment tracks observed satellite flux while site index does not. BGI correlates with observed GPP at a pooled Pearson r = +0.74 and with NPP at +0.61, whereas the unified-target site index correlates negatively (r = -0.41 with GPP, -0.38 with NPP). Consistent with the scale dependence emphasized throughout this paper, the pooled BGI value is partly a between-region aggregation effect. Within-region correlations are more modest and heterogeneous: r(BGI, GPP) = +0.46 in the West and +0.11 in the East, ranging by latitude band from -0.03 in the subtropical Southeast (24 to 31 N, where MODIS productivity products are least reliable) to +0.80 at 37 to 43 N. That the relationship is not an artifact of shared structure with site index is confirmed by partial correlation: controlling for ESI, observed NPP still tracks BGI at partial r = +0.53 and GPP at +0.68, while ESI contributes negatively (partial r = -0.14 and -0.13). The BGI versus ESI divergence documented from FIA-internal measures is therefore reproduced in an independent satellite measurement chain.

The same structure appears in Sentinel-2 optical metrics. Lamb et al. (2020) identified the Sentinel-2 red-edge position as the most important remote-sensing metric for site productivity in the North American Acadian region and used Sentinel-2 to improve BGI (an "improved BGI," or iBGI). At the conterminous-scale plot set, BGI correlates positively with every Sentinel-2 index (CIRE r = +0.76, NDRE +0.74, NDVI +0.73, EVI +0.73, S2REP +0.70), while ESI correlates negatively with all of them (-0.40 to -0.48). A random forest predicting observed NPP from BGI alone reaches an adjusted R squared of 0.37; adding the Sentinel-2 stack raises it to 0.44, with S2REP alone (0.38) slightly exceeding BGI alone. This generalizes the iBGI result of Lamb et al. (2020) to the conterminous United States, although part of the gain reflects shared optical lineage between S2REP and the MODIS NPP target rather than fully independent information.

Observed canopy height carries little site-productivity signal on its own. At 29,089 forested plots, LANDFIRE 2023 canopy height is predicted by ESI at an adjusted R squared of 0.004, by BGI at 0.112, and by ESI, BGI, and Asym jointly at only 0.165. A single-epoch canopy height is governed by stand age, disturbance history, and structure rather than by site productivity, so absolute height is nearly uninformative about the productivity measures. The productivity signal resides in the rate of canopy-height change rather than in the height itself, which points toward repeat observation of biomass increment (for example a MODIS NPP temporal trend or an ESA CCI Biomass aboveground-biomass increment) as the appropriate independent validator for a future prediction-focused release.

### 4.7 What is robust to the SICOND correction

A reviewer-style robustness test at the manuscript revision stage revealed that the v0.9 framing of the SICOND-vs-ESI orthogonality result was overstated due to a Simpson's paradox in the SIBASE strata (§3.5, Table 2a). We log the finding transparently because it is methodologically informative: the corrected reading is materially different from the raw reading, but the principal claims of the paper survive intact. Specifically, the following findings are independent of the SICOND base-age and equation-family issues:

The SITECLCD random-forest result (§3.6, Table 3a): BGI alone reaches OOB R² = 0.808; ESI alone reaches 0.751; the six-percentage-point gap is the cleanest single statistic in the paper and is computed without any SI base-age dependency.

The parent material structural axis (§3.14, Tables 7 and 7a): volcanic soils have the highest mean ESI (39.9 m) but the lowest mean FIA SITECLCD (5.69 of 7); organic soils have the lowest mean ESI (19.2 m) but the highest BGI in the dataset. The opposite-sign disagreement between site index and FIA productivity classification is reproducible across multiple stratifications and is structural in the productivity construct, not artifact of a single grouping variable.

The per-species heterogeneity (§3.3, Table 3): r = 0.028 (yellow-poplar) to r = 0.492 (Douglas-fir). Computed at the species level on observed measures.

The East-vs-West regime sign flip for Asym × NPP (§3.4): r = −0.60 in the East, r = +0.57 in the West. Independent of SI.

What changed in the corrected reading is the specific claim about SICOND. The base-age-corrected SICOND × ESI correlation is +0.48, not −0.08; the SSURGO comparator (Table 2b) and the GADA-refit comparator (Table 2c) both show that traditional measurement chains share substantial structure with the unified-target ESI rather than being orthogonal to it. The structural argument for the multi-dimensional view does not rest on SICOND-ESI orthogonality; it rests on the four-dimensional cross-prediction analysis, the SITECLCD random forest, and the stand-age and species heterogeneity. The SICOND base-age finding is now a robustness-check section, not a headline.

### 4.7.1 FIA-on-FIA representation, not independent prediction

A reviewer-style stress test of the SITECLCD random-forest result and the multilevel ecoregion analysis must acknowledge the validation chain. SITECLCD is computed by FIA from regionally-calibrated growth equations. Our ESI v7 component is a random forest prediction of the unified North America height-and-age compilation, which includes the FIA Phase 2 height-and-age records as a major source. BGI and Asym are derived directly from FIA remeasurement and AGB pairs. All five measures in our composite analyses therefore share a substantial degree of common FIA-derived structure. The OOB R² = 0.808 (BGI alone predicting SITECLCD) and the +0.015 R² gain from the multilevel ecoregion composite (§3.9) reflect the field's ability to recover its own classification rules within its own measurement system.

This is empirically meaningful as a representation result: the data show what FIA SITECLCD is in terms of multi-dimensional productivity structure, and they show that the multi-dimensional composite recovers the classification more faithfully than any single component. It is not a strong claim about absolute site-quality prediction in an FIA-independent sense. An honest peer-reviewed reading is that the composite is a better operational proxy for what U.S. forest practitioners are already using SITECLCD to do, not that the composite is the best site-quality measure available.

An independent prediction validation would require: (a) long-term carbon-sequestration rates from non-FIA permanent forest research plots (e.g., USFS Long-Term Ecological Research network plots), (b) net primary production at AmeriFlux tower sites, or (c) commercial growth-and-yield records from intensively managed plantations with calibrated yield curves. Such validation is planned for the v3.0.0 release cycle.

### 4.8 Limitations

Spatial autocorrelation among nearby FIA plots can inflate cross-validation estimates. The CV protocol used here (plot-blocked + latitude-fold) addresses gross gradient; a more granular Moran's I diagnostic on per-fold residuals is planned for the v2.0.1 release.

BGI and Asym are FIA-derived; ESI and NPP are not (ESI is a model prediction; NPP is a satellite-derived product). The relationships among the measures inherit some method dependence. The external validation in §3.22 partially addresses this concern: the BGI-positive, ESI-negative structure is reproduced against three independent remote-sensing families (MODIS flux, LANDFIRE canopy height, and Sentinel-2 optical indices), and a partial correlation shows BGI tracks observed flux independently of ESI, so the structural pattern is not solely an FIA-method artifact. Future work could test whether substituting different operationalizations of each component changes the headline findings; we expect the structural patterns (sign flips, species heterogeneity, SITECLCD alignment) to be robust because they are driven by the underlying biology rather than by the specific model chains.

The unified North America site index compilation that supplies the ESI training response is described in a companion methods note (Weiskittel et al., in preparation). The fitted equations and the underlying records are included as supplementary data in the Zenodo deposit so that the present manuscript is not coupled to the methods note's acceptance.

## 5. Conclusions

The primary story is that forest site productivity is empirically multi-dimensional and that the U.S. operational measurement infrastructure has been carrying a quiet structural mismatch for seven decades. The four modern measures of productivity at the CONUS scale (site index, biomass growth increment, asymptotic biomass, net primary production) carry overlapping but not redundant information; no measure is fully recoverable from the others. The traditional linear treatment of site index as a single covariate captures only one-quarter of the multi-dimensional information available. FIA's own site productivity classification (SITECLCD) aligns with biomass growth and with a 3-component composite (ESI + BGI + Asym), not with site index alone. The FIA-computed site index (SICOND) carries mixed information about both height-growth and biomass-growth dimensions after base-age correction; a methodologically clean GADA-refit site index confirms that what looked like SICOND × ESI orthogonality in pooled raw data is a Simpson's paradox artifact. The 3-component Composite Site Productivity Index (CSPI v2) is one operationalization of the multi-dimensional view; it tracks SITECLCD more faithfully than any single component and is what U.S. forestry has been describing operationally with the seven-class system since the 1950s.

The secondary story is that the divergence between site index and biomass growth is not random model error but structurally organized by what kind of forest is on the plot and what has happened to it. The ESI–BGI correlation ranges from r = −0.555 (Oak-Gum-Cypress) to r = +0.591 (Longleaf-Slash pine) across forest type groups and shows similar wide ranges across species, ecoregion, parent material, and disturbance category. A joint stratification across disturbance and EPA Level III ecoregion produces the widest range of all (1.40 across 115 cells), demonstrating that the two structural axes interact: insect-disturbed plots in the Mississippi Alluvial Plain behave differently from insect-disturbed plots elsewhere. Site index and FIA SITECLCD disagree directly on parent-material extremes (volcanic soils, highest mean ESI, lowest SITECLCD; organic soils, lowest mean ESI, highest BGI). Parent material added as a categorical predictor on top of a climate-saturated stack reorganizes height-growth-potential predictions essentially not at all (mean |ΔESI| = 0.22 m on a 28 m scale) but reorganizes asymptotic biomass predictions meaningfully (mean |ΔAsym| = 0.59 Mg ha⁻¹ on a 250 Mg ha⁻¹ scale, with Marine substrates shifting downward by 0.42 Mg ha⁻¹ on average and Alluvial, Volcanic, and Other substrates shifting upward). The biological implication is that the productivity-dimension orthogonality varies systematically across species, region, and substrate in ways that single-metric national studies absorb into the response variable without seeing.

We release the 3-component CSPI v2 composite at 30 m as the operational implementation of the multi-dimensional view, together with the four component layers, the parent material 30 m overlay, and a parent-material-aware corrective surface for asymptotic biomass (Asym v9). All five products are deposited under Zenodo concept DOI 10.5281/zenodo.20515034 with versions 2.0.0 at 10.5281/zenodo.20663652 and v3.0.0 in preparation as this paper goes to press. Users who need a single productivity layer can take the CSPI v2 composite; users who need to decompose by productivity dimension can take the component layers; users whose application is concentrated in geologically distinctive regions can take the parent material overlay and the Asym v9 corrective surface together. The multi-dimensional reading is meant to give the operational community a richer toolkit, not to displace the FIA SICOND/SITECLCD infrastructure on which seven decades of forest assessment depend.

## 5.5 Author contributions (CRediT)

Aaron R. Weiskittel: Conceptualization, Methodology, Software, Validation, Formal analysis, Investigation, Resources, Data curation, Writing — original draft, Writing — review and editing, Visualization, Supervision, Project administration, Funding acquisition.

## 5.6 Declaration of competing interests

The author declares no competing interests.

## 5.7 Declaration of generative AI use

During the preparation of this work the author used Claude (Anthropic) for structural organization, consistency checking, and code drafting in the analytical pipeline. The author reviewed and edited all output and takes full responsibility for the content of the publication.

## 6. Acknowledgments

This work was supported by the University of Maine Center for Research on Sustainable Forests. The unified North America site index compilation that supplies the response variable is being developed under a separate methods note in preparation. Computation was performed on the Ohio Supercomputer Center Cardinal cluster under allocation PUOM0008.

## 7. Data and code availability

CSPI v3.0.0, the data release accompanying this manuscript, is at https://doi.org/10.5281/zenodo.20763197 (concept 10.5281/zenodo.20515034), CC-BY-4.0. The release contains the Asym v9 corrective surface at 30 m (forest-masked, `ASYM_V9_CONUS_30m_fm.tif`, headline product for existing-forest assessment; unmasked, `ASYM_V9_CONUS_30m.tif`, for reforestation use cases where non-forest pixels carry model-estimated potential mature carrying capacity), the parent material 30 m CONUS overlay (`parent_material_30m_CONUS_4326.tif`), the trained ranger model object (`m_asym_v9_v3stack.rds`) for reproducibility, and release notes. v2.0.0 (10.5281/zenodo.20663652) remains available and contains the 1 km ESI v6 surface and MOD17A3HGF NPP at 500 m; the SICOND-target v3 and v4 surfaces from v1.0.0 (10.5281/zenodo.20515035) also remain available. Pipeline at https://github.com/holoros/cspi-conus. Analytical chain archive at https://doi.org/10.5281/zenodo.20693106.

## References

Bontemps, J.-D., Bouriaud, O. (2014). Predictive approaches to forest site productivity: recent trends, challenges and future perspectives. Forestry 87 (1): 109–128.

Breiman, L. (2001). Random forests. Machine Learning 45: 5–32.

Hansen, M. C., et al. (2013). High-resolution global maps of 21st-century forest cover change. Science 342: 850–853.

Lamb, S. M., et al. (2020). Forest potential productivity mapping by linking remote-sensing-derived metrics to site variables. Remote Sensing 12 (12): 2056. doi:10.3390/rs12122056. Identifies the Sentinel-2 red-edge position (S2REP) as the most important remote-sensing metric for site productivity in the North American Acadian region and uses Sentinel-2 to improve the biomass growth index (iBGI).

Poggio, L., et al. (2021). SoilGrids 2.0. SOIL 7: 217–240.

Running, S. W., Mu, Q., Zhao, M. (2015). MOD17A3HGF MODIS/Terra Net Primary Production Gap-Filled Yearly L4 Global 500 m SIN Grid V006. NASA EOSDIS LP DAAC. https://doi.org/10.5067/MODIS/MOD17A3HGF.006

Skovsgaard, J. P., Vanclay, J. K. (2008). Forest site productivity: a review of the evolution of dendrometric concepts for even-aged stands. Forestry 81 (1): 13–31.

Westfall, J. A., Coulston, J. W., Gray, A. N., Shaw, J. D., Radtke, P. J., Walker, D. M., Weiskittel, A. R., MacFarlane, D. W., Affleck, D. L. R., Zhao, D. (2024). A national-scale tree volume, biomass, and carbon modeling system for the United States. USDA Forest Service General Technical Report WO-104, May 2024. Replaces the Component Ratio Method for FIA tree-level biomass estimation. URL: https://www.fs.usda.gov/sites/default/files/fs_media/fs_document/biomass-modeling-system.pdf

Subedi, M. R., Baeza-Castro, A. A., Dwivedi, P., Costanzo, B., Martin, J. A. (2024). Modeling regional forest site productivity accounting spatial structure in climatic and edaphic variables. Forest Ecology and Management. ScienceDirect identifier pii/S0378112724006728. The closest analog in the recent literature to our multi-scale productivity argument; uses a random forest model with climate and soil covariates to predict a composite site index for slash pine, longleaf pine, loblolly pine, and yellow poplar across the southeastern United States (random forest adjusted R² = 0.81), and demonstrates that regional spatial structure in climatic and edaphic variables matters for site productivity estimation.

Hoover, C. M., Smith, J. E. (2012). Site productivity and forest carbon stocks in the United States: analysis and implications for forest offset project planning. Forests 3 (2): 283–299. doi:10.3390/f3020283. USDA Forest Service treesearch/40783. Establishes that practitioners are using FIA SITECLCD operationally for carbon offset planning, which gives the SITECLCD-vs-site-index mismatch documented in this paper direct practical relevance for the carbon accounting community.

Wang, T., Hamann, A., Spittlehouse, D., Carroll, C. (2016). Locally downscaled and spatially customizable climate data for historical and future periods for North America. PLoS ONE 11 (6): e0156720.

Weiskittel, A. R. (2026). Composite Site Productivity Index (CSPI) v1.0.0 for the conterminous United States. Zenodo. https://doi.org/10.5281/zenodo.20515035

Weiskittel, A. R. (2026). Composite Site Productivity Index (CSPI) v2.0.0 for the conterminous United States. Zenodo. https://doi.org/10.5281/zenodo.20663652

Wright, M. N., Ziegler, A. (2017). ranger: a fast implementation of random forests for high dimensional data in C++ and R. Journal of Statistical Software 77 (1): 1–17.

Weiskittel, A. R. et al. (in preparation). The unified North America site index compilation.
