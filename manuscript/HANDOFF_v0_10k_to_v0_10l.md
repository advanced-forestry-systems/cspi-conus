# CSPI Manuscript & v3.0.0 Release Handoff
## End of session 19 June 2026 → next session

This doc captures the full state for picking up where we left off. The prompt for the next session is at the bottom.

## Where we are

The CSPI multi-dimensional productivity manuscript is at draft **v0.10k** with the two-story arc Aaron requested. New §3.18 (DSTRBCD1 × EPA L3 ecoregion interaction) is the strongest single piece of evidence in the paper that productivity-dimension orthogonality is structural rather than methodological: joint stratification yields r(ESI,BGI) range of 1.40 across 115 cells, wider than any single-axis stratification.

The v3.0.0 surface release is **fully staged and dependency-queued to fire automatically**. The ASYM_V9_CONUS_30m.tif mosaic (13 GB, 90,000 × 212,400 pixels) is built. The forest-mask streaming job (11786566) is currently running and writing `ASYM_V9_CONUS_30m_fmasked.tif` (rate has slowed to ~12 MB/min in the second half; estimated landing later today). The Zenodo deposit job (11786731) is dependency-queued (`afterok:11786566`) and will fire as a **draft** (no autopublish) the moment the surface lands.

The delta layer (ASYM_DELTA_v9_v7_CONUS_30m.tif) is partially written and orphaned on disk. The v3.0.1 release will ship it after a clean single-job rebuild.

## What's in flight on Cardinal

| Job | What | State |
|---|---|---|
| 11786566 | asym_fm: forest-masked Asym v9 30m output | RUNNING (~30% done at last poll) |
| 11786731 | cspi_v3_zen: dependency upload to Zenodo as draft | PENDING on Dependency |

When 11786566 lands, 11786731 will auto-fire. It runs `upload_to_zenodo.py` against the staged metadata and creates a DRAFT deposit (no `--publish` flag). You can then verify via the Zenodo web UI and click publish manually.

## What's in the v3.0.0 deposit

| File | Where on Cardinal | Size |
|---|---|---|
| ASYM_V9_CONUS_30m_fmasked.tif (in flight) | `/users/PUOM0008/crsfaaron/raster_layers/asym_v9/` | ~6 GB est |
| parent_material_30m_CONUS_4326.tif | `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/` | 294 MB |
| m_asym_v9_v3stack.rds | `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/` | 83 MB |
| NEWS_v3.0.0.md | `/fs/scratch/PUOM0008/crsfaaron/zenodo_staging/cspi-v3/` | ~5 KB |

Metadata: `/fs/scratch/PUOM0008/crsfaaron/zenodo_staging/cspi-v3/metadata.json`. Upload script: same dir, `upload_to_zenodo.py`. Files list: same dir, `files_to_upload.txt`. Slurm wrapper: same dir, `fire_upload.slurm`.

## Remaining tasks for FEM submission

1. **Verify Zenodo deposit landed as draft.** Once 11786731 completes, inspect its output log at `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi_v3_zen_*.out`. The script prints the deposit ID and pre-mint DOI on success.
2. **Publish via Zenodo web UI.** Log in at zenodo.org, find the CSPI v3.0.0 draft, verify the metadata and files, click publish. The DOI mints at that moment.
3. **Backfill the minted DOI** into manuscript Abstract + §7 Data and Code Availability, NEWS_v3.0.0.md, and cspi-conus README. Regenerate docx + PPTX with the new DOI.
4. **Send coauthor review email** to Anthony D'Amato and Jereme Frank with the v0.10k docx attached. The drafted email is in the project folder from an earlier session.
5. **Submit to Forest Ecology and Management.** The package is ready.

## What's done in this session

