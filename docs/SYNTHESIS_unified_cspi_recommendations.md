# Toward a robust unified CONUS site productivity measure: synthesis and recommendations

*14 June 2026. Aaron R. Weiskittel, CRSF, University of Maine. A strategic synthesis of the CSPI v0.10d analytic chain. For stakeholder briefings, collaborator integration discussions, and follow-on funding proposals.*

---

## The bottom line

A single national productivity metric will not serve the field well. The data show forest site productivity is intrinsically multi-dimensional, the relationships among measures depend strongly on context, and the operational classification that practitioners have used for seven decades (FIA SITECLCD) tracks biomass growth more closely than site index. The right unified product is a multi-measure composite released alongside its components with explicit documentation of when each measure is the appropriate one.

The Composite Site Productivity Index (CSPI) v2.0.0, released June 2026 at Zenodo concept DOI 10.5281/zenodo.20515034, is the first version of that unified product. It captures both local drivers (through 30 m soil, terrain, canopy, and microclimate covariates) and regional drivers (through ClimateNA distillation and MODIS NPP). It is operational now; v2.1.0 will expand the 30 m wall-to-wall surface release once Zenodo storage quota is approved.

## How the unified measure captures local and regional drivers

| Driver scale | Mechanism in CSPI v2 | Resolution |
|---|---|---|
| Local soil and terrain | 11 covariates in the ESI v5 predictor stack (soil sand, silt, clay, OM, BD, pH, CEC, AWC, SOC, Ksat; elevation, slope, aspect) | 30 m |
| Local microclimate | Heat load index, northness, eastness, elevation squared in ESI v7 | 30 m |
| Local stand structure | BGI from FIA remeasurement pairs (current decade) and Asym from Chapman-Richards fit at the same FIA plot set | 30 m |
| Local canopy condition | Hansen tree cover, GEDI relative height in the v5 stack | 30 m |
| Regional climate | 33 ClimateNA covariates distilled through ESI v6 (1 km) and propagated into ESI v7 (30 m) | 1 km calibration, 30 m surface |
| Regional carbon flux | MODIS MOD17A3HGF NPP mean and CV at 500 m | 500 m |
| Regional regime | East-West and per-state correlations make the regime structure explicit and falsifiable in the analyses | descriptive |

The unified composite is the equal-weight z-score average of the three internal components (ESI v7, BGI, Asym) rescaled to 0-100. NPP and FIA SICOND serve as external comparators. Three additional traditional SI measurements (raw SICOND, NRCS SSURGO coforprod, GADA-refit on the unified compilation) confirm that the composite tracks FIA SITECLCD ranking that single measures miss.

## Operational recommendations by application

| Application | Recommended measure | Why |
|---|---|---|
| FVS calibration, dominant-tree height work | ESI v7 (unified-target SI at 30 m) | Clean height-growth-potential signal; not the SICOND value, which has been mislabeled for decades. |
| Carbon stock change projection, current-decade productivity | BGI (30 m) | This is what FIA SITECLCD has been tracking. |
| Long-run carbon accounting, mature stand density management | Asym (30 m) | Asymptotic biomass from Chapman-Richards; the steady-state capacity. |
| Land surface modeling, atmospheric flux | NPP (500 m MOD17) | Annual carbon assimilation, ships with a CV layer for interannual stability. |
| Cross-study site quality ranking, general use | CSPI v2 3-component composite (0 to 100) | Tracks FIA SITECLCD linearly; matches field-observed productivity expectations. |
| Quick reference for FIA-trained models | FIA SICOND raw values | Existing workflows; understand that the relationship to height growth is regional and base-age sensitive. |

Decision tree in Figure 11 of the manuscript codifies these defaults with their key caveats.

## The case for CSPI as the unified product (not any single component)

A unified product needs to satisfy three properties:

