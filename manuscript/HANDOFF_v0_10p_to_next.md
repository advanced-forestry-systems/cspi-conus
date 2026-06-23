# CSPI Manuscript v0.10p Handoff
## End of multi-track autopilot run, 23 June 2026

## Headline this run

§3.23 RS-target validation extended with per-substrate residual stratification, F16 NPP scatter and residual map, F17 variable importance side-by-side. NEWS_v3.0.1 updated with §3.23 as primary v3.0.1 finding. Per-PM residuals (Volcanic over-predicted by 32 g C m⁻² yr⁻¹, Marine under-predicted by 15) reproduce §3.14 height-vs-flux orthogonality at the satellite target — strong cross-target consistency.

## State at v0.10p

| | |
|---|---|
| Manuscript | **v0.10p** committed and pushed at `3d26edf` |
| §3.23 expansion | Per-PM residual paragraph + Figure F16/F17 references |
| Figure F16 (supplement) | Two-panel: predicted vs observed NPP scatter + residual spatial map (n = 57,396) |
| Figure F17 (supplement) | Variable importance side-by-side (RS NPP vs FIA Asym v9) |
| NEWS_v3.0.1 | Updated with §3.22 and §3.23 sections |
| Zenodo v3.0.0 | Published 10.5281/zenodo.20763197 (unchanged) |

## Numbers worth remembering

| | |
|---|---|
| RS NPP target OOB R² (v9 stack) | 0.919 |
| RS NPP target RMSE | 509 g C m⁻² yr⁻¹ |
| Climate-only baseline OOB R² | 0.897 |
| FIA Asym v9 target OOB R² | 0.836 |
| RS minus FIA target R² gap | +0.083 |
| Per-PM residual range | -33 (Volcanic) to +18 (Glacial) g C m⁻² yr⁻¹ |

Per-PM residuals (mean observed minus mean predicted, g C m⁻² yr⁻¹):
- Glacial +18, Marine +15, Colluvium +6, Eolian +4, Residuum +1, Other -12, Organic -17, Lacustrine -26, Alluvial -29, Volcanic -33

Volcanic is over-predicted by the largest margin (matches §3.14: high height-growth potential / lower realized flux).
Marine and Glacial are under-predicted slightly (high coastal moisture / glacial wetness drive NPP beyond what 4 km predictors capture).

## What this autopilot run failed to do

1. **GEDI L4B download.** First URL pattern returned 44-byte redirects. Updated URL pattern queued for next session (the GEDI04_B_MW019MW138_*.tif filenames may be the right pattern under daacdata/cms/GEDI_L4B_Gridded_Biomass_V2_1/data/). Without working GEDI L4B, the AGB-density target arm of v3.0.1 stays pending.

2. **L3 ecoregion residual breakdown.** Shapefile not present at the hardcoded paths I tried. Could pull from EPA or build at next session.

3. **NASA-CMS biomass change target.** Listed in v3.0.1 deferred items; not attempted this run.

## Cardinal jobs this session

| Job | What | State |
|---|---|---|
| 11958718 | GEDI L4B download (URL wrong) | COMPLETED (no useful TIFs) |
| 11958719 | Multi-track v0.10p (cancelled, recursive list.files stuck) | CANCELLED |
| 11959169 | Multi-track v0.10p v2 (hard-coded paths) | COMPLETED in 10 sec |

## Files produced

| File | Path |
|---|---|
| Manuscript md (v0.10p) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx (v0.10p) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10p_FEM_combined.docx` |
| F16 (PNG, PDF, py) | repo `figures_v10/supplement/F16_npp_pred_vs_obs.*` |
| F17 (PNG, PDF) | repo `figures_v10/supplement/F17_importance_npp_vs_asym.*` |
| NEWS_v3.0.1 | repo root |
| PIX20 per-PM residuals | repo `analyses/PIX20_npp_resid_perPM.csv` |

## Repo

advanced-forestry-systems/cspi-conus main is at `3d26edf` after this push. The PAT scoped to the org continues to work directly.

## Optional next-session ideas

- **Get GEDI L4B working** with correct URL pattern (NASA Earthdata path discovery) or via the ORNL DAAC OPeNDAP service. Then fit AGB-density target.
- **L3 ecoregion residual map** for v0.10q supplement.
- **F18 hexbin of NPP residuals across CONUS** at higher resolution than F16's plot dots.
- **NASA-CMS biomass change target** (annual gridded AGB Tg/ha/yr) as direct productivity flux signal.
- **Sentinel-2 NDVI/EVI** target. Higher temporal resolution than MODIS; could test 30 m predictions.
- **Discussion §4 wording update** to integrate §3.23 finding alongside the FIA-target framing.
- **Submit to FEM** when coauthor review completes.

## PROMPT FOR NEXT SESSION

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197. Manuscript is at v0.10p on advanced-forestry-systems/cspi-conus at commit 3d26edf. Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10p_to_next.md`.
>
> §3.23 RS-target validation now includes per-PM residual stratification reproducing §3.14 (Volcanic over-predicted by 33, Marine under-predicted by 15), F16 NPP scatter and residual map, and F17 variable importance side-by-side. NEWS_v3.0.1.md has the §3.22 wind + §3.23 RS-target sections.
>
> Pick up by:
> 1. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with `CSPI_v0_10p_FEM_combined.docx` attached.
> 2. If I want any optional v0.10q work (GEDI L4B AGB-density target, L3 ecoregion residuals, NASA-CMS biomass change, Sentinel-2 indices, Discussion §4 integration), execute on autopilot.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token at `~/.zenodo_token` on Cardinal mode 600 — never echo to stdout. GitHub PAT at `_context/.gh-holoros/token` (now scoped to advanced-forestry-systems). Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