- v0.10k manuscript reorganization to two-story arc (Abstract reframed, §3 split with explicit Primary/Secondary divider headings, §3.18 new for DSTRB × L3, Conclusion rewritten).
- Three blocking citation placeholders verified and fixed (Westfall NSVB GTR WO-104 2024, Subedi 2024 FEM, Hoover and Smith 2012 not Smith 2024).
- NIFA McIntire-Stennis acknowledgment removed (Aaron has no MAFES appointment).
- ASYM_V9_CONUS_30m.tif tile-array predict + mosaic complete.
- Forest-mask streaming job in flight; Zenodo dependency-queued.
- v3.0.0 scope-down to 2 products (delta deferred to v3.0.1).
- docx + PPTX regenerated for v0.10k.
- Commits on holoros/cspi-conus: 9333cf4, 381fb17, 4acb1f4, 5743b2d, 8c39a4e, 58ed07d, 1afacba, d77c9f9, 238a7c1.

## Key paths

| What | Where |
|---|---|
| v0.10k manuscript | `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/CSPI_v0_10_manuscript_draft.md` |
| v0.10k docx | `CSPI_v0_10k_FEM_combined.docx` |
| v0.10k PPTX | `CSPI_v10k_collaborators_overview.pptx` |
| v3.0.0 metadata | `cspi-conus/zenodo/v3.0.0_metadata.json` |
| NEWS v3.0.0 | `cspi-conus/NEWS_v3.0.0.md` |
| Zenodo staging on Cardinal | `/fs/scratch/PUOM0008/crsfaaron/zenodo_staging/cspi-v3/` |
| Asym v9 30m surface | `/users/PUOM0008/crsfaaron/raster_layers/asym_v9/ASYM_V9_CONUS_30m_fmasked.tif` |
| Parent material 30m EPSG:4326 | `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/parent_material_30m_CONUS_4326.tif` |

---

## PROMPT FOR NEXT SESSION

Paste this verbatim into the next session to pick up where we left off.

> The CSPI v3.0.0 surface release was set up as an autonomous Cardinal pipeline at the end of the last session. Job 11786566 produces ASYM_V9_CONUS_30m_fmasked.tif via terra block-streaming. Job 11786731 is dependency-queued (afterok:11786566) and auto-fires the Zenodo deposit script as a draft (no autopublish) when the surface lands. The full state is documented at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10k_to_v0_10l.md`. Please pick up by:
>
> 1. SSH into Cardinal. Check `sacct -j 11786566` and `sacct -j 11786731` to see if both jobs completed.
> 2. If 11786731 completed, read its log at `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi_v3_zen_*.out`. Look for the Zenodo deposit ID and pre-mint DOI URL. Report these to Aaron.
> 3. If 11786731 failed, diagnose by reading the err log. Common failures are: stale TIFF handle (re-fire with fresh output filename), token auth failure (verify ~/.zenodo_token mode 600 with at least one curl GET against zenodo.org/api/deposit/depositions), or metadata validation error (the script prints the server response body).
> 4. If both jobs completed cleanly, walk Aaron through publishing the draft via the Zenodo web UI (he will manually click publish; the DOI mints at that moment).
> 5. Once Aaron has the minted DOI, backfill it into the v0.10k manuscript Abstract + §7 Data and Code Availability, cspi-conus/NEWS_v3.0.0.md, and cspi-conus/README. Regenerate `CSPI_v0_10k_FEM_combined.docx` and `CSPI_v10k_collaborators_overview.pptx` with the new DOI references. Commit and push to holoros/cspi-conus.
> 6. Confirm coauthor review email is ready to send (Anthony D'Amato + Jereme Frank). The draft is in the project folder from earlier sessions.
> 7. v3.0.1 follow-up: rebuild ASYM_DELTA_v9_v7_CONUS_30m.tif as a clean single-job streaming pipeline. The partial 7 GB delta file is orphaned on disk; Aaron must delete it manually (deletions on Cardinal are prohibited from autopilot sessions).
>
> Security policy: file deletions on Cardinal are prohibited (provide rm commands as text only). Zenodo token at `~/.zenodo_token` on Cardinal mode 600. Never echo to stdout. GitHub PAT at `/sessions/.../.gh-holoros/token`. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style preferences: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose (they are an AI tell).
