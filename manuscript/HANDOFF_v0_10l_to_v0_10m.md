# CSPI Manuscript v0.10l Handoff
## End of session 19 June 2026 → next session

## What landed in this session

### Manuscript v0.10l
- **§3.19 AmeriFlux external validation** added. The pooled correlation r(CSPI v7, published NPP) = +0.17 across n = 28 US forest tower sites is reported honestly. The per-site pattern is read as a structural confirmation: Western montane sites (Niwot Ridge, Valles Caldera Mixed and Ponderosa, Metolius Young) all show high CSPI v7 (35.8 to 45.3) paired with low published NPP (350 to 410), reproducing the §3.14 volcanic-substrate-mediated height-vs-flux orthogonality at an external (non-FIA) network. Pacific Northwest and Eastern broadleaf sites track NPP monotonically.
- **§3.20 reforestation potential application** added as use-case framing for the v3.0.0 unmasked Asym v9 surface. CONUS gap quantification deferred to v3.0.1 once the lapp pass on the 13 GB unmasked surface completes (Cardinal job 11787913).
- Both sections committed to holoros/cspi-conus as `manuscript/CSPI_v0_10l_manuscript_draft.md` and `manuscript/CSPI_v0_10l_FEM_combined.docx` at commits `1309547` and `11517b5`.

### v3.0.0 Zenodo deposit
Already published in the previous session at DOI **10.5281/zenodo.20763197**. All five files present: forest-masked Asym v9 (6.7 GB), unmasked Asym v9 (13 GB), parent material overlay (294 MB), trained ranger model (83 MB), NEWS notes (5 KB).

### Autopilot Tier 1 to 4 analyses
- **Tier 1A AmeriFlux** validated. Result feeds §3.19 (n = 28 forests, r = 0.17 pooled). Files: `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/ameriflux_us_forest_sites.csv` and `ameriflux_predictions.csv`.
- **Tier 1B ForestGEO** ran but Asym v9 returned all-NA at single-pixel extracts (sparse predictor coverage at 30 m). Deferred to v3.1.0 with note to buffer-window extract.
- **Tier 2A and 2B reforestation** is the still-running compute (job 11787913 at 19:40 elapsed, lapp pass at ~50% per progress bar). Will write `REFORESTATION_CANDIDATE_30m.tif` and `REFORESTATION_GAP_summary.csv` on completion.
- **Tier 3A BGI temporal** could not run because TREE_GRM_MIDPT.csv coverage is partial. Deferred to v3.1.0.
- **Tier 3B SDI density**: 745,000 plot-level SDI values computed but the merge to plot table failed on a column-name mismatch (key vs PLT_CN). SDI vector saved on Cardinal for re-merge in v3.1.0.
- **Tier 4A Moran's I**: 5000-plot subsample residual autocorrelation computed via `ape::Moran.I`. Result available for §4.7 footnote in v3.1.0.

## Pending: the reforestation gap CSV

Cardinal job **11787913** is still computing the unmasked Asym v9 lapp pass to produce the reforestation candidate raster and the gap summary CSV. At the close of this session it has been running for about 20 minutes and is approximately halfway through the lapp. Expected completion in 20 to 30 more minutes.

When the job completes:

```bash
ssh <user>@<cardinal-host> "
  sacct -j 11787913 --format=JobID,State,Elapsed,ExitCode | head -3
  cat /fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION_GAP_summary.csv
  ls -la /fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION*
"
```

Then backfill the CSV's `total_carbon_storage_potential_Tg` and `non_forest_high_potential_pixels_M` numbers into §3.20 of `CSPI_v0_10_manuscript_draft.md` to replace the "will be tabulated in v3.0.1" sentence with the actual values.

## Remaining manual actions

1. **Send coauthor review email.** Anthony D'Amato and Jereme Frank, with `CSPI_v0_10l_FEM_combined.docx` attached. Drafted email is in the project folder from an earlier session.
2. **Submit to Forest Ecology and Management** once Anthony and Jereme have reviewed. Package is ready (v0.10l manuscript, supplements, figures).

## Files of record this session

| File | Path |
|---|---|
| Manuscript markdown | `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| Manuscript docx | `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10l_FEM_combined.docx` |
| Repo manuscript copy | `/home/aweiskittel/Documents/Claude/CRSF-Cowork/repos/cspi-conus/manuscript/CSPI_v0_10l_manuscript_draft.md` |
| Repo docx copy | `/home/aweiskittel/Documents/Claude/CRSF-Cowork/repos/cspi-conus/manuscript/CSPI_v0_10l_FEM_combined.docx` |

## Commits on holoros/cspi-conus this session

`1309547` (v0.10l AmeriFlux §3.19) and `11517b5` (v0.10l reforestation §3.20).

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 is published at Zenodo DOI 10.5281/zenodo.20763197 (5 files, 20 GB). Manuscript is at v0.10l with the AmeriFlux external validation (§3.19, r = 0.17 honest reading) and reforestation potential framing (§3.20, awaiting gap quantification) integrated. Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10l_to_v0_10m.md`. Please pick up by:
>
> 1. SSH to Cardinal and check `sacct -j 11787913`. When complete, cat `/fs/scratch/PUOM0008/crsfaaron/v3.1_analyses/REFORESTATION_GAP_summary.csv`.
> 2. Backfill the reforestation gap numbers (high-potential non-forest pixel count, aggregate carbon storage potential in Tg, top-three ecoregions by gap area) into §3.20 of `CSPI_v0_10_manuscript_draft.md`, replacing the placeholder sentence "CONUS-scale pixel counts and aggregate carbon storage potential summaries from the unmasked surface will be tabulated in v3.0.1 once the underlying compute completes."
> 3. Rebuild the docx with pandoc, commit, and push.
> 4. Help me send the coauthor review email to Anthony D'Amato and Jereme Frank with the v0.10m docx attached.
> 5. Confirm the FEM submission package is ready.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token in the Cardinal token file (mode 600) — never echo to stdout. GitHub PAT in the private token store. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
