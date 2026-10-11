# CSPI Manuscript v0.10m Handoff
## End of session 20 June 2026 → next session

## State at v0.10m

| | |
|---|---|
| Manuscript | **v0.10m** committed to holoros/cspi-conus at `4f96be0` |
| New sections this session | §3.19 AmeriFlux (added v0.10l), §3.20 reforestation gap quantified, §3.21 wind exposure null result |
| Zenodo v3.0.0 | Published 10.5281/zenodo.20763197 (5 files, 20 GB) |
| FEM submission package | Ready: v0.10m docx + supplements + figures |
| Open items | Coauthor review email send (manual), FEM submission (manual) |

## Section adds this session

### §3.19 AmeriFlux external validation (v0.10l)
n = 28 US forest tower sites with published NPP; pooled r(CSPI v7, NPP) = +0.17. Per-site pattern is the actual story: Pacific Northwest sites track NPP correctly (Wind River CSPI 47, NPP 715–825), Western montane sites show the §3.14 volcanic-substrate orthogonality reproduced (Niwot Ridge CSPI 35.8, NPP 350; Valles Caldera Mixed 40.3, 375). External-network confirmation of structural pattern.

### §3.20 reforestation potential application (v0.10l + v0.10m gap backfill)
v3.0.0 ships both forest-masked and unmasked Asym v9 surfaces. The unmasked surface identifies 548.7 million 30 m pixels (**40.2 Mha**, roughly 99 million acres) currently non-forest with Asym v9 > 200 Mg/ha. Mean Asym v9 across candidates = 251.0 Mg/ha. Aggregate model-estimated potential biomass = 10,088 Tg dry matter = **4,741 Tg C = 4.74 Pg C** at f_biomass = 0.47. Roughly 3x annual US forest-sector net sequestration. We frame this explicitly as model-estimated environmental ceiling, not realizable accumulation. Downstream studies must overlay land-cover transition feasibility, ownership, fire regime.

### §3.21 wind exposure as non-structural driver (v0.10m, NEW)
TerraClimate annual mean wind speed at 4 km, extracted at 31,463 v9-model plots:
- Raw bivariate: Asym v9 increases monotonically with wind decile (236.7 → 261.3 Mg/ha across fourfold gradient)
- After conditioning on v9 stack: residuals collapse (range −0.88 to +0.48 Mg/ha, no monotonic pattern, well within v9 RMSE of 8.21)
- Per-PM correlations |r| < 0.25 mostly, strongest signals on Eolian (+0.229) and Colluvium (+0.226)
- Honest reading: wind operates through correlated climate and terrain covariates already in the v9 stack. Mean wind is not an independent structural axis for Asym at continental scale.
- This is a clean negative result that strengthens the parent-material framing in §3.14 and §3.18 by ruling out wind as a confound.

## Cardinal jobs landed this session

| Job | What | State |
|---|---|---|
| 11787913 | Reforestation candidate raster + AmeriFlux extraction | OUT_OF_MEMORY at gap stats (TIF wrote OK) |
| 11824119 | Asym v10 wind refit (residual mode) | COMPLETED |
| 11824129 | Reforestation gap streaming (rasterio) | COMPLETED, 3.2 min |

## Files produced

| File | Path |
|---|---|
| Manuscript md (v0.10m) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx (v0.10m) | `~/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10m_FEM_combined.docx` |
| Repo manuscript copy | `~/Documents/Claude/CRSF-Cowork/repos/cspi-conus/manuscript/CSPI_v0_10m_*` |
| Wind PM correlations | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/PM30_asym_resid_vs_wind_perPM.csv` (also in repo `analyses/`) |
| Wind decile binning | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/PM31_asym_resid_by_wind_decile.csv` |
| Reforestation gap summary | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION_GAP_summary.csv` |
| Reforestation histogram | Cardinal `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION_GAP_hist.csv` |

## Remaining manual actions (cannot be done autonomously)

1. **Send coauthor review email** to Anthony D'Amato and Jereme Frank with `CSPI_v0_10m_FEM_combined.docx` attached. Drafted email exists from earlier session.
2. **Submit to Forest Ecology and Management** once Anthony and Jereme have reviewed.

## Optional next-session ideas

These are nice-to-haves, not blockers:

- **HURDAT2 hurricane track density grid** at FIA plots (NOAA NHC, Atlantic and Pacific basins). Episodic disturbance rather than mean wind. Would test whether hurricane swath density adds residual signal where mean wind does not. Construction: buffer each hurricane track polyline by storm radius, count overlaps per 4 km grid cell, normalize by years.
- **SVRGIS tornado paths + EF rating** density grid (NOAA SPC). Same construction approach as above.
- **NREL Wind Toolkit** 2 km wind at 80 m hub height for higher-resolution test. Available via NREL HSDS API requiring auth setup.
- **F14 wind decile plot** for the supplement (already have the data table).
- **F15 reforestation map**: choropleth of REFORESTATION_CANDIDATE area by L3 ecoregion or by state.
- **NEWS_v3.0.1.md** noting the wind null finding and gap quantification.

## Commits on holoros/cspi-conus this session

`1309547` (v0.10l AmeriFlux §3.19), `11517b5` (v0.10l reforestation §3.20 placeholder), `d5ac2e3` (v0.10l handoff), `4f96be0` (v0.10m §3.20 gap backfill + §3.21 wind null + analyses CSVs).

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197 (5 files, 20 GB). Manuscript is at v0.10m at holoros/cspi-conus commit 4f96be0 with §3.19 AmeriFlux validation (r = 0.17 honest reading), §3.20 reforestation gap quantified (40.2 Mha non-forest with Asym v9 > 200 Mg/ha, aggregate 4.74 Pg C potential storage), and §3.21 wind exposure null finding (TerraClimate annual wind adds no residual signal beyond the v9 stack). Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10m_to_next.md`. Please pick up by:
>
> 1. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with `CSPI_v0_10m_FEM_combined.docx` attached.
> 2. Confirm the FEM submission package is ready (manuscript, supplements, figures, cover letter).
> 3. If I want any of the optional next-session ideas in the handoff doc (HURDAT2 hurricane density, SVRGIS tornado density, NREL Wind Toolkit at 80 m hub, F14 wind decile figure, F15 reforestation choropleth, NEWS v3.0.1), execute on autopilot.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token in the Cardinal token file (mode 600) — never echo to stdout. GitHub PAT in the private token store. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
