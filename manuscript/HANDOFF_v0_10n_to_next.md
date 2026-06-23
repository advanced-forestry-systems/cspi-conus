# CSPI Manuscript v0.10n Handoff
## End of autopilot run, 23 June 2026

## Headline this run

The wind exposure story is closed. Two independent tests (chronic mean wind speed in §3.21, episodic hurricane track density in §3.22) both return r ≈ 0 after conditioning on the v9 stack. The Asym v9 surface released in v3.0.0 does not need a wind correction.

The reforestation potential is quantified: 40.2 Mha non-forest with Asym v9 above 200 Mg/ha; aggregate model-estimated environmental ceiling = 4.74 Pg C.

## ACTION REQUIRED FROM AARON

The cspi-conus repo was transferred from `holoros/cspi-conus` to `advanced-forestry-systems/cspi-conus` during this autopilot run. The `holoros` PAT no longer has push permission to the new org, so this session's commits (v0.10m gap, v0.10n wind closure, F14 figure, NEWS_v3.0.1) live locally only at `~/Documents/Claude/CRSF-Cowork/repos/cspi-conus/` and have not been pushed.

To restore push from this session:
1. Either go to `https://github.com/advanced-forestry-systems` → People → invite `holoros` as a member with write access, **or** create a new PAT under the advanced-forestry-systems org and save it to `~/Documents/Claude/CRSF-Cowork/_context/.gh-holoros/token` (replacing the holoros PAT).
2. Then `cd ~/Documents/Claude/CRSF-Cowork/repos/cspi-conus && git push` will succeed and the v0.10m, v0.10n, F14, and NEWS commits will land remote.

I cannot do this for you because it requires modifying repository access controls, which my safety rules reserve for the user.

## State at v0.10n