**Robustness across context.** The composite tracks the FIA seven-class SITECLCD classification monotonically (40.0 to 30.2 from class 1 to 7). No single component does. Site index actually peaks at class 6 (32.1 m). The composite is the only operational metric that gives the same answer that practitioners on the ground already give when they assess site quality.

**Decomposability.** The composite is the equal-weight z-score average of three transparent components. Users who want only one dimension can take the corresponding component layer (shipped separately at the same Zenodo deposit). Users who want a custom weighting can rebuild the composite from the components using the documented z-score parameters.

**Documentable provenance.** The full pipeline ships as open source at github.com/holoros/fvs-conus. The components, the composite, the model versions, the QC chain, and the seven head-to-head comparisons against alternative measurements (raw SICOND, base-50 SICOND, SSURGO, GADA-refit, MOD17 NPP) are all in the deposit. A federal program officer or a peer reviewer can reconstruct any result from first principles.

## Near-term roadmap

| Release | What lands | When |
|---|---|---|
| v2.0.1 | 30 m quantile-RF uncertainty raster for ESI v7 | After v7_qrf array completes (~24 hours from this writing) |
| v2.1.0 | 30 m wall-to-wall composite + component surfaces, MOD17 500 m NPP replaces 1 km Miami climatology | After Zenodo storage quota expansion approval |
| v3.0.0 (proposed) | Per-ecoregion weighted composite, with weights derived from the regional regime analysis (§3.4 and §3.13 of the manuscript) | 12 to 18 months out, dependent on funded follow-on |

The v3.0.0 step is the biggest near-term scientific opportunity. The data in v0.10d show that the East-vs-West regime sign flip and the per-state correlation range are large enough that a one-size-fits-all national composite leaves real signal on the table. An ecoregion-aware composite that uses different component weights in the Pacific Northwest, the southern coastal plain, the interior West, and the Lake States would improve the calibration without losing decomposability or transparency.

## Concrete next steps

| Track | Owner | Timing |
|---|---|---|
| FEM submission of the v0.10d manuscript | Aaron + Claude | Within 2 weeks, after coauthor review (Anthony D'Amato, Jereme Frank for CFRU input) |
| Press release through UMaine Communications | Aaron + UMaine Comms office | Coordinated with FEM in-press notification |
| Collaborator integrations (FVS DG-Kuehne, CFRU growth-and-yield, Carbon Field Pilot validation) | CRSF + collaborator PIs | Q3 2026 onward, using the v2.0.0 deposit |
| v2.1.0 30 m surface release | Aaron + Cardinal pipeline | After Zenodo quota approval, ~1 to 2 months |
| Ecoregion-aware v3 composite proposal | Aaron, CRSF | Submit to USDA NIFA McIntire-Stennis or NSF EPSCoR Track 2 in next cycle |
| FIA-FS engagement on SITECLCD implications | Aaron, with introductions through CRSF advisory board | Q4 2026 (sensitive timing given the SITECLCD finding) |

## What the headline of the unified measure should be

Not "we built a better site index." Site index is what it is, and our work shows it cannot single-handedly carry the productivity construct.

Not "site index is wrong." It is one operational measure among several, well-suited for the narrow envelope of single-species pure stands with calibrated curves and even-aged structure.

The right headline is: **forest site productivity is multi-dimensional, the operational classification practitioners have been using has been tracking biomass growth all along, and we have given the field a unified composite that recovers the ranking field staff already see, plus the components that compose it for any application that wants only one dimension.** That is the unified measure that captures both local and regional drivers. CSPI v2 ships it now; v2.1.0 expands the 30 m surface coverage; v3.0.0 makes it ecoregion-aware.

---

*Sources: full analytical chain at github.com/holoros/fvs-conus; data and components at Zenodo concept 10.5281/zenodo.20515034 (version 2.0.0 at 10.5281/zenodo.20663652); manuscript draft at v5/CSPI_v0_10_manuscript_draft.md.*
