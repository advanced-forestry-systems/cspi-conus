# CSPI Manuscript v0.10q Handoff
## End of extended autopilot run, 23 June 2026

## Headline this run

§3.23 RS-target validation now has full ecoregion stratification: the v3 environmental stack is essentially unbiased in Eastern Temperate Forests (mean residual +1 g C m⁻² yr⁻¹ across n = 42,580 plots) and Northern Forests (+29, n = 1,401), under-predicts in moist coastal ecoregions (Marine West Coast Forest +372), and over-predicts in arid ecoregions (North American Deserts -247, Southern Semi-Arid Highlands -307). Discussion §4 woven to integrate §3.23 finding alongside §4.7.1 FIA-on-FIA framing and §4.8 limitations. F18 hexbin spatial residual map added.

## State at v0.10q

| | |
|---|---|
| Manuscript | **v0.10q** committed and pushed at `8fb4c61` |
| §3.23 expansion | + per L1/L3 ecoregion residual paragraph + Tables S18/S19 reference |
| §4.7.1 update | RS-target finding integrated as partial answer to FIA-on-FIA concern |
| §4.8 update | RS-target gap quantifying FIA-chain noise budget |
| Figure F18 (supplement) | Three-panel hexbin: mean residual, residual SD, plot count per hex |
| EPA L3 ecoregions | Downloaded and joined; PIX30 (per-L3) + PIX31 (per-L1) CSVs in repo analyses/ |

## Key numbers

**Per L1 ecoregion residuals (v9-stack NPP, mean obs minus pred, g C m⁻² yr⁻¹):**
| L1 ecoregion | n | residual |
|---|---|---|
| Marine West Coast Forest | 53 | **+372** |
| Northern Forests | 1,401 | +29 |
| NW Forested Mountains | 10,726 | +10 |
| Eastern Temperate Forests | 42,580 | **+1** |
| Temperate Sierras | 1,109 | -7 |
| Great Plains | 989 | -61 |
| Mediterranean California | 48 | -81 |
| **North American Deserts** | 447 | **-247** |
| Southern Semi-Arid Highlands | 23 | -307 |
| Tropical Wet Forests | 20 | -435 |

The v3 stack is **essentially unbiased in the dominant CONUS forested ecoregions** (Eastern Temperate Forests near zero, Northern Forests +29, NW Forested Mountains +10). It systematically over-predicts in arid ecoregions and under-predicts in coastal moisture-dominated ecoregions, in directions consistent with the §3.14 height-vs-flux pattern.

**Per L3 highlights:**
- Top over-predicted: Mississippi Alluvial Plain (-471), Wyoming Basin (-393), Central Basin and Range (-338), Northern Basin and Range (-208), Colorado Plateaus (-132)
- Top under-predicted: Erie Drift Plain (+153), N Central Hardwood Forests (+78), Erie Drift Plain (+76), Coastal Plains/Hills (+70)

## What this autopilot run failed to do

1. **GEDI L4B fetch.** CMR Search API returned 0 granules for the short_name + version query I used. Need to refine the CMR query (try without version, or use collection concept_id directly). GEDI L4B v2.1 is at ORNL DAAC but the search short_name may not be `GEDI_L4B_Gridded_Biomass`.

2. **NASA-CMS biomass change.** Not attempted this run. Listed as next-session item.

## Cardinal jobs this session

| Job | What | State |
|---|---|---|
| 11959947 | EPA L3 download + slow terra::extract | KILLED at 10 min |
| 11960527 | sf::st_join attempt 1 (s2 polygon validity error) | FAILED |
| 11960714 | sf::st_join attempt 2 with sf_use_s2(FALSE) + st_make_valid | COMPLETED in 7 sec |

## Files produced

| File | Path |
|---|---|
| Manuscript md (v0.10q) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx (v0.10q) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10q_FEM_combined.docx` |
| F18 hexbin spatial residual (PNG, PDF, py) | repo `figures_v10/supplement/F18_npp_residual_hexbin.*` |
| PIX30 per-L3 NPP residuals | repo `analyses/PIX30_npp_resid_perL3.csv` |
| PIX31 per-L1 NPP residuals | repo `analyses/PIX31_npp_resid_perL1.csv` |
| EPA L3 shapefile (Cardinal) | `/fs/scratch/PUOM0008/crsfaaron/v10q_aux/us_eco_l3.shp` |

## Optional next-session ideas

- **GEDI L4B via correct CMR query.** Try collection short_name `GEDI04_B_Gridded` or use CMR concept ID `C2244601952-ORNL_CLOUD`. Once landed fit AGB-density target as second RS-target validation.
- **NASA-CMS biomass change** (annual gridded). Direct productivity-flux signal.
- **F19 ecoregion choropleth** showing residual mean per L3 polygon.
- **F20 spatial residual map by climate zone** (Köppen) for comparison with ecoregion stratification.
- **Sentinel-2 NDVI/EVI** target. 10 m resolution, finer-grained validation.
- **§4 Conclusions update** to mention the L1/L3 ecoregion finding alongside §3.23.

## Commits on advanced-forestry-systems/cspi-conus this session

`8fb4c61` v0.10q with §3.23 L3/L1 + Discussion §4 weave + F18 hexbin.

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197. Manuscript is at v0.10q on advanced-forestry-systems/cspi-conus at commit 8fb4c61. Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10q_to_next.md`.
>
> v0.10q adds: (a) per L1 and L3 ecoregion residual stratification to §3.23 showing the v3 stack is essentially unbiased in dominant forested ecoregions (Eastern Temperate Forests +1, Northern Forests +29, NW Forested Mountains +10 g C m⁻² yr⁻¹) and systematically over/under-predicts in arid/coastal extremes; (b) Discussion §4.7.1 weave integrating §3.23 as a partial answer to FIA-on-FIA concerns; (c) §4.8 limitation update quantifying the FIA-chain noise budget via the 8.3-point R² gap; (d) F18 three-panel hexbin spatial residual map.
>
> Pick up by:
> 1. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with `CSPI_v0_10q_FEM_combined.docx` attached.
> 2. If I want any optional v0.10r work (GEDI L4B via correct CMR query, NASA-CMS biomass change target, F19 ecoregion choropleth, Sentinel-2 NDVI target), execute on autopilot.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token at `~/.zenodo_token` on Cardinal mode 600 — never echo to stdout. GitHub PAT at `_context/.gh-holoros/token` (now scoped to advanced-forestry-systems). Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