| | |
|---|---|
| Manuscript | **v0.10n** locally committed (commits 4f96be0, b926869, plus today's HEAD) |
| New sections added across v0.10l through v0.10n | §3.19 AmeriFlux, §3.20 reforestation gap quantified, §3.21 mean wind null, §3.22 hurricane null |
| Zenodo v3.0.0 | Published 10.5281/zenodo.20763197 (unchanged) |
| FEM submission package | Ready: v0.10n docx + supplements + figures |
| Open items | Coauthor review email send (manual), FEM submission (manual), repo-access fix (manual, see above) |

## Section adds

### §3.19 AmeriFlux external validation (v0.10l)
n = 28 US forest tower sites with published NPP; pooled r(CSPI v7, NPP) = +0.17. Western montane sites compress the correlation (Niwot Ridge, Valles Caldera, Metolius Young) by reproducing the §3.14 volcanic-substrate orthogonality at an external (non-FIA) network.

### §3.20 reforestation potential quantification (v0.10l + v0.10m backfill)
v3.0.0 unmasked Asym v9 surface identifies 548.7 million 30 m pixels (40.2 Mha, ~99 million acres) currently non-forest with Asym v9 > 200 Mg/ha. Mean Asym = 251.0 Mg/ha. Aggregate environmental ceiling 4,741 Tg C = **4.74 Pg C** at f_biomass = 0.47. Framed as model-estimated ceiling, not realizable accumulation.

### §3.21 wind exposure null (v0.10m)
TerraClimate annual mean wind at 31,463 v9 plots. Raw bivariate: Asym increases with wind (236.7 → 261.3 Mg/ha across deciles). After v9 conditioning: residuals within ±0.88 Mg/ha. Per-PM correlations |r| < 0.25 mostly. Wind operates via correlated climate and terrain covariates already in v9 stack.

### §3.22 hurricane density null (v0.10n, NEW this run)
NOAA HURDAT2 1851-2024 tropical-storm-or-stronger track-point density at 0.25 deg across CONUS, extracted at 31,463 v9 plots. 17,804 storm-track points in 7,398 cells (max 41 in Florida/Carolinas). 17.8 percent of plots fall in at least one storm cell.

- Pearson r(asym v9 residual, hurricane density) = **−0.028**
- Spearman ρ = −0.032
- Per-PM: Marine = 1.13 mean storm passes, r = −0.019. Eolian r = −0.037. Alluvial (most ecologically coherent) r = −0.070. Volcanic plots have zero hurricane exposure (natural control). All per-PM |r| < 0.07.

Closes the wind story: neither chronic mean wind nor episodic hurricane exposure is a structural axis missing from the v9 stack. The v3.0.0 Asym surface ships without a wind correction.

## Cardinal jobs this session

| Job | What | State |
|---|---|---|
| 11824119 | Asym v10 wind residual (TerraClimate) | COMPLETED |
| 11824129 | Reforestation gap streaming (rasterio) | COMPLETED |
| 11944906 | First autopilot v10n batch | FAILED (raster assign NA bug) |
| 11944936 | HURDAT2 rerun after fix | FAILED on quantile-tie at decile bin; main result r=−0.028 captured before crash |
| 11948515 | Reforestation by state standalone | RUNNING at handoff time |

## Files produced

| File | Path |
|---|---|
| Manuscript md (v0.10n) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx (v0.10n) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10n_FEM_combined.docx` |
| NEWS v3.0.1 (planning) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/NEWS_v3.0.1.md` |
| F14 wind decile fig (PNG, PDF, py) | `~/Documents/Claude/CRSF-Cowork/repos/cspi-conus/figures_v10/supplement/F14_wind_decile.*` |
| HURDAT2 per-PM | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/PM33_asym_resid_vs_hurdat2_perPM.csv` |
| HURDAT2 raster | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/hurdat2_density_0.25deg_CONUS.tif` |
| Reforestation by state | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION_BY_STATE.csv` (in flight, job 11948515) |

## Remaining manual actions

1. **Fix repo access** (see ACTION REQUIRED above) so this session's commits push.
2. **Send coauthor review email** to Anthony D'Amato and Jereme Frank with `CSPI_v0_10n_FEM_combined.docx` attached.
3. **Submit to Forest Ecology and Management** once coauthor review lands.

## Optional next-session ideas

- **F15 reforestation by state choropleth** once job 11948515 lands `REFORESTATION_BY_STATE.csv`.
- **SVRGIS tornado paths** (NOAA SPC). Same pattern as HURDAT2 but for tornado tracks. Likely null given the §3.21 and §3.22 results, but worth confirming.
- **NREL Wind Toolkit 2 km hub-height wind** test. Requires NREL HSDS API auth. Higher resolution than TerraClimate at 4 km; would test whether the wind-null result holds at finer scale.
- **F16 hurricane density map** for the supplement showing the HURDAT2 0.25 deg raster overlaid with v9 residuals at colored points.
- **NSVB biomass swap** to align Asym target with Westfall et al. 2024 (deferred to v3.1.0).
- **ForestGEO buffered extraction** to resolve single-pixel NA at 26 of 30 sites.

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197 (5 files, 20 GB). Manuscript is at v0.10n locally with §3.19 AmeriFlux (r=0.17), §3.20 reforestation quantified (40.2 Mha, 4.74 Pg C ceiling), §3.21 mean wind null, §3.22 hurricane null. The wind story is closed. Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10n_to_next.md`.
>
> CRITICAL: The cspi-conus repo was transferred to advanced-forestry-systems org during the prior session. The holoros PAT lacks push access. v0.10m, v0.10n, F14, and NEWS commits live locally at `~/Documents/Claude/CRSF-Cowork/repos/cspi-conus/` but have not pushed. Aaron must either grant holoros write access at advanced-forestry-systems org, or replace `~/Documents/Claude/CRSF-Cowork/_context/.gh-holoros/token` with a PAT scoped to advanced-forestry-systems. Then `git push` from the repo will succeed.
>
> Pick up by:
> 1. Confirm repo-access fix completed; push the local commits.
> 2. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with `CSPI_v0_10n_FEM_combined.docx` attached.
> 3. Pull REFORESTATION_BY_STATE.csv when Cardinal job 11948515 lands; build F15 state choropleth.
> 4. If I want any of the optional next-session ideas in the handoff doc (SVRGIS tornado, NREL Wind Toolkit, F16 hurricane map, NSVB swap, ForestGEO buffered), execute on autopilot.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token at `~/.zenodo_token` on Cardinal mode 600 — never echo to stdout. GitHub PAT at `_context/.gh-holoros/token`. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only (this is why the repo-transfer fix is in your court, not mine).
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
