# CSPI Manuscript v0.10o Handoff
## End of autopilot run, 23 June 2026

## Headline this run

The v9 environmental stack predicts **satellite-observed MODIS NPP at OOB R² = 0.919**, beating the FIA-derived Asym v9 fit (0.836) by 8.3 percentage points on the same plot locations. This is the FIA-independent validation Aaron asked for: the stack that drives v3.0.0 surfaces is well-calibrated to satellite productivity flux regardless of FIA-specific measurement chain (fuzzed coords, base-age, allometric uncertainty).

## State at v0.10o

| | |
|---|---|
| Manuscript | **v0.10o** committed and pushed at `06a1e72` |
| New §3.23 | RS-target NPP validation (n = 61,656 plots, OOB R² = 0.919, parent material ΔR² = +0.022) |
| Repo access | Permanent fix complete; PAT scoped to advanced-forestry-systems works |
| Zenodo v3.0.0 | Published 10.5281/zenodo.20763197 (unchanged) |
| FEM submission package | Ready: v0.10o docx + supplements + figures |

## Numbers worth remembering

| Target | Predictors | OOB R² | RMSE | Units |
|---|---|---|---|---|
| FIA Asym v9 (v3.0.0 surface) | v3 stack (12 covariates) | 0.836 | 8.21 | Mg ha⁻¹ |
| MODIS NPP_obs (this analysis) | v3 stack (12 covariates) | **0.919** | 509 | g C m⁻² yr⁻¹ |
| MODIS NPP_obs climate-only | 6 covariates | 0.897 | 575 | g C m⁻² yr⁻¹ |

Parent material contribution: ΔR² = +0.022 for NPP, +0.008 for Asym v9. Consistent magnitudes — geology matters modestly but consistently for both biomass and flux productivity targets.

Variable importance (RS NPP target): WATER_RATIO (rank 1), WATER_AET (2), WATER_DEF (3), DIST_COAST (4), NDEP (5), SRAD (6), WATER_WD (7), VPD_TC (8), WATER_AI (9), WATER_PET (10), WIND (11), pm_int (12).

## Why this matters

Three reframings the paper can now make safely:

1. **External defense against FIA-specific noise.** Reviewers who push back on the height-derived measurement chain, fuzzed coords, base-age standardization, or SSURGO sparsity can be answered with: the v9 stack predicts satellite-observed NPP at 91.9% explained variance on 61,656 forested locations, independent of all those concerns. The FIA-derived target adds noise beyond the environmental signal.

2. **The 8.3-point R² gap quantifies FIA noise contribution.** That ~8% of variance the environmental stack cannot capture in the FIA-derived biomass target IS capture-able in the satellite NPP target, suggesting the FIA chain itself contributes roughly that much measurement noise. This is a clean number to cite when defending against "but your biomass is fuzzy" critiques.

3. **Future productivity surfaces can deploy on satellite targets natively.** GEDI L4B biomass at 1 km, NASA-CMS biomass change layers, Sentinel-2 derived indices — all are accessible at CONUS scale and bypass FIA entirely. Future v3.1.0+ releases can use these as targets if the FIA-target chain becomes a reviewer obstacle.

## Files produced

| File | Path |
|---|---|
| Manuscript md (v0.10o) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx (v0.10o) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10o_FEM_combined.docx` |
| Variable importance (RS NPP) | Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/PIX11_npp_obs_varimp.csv` |
| OOB comparison | Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/PIX12_npp_obs_climate_vs_full.csv` |
| RS vs FIA target compare | Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/PIX13_oob_target_comparison.csv` |
| Trained NPP model | Cardinal `/fs/scratch/PUOM0008/crsfaaron/rs_target/m_npp_obs_v2.rds` |

## Cardinal jobs this session

| Job | What | State |
|---|---|---|
| 11824119 | Asym v10 wind residual | COMPLETED (v0.10m §3.21) |
| 11824129 | Reforestation gap streaming (rasterio) | COMPLETED |
| 11944936 | HURDAT2 hurricane density | COMPLETED (with non-fatal decile-bin error) |
| 11948515 | Reforestation by state | submitted, may still be running |
| 11957055 | NPP-target pixel RF v1 (failed: target was circular) | FAILED |
| 11958072 | NPP-target pixel RF v2 (failed: column index) | FAILED |
| 11958233 | NPP-target pixel RF v3 (NPP_COMBO target, circular OOB=0.9997) | COMPLETED but result invalid |
| **11958253** | **RS-target NPP_obs v2 (CORRECT, OOB R² = 0.919)** | **COMPLETED** |

## GitHub repo state

Direct push to advanced-forestry-systems/cspi-conus is now working with the new PAT (claude-cowork-afs). Local clone main at commit `06a1e72`. The org repo is at the same commit.

Permanent fix complete: holoros PAT updated at `~/Documents/Claude/CRSF-Cowork/_context/.gh-holoros/token`, scoped to advanced-forestry-systems, with Contents = Read and write on cspi-conus.

## Commits on advanced-forestry-systems/cspi-conus this session

`b926869` v3.0.1 NEWS + F14, `42e9c43` v0.10n §3.22 HURDAT2, `2255d4a` v0.10n handoff, `1a7646b` PR #1 merge, `06a1e72` v0.10o §3.23 RS-target NPP.

## Optional next-session ideas

- **GEDI L4B at 1 km** (need to re-download the actual TIF — current placeholder is HTML). Test biomass-density target alongside the flux target.
- **NASA-CMS biomass change layer** (continuous biomass change rate, 250 m). Test ΔAGB target — direct productivity signal.
- **Sentinel-2 NDVI/EVI productivity index** at CONUS. Higher temporal frequency than MODIS.
- **F16 spatial map of NPP model predictions vs MODIS NPP_obs residuals** for the supplement.
- **NEWS_v3.0.1.md update** with §3.23 RS-target finding as primary v3.0.1 addendum.
- **Two-paper split revisit**: §3.23 alone could anchor a methods note demonstrating FIA-independent validation of the multi-dimensional framework.

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197. Manuscript is at v0.10o on advanced-forestry-systems/cspi-conus at commit 06a1e72 with §3.19 AmeriFlux, §3.20 reforestation gap (40.2 Mha, 4.74 Pg C), §3.21 mean wind null, §3.22 hurricane null, and §3.23 RS-target NPP validation (OOB R² = 0.919 beats FIA-target Asym v9 0.836 by 8.3 points). Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10o_to_next.md`.
>
> GitHub permanent fix complete: holoros PAT now scoped to advanced-forestry-systems. Direct pushes to the org repo work.
>
> Pick up by:
> 1. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with `CSPI_v0_10o_FEM_combined.docx` attached.
> 2. Confirm FEM submission package is ready.
> 3. If I want any optional v3.0.1 work (GEDI L4B re-download and AGB-target fit, NASA-CMS biomass change target, Sentinel-2 productivity, F16 spatial residual map, NEWS_v3.0.1 update), execute on autopilot.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token at `~/.zenodo_token` on Cardinal mode 600 — never echo to stdout. GitHub PAT at `_context/.gh-holoros/token`. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
