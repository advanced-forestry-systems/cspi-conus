# CSPI Manuscript & v3.0.0 Release Handoff
## End of session 19 June 2026 → next session

## State summary

| | |
|---|---|
| Manuscript | **v0.10k** — two-story arc reorganization complete |
| Zenodo deposit | **20763197 draft** at https://zenodo.org/deposit/20763197 |
| Reserved DOI | **10.5281/zenodo.20763197** (will mint on publish) |
| Files in deposit | 4 of 5 uploaded; 5th (13 GB unmasked) in flight via job 11787174 |
| DOI backfilled | Yes — manuscript Abstract + §7, NEWS, cspi-conus README |
| docx + PPTX | Regenerated with DOI; committed at holoros/cspi-conus 9ebe235, 7cf9acf |

## Deposit 20763197 contents

| File | Size | State | Use |
|---|---|---|---|
| ASYM_V9_CONUS_30m_fm.tif | 6.7 GB | Uploaded | Forest-masked headline product (Hansen tree cover 2000 ≥ 30%) |
| ASYM_V9_CONUS_30m.tif | 13 GB | Uploading (job 11787174) | Unmasked for reforestation use case (non-forest pixels carry model-estimated potential carrying capacity) |
| parent_material_30m_CONUS_4326.tif | 294 MB | Uploaded | gSSURGO 10-class overlay |
| m_asym_v9_v3stack.rds | 83 MB | Uploaded | Trained ranger model for reproducibility |
| NEWS_v3.0.0.md | 5 KB | Uploaded | Release notes |

## Remaining manual actions

These cannot be done autonomously; they require your action.

1. **Verify and publish the deposit.** Once the 13 GB unmasked file upload completes (job 11787174 will write a DONE line to its log), open https://zenodo.org/deposit/20763197 in a browser. Verify all 5 files are present and metadata reads correctly. Click "Publish" to mint the DOI. The reserved DOI 10.5281/zenodo.20763197 becomes the official v3.0.0 DOI at that moment.
2. **Send coauthor review email.** Anthony D'Amato + Jereme Frank, with the CSPI_v0_10k_FEM_combined.docx attached. The drafted email is in the project folder from an earlier session.
3. **Submit to Forest Ecology and Management.** Package is ready (v0.10k manuscript + supplements + figures).

## Cardinal job state

| Job | What | State |
|---|---|---|
| 11787174 | Upload ASYM_V9_CONUS_30m.tif (13 GB) to deposit 20763197 | RUNNING |

## What landed in this session

- **v0.10k manuscript reorganization** to your two-story arc (primary: cross-metric vs traditional FIA SICOND/SITECLCD + CSPI v2 development; secondary: drivers of metric divergence). Abstract reframed, §3 split with explicit divider headings, §3.18 added for DSTRB × EPA L3 ecoregion interaction (r(ESI,BGI) range = 1.40 across 115 cells, wider than any single-axis stratification), Conclusion rewritten.
- **3 verified citations** replacing placeholders (Westfall NSVB GTR WO-104 2024, Subedi 2024 FEM, Hoover and Smith 2012).
- **§6 Acknowledgments fix** — removed NIFA McIntire-Stennis (CRSF only since no MAFES appointment).
- **ASYM_V9_CONUS_30m.tif mosaic** (13 GB, 90,000 × 212,400 pixels).
- **ASYM_V9_CONUS_30m_fm.tif forest-masked surface** via Python rasterio block-streaming (25× faster than terra::lapp, 1105 s total).
- **v3.0.0 Zenodo deposit 20763197** with 5 files.
- **DOI 10.5281/zenodo.20763197 backfilled** into manuscript + NEWS + README.
- **docx and PPTX regenerated** with the new DOI.

## Commits on holoros/cspi-conus (this session)

9333cf4, 381fb17, 4acb1f4, 5743b2d, 8c39a4e, 58ed07d, 1afacba, d77c9f9, 238a7c1, 32622a9, 2d26eb3, 9ebe235, 7cf9acf

---

## PROMPT FOR NEXT SESSION

Paste verbatim into the next session.

> CSPI v3.0.0 deposit is staged at Zenodo draft 20763197 (https://zenodo.org/deposit/20763197) with reserved DOI 10.5281/zenodo.20763197. The 5th file upload (13 GB unmasked ASYM_V9_CONUS_30m.tif for reforestation use cases) was in flight via Cardinal job 11787174 at the end of the previous session. The v0.10k manuscript is committed at holoros/cspi-conus with the DOI backfilled. Full state at `/home/aweiskittel/Documents/Claude/CRSF-Cowork/active-projects/bgi-cspi-conus/v5/HANDOFF_v0_10k_to_v0_10l.md`. Please pick up by:
>
> 1. SSH into Cardinal. Check `sacct -j 11787174` to confirm the unmasked file upload completed.
> 2. Hit the Zenodo deposit API to verify all 5 files are present and total size is ~20 GB. If a file is missing, re-upload it.
> 3. Walk Aaron through publishing the draft via the Zenodo web UI. Once Aaron clicks publish, the DOI mints and the deposit becomes citable.
> 4. Verify the minted DOI matches the reserved DOI 10.5281/zenodo.20763197 (it should).
> 5. Help Aaron send the coauthor review email to Anthony D'Amato and Jereme Frank with CSPI_v0_10k_FEM_combined.docx attached.
> 6. Confirm submission package is ready for Forest Ecology and Management.
>
> Security policy: file deletions on Cardinal are prohibited from autopilot (provide rm commands as text only). Zenodo token in the Cardinal token file (mode 600) — never echo to stdout. GitHub PAT in the private token store. Never place tokens in URL query params (use Authorization Bearer header). IAM permission grants are user-only.
>
> Funding: University of Maine Center for Research on Sustainable Forests (CRSF) only. Aaron does not have a MAFES appointment so do not reattribute to NIFA McIntire-Stennis.
>
> Style preferences: retain past knowledge and provide R code when possible, Python when useful. Do not use hyphens in prose.
