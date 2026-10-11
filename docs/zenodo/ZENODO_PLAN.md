# Zenodo deposit plan — 14 June 2026

Three actions per the REORG plan. All ready for Aaron's go/no-go.

## Action 1 — NEW CONCEPT: CSPI analytical chain v1.0.0 (READY TO FIRE)

**Staging location:** `/users/PUOM0008/crsfaaron/zenodo_staging/cspi-analytical-chain-v1/`
**Total payload:** 119 files, 9 MB
**Suggested fire command from Cardinal tmux session:**

```bash
cd /users/PUOM0008/crsfaaron/zenodo_staging/cspi-analytical-chain-v1
python upload_to_zenodo.py \
    --token-file "$ZENODO_TOKEN_FILE" \
    --metadata zenodo_metadata.json \
    --files-list files_to_upload.txt \
    --publish
```

**What's in the package:**
- `manuscript/` v0.10g manuscript draft + FEM combined md/docx + self-review (4 files)
- `analyses/` 30 result CSVs covering multidim_v3 (C1-C5 FIA context), v4 (D-E-F-G-H = SICOND, SSURGO, GADA, bootstrap), v5_L3 + v5_ML2 (ecoregion + multilevel + stress tests)
- `scripts/` 30+ R and Python pipeline scripts (gada_refit, ssurgo_login, ecoregion_L3, multilevel_from_L3, bootstrap_multilevel, etc.)
- `outreach/` 5 markdown files (CRSF news, social posts, press release, coauthor email, README)
- `docs/` SYNTHESIS, PROTOTYPE, STRESS_TEST, REORG, PAPER_SPLIT outlines
- `README.md` deposit description with cross-references to data deposit + GitHub
- `NEWS.md` v0.10 to v0.10g revision history with Simpson paradox transparency note
- `zenodo_metadata.json` Zenodo API metadata (publication / preprint type, forestry community, CC-BY-4.0, ORCID 0000-0003-2534-4478)

**Metadata highlights:**
- Title: "Composite Site Productivity Index (CSPI) analytical chain v1.0.0 for the conterminous United States"
- upload_type: `publication` / `preprint`
- Linked to data concept DOI `10.5281/zenodo.20515034` via `isPartOf`
- Linked to source repo `holoros/cspi-conus` via `isSupplementTo`

Once fired, mints a brand new Zenodo concept DOI distinct from the data deposit. Two clean citation paths: the new concept for methods/scripts/manuscript, the existing concept (20515034) for data surfaces.

## Action 2 — METADATA REFRESH on v2.0.0 (deferred until Action 1 mints)

Once Action 1 lands and we know the new analytical chain DOI, the v2.0.0 data deposit metadata should be updated to:
1. Add `related_identifiers[]: { identifier: <new analytical DOI>, relation: hasPart, scheme: doi }`
2. Update the `related_identifiers` source URL from `github.com/holoros/fvs-conus` to `github.com/holoros/cspi-conus`
3. Add MOVED_CSPI.md note referencing the repo split

Suggested command (after Action 1):

```bash
python scripts/update_metadata.py \
    --token-file "$ZENODO_TOKEN_FILE" \
    --record-id <v2.0.0 record id, look up via list_deposits> \
    --metadata <updated v2.0.0 metadata json with new related_identifiers> \
    --publish
```

## Action 3 — v2.0.1 DEPOSIT (waiting on v7_qrf array completion)

The v7_qrf array `11553490_[5-40%4]` is blocked on AssocGrpJobsLimit and currently has 4 tasks running. At the current pace ~36 hours until the merge job (`11553491`) can fire and produce `CSPI_V7_CONUS_30m_uncertainty.tif`.

When that lands, fire a new-version deposit:

```bash
cd /users/PUOM0008/crsfaaron/zenodo_staging/cspi-v2-0-1
python scripts/new_version.py \
    --token-file "$ZENODO_TOKEN_FILE" \
    --parent-doi 10.5281/zenodo.20663652 \
    --metadata zenodo_metadata.json \
    --files-list files_to_upload.txt \
    --publish
```

This is already staged from prior session work (task #203). Just needs the new uncertainty raster.

## Recommended sequence

1. **Today**: review and fire Action 1 (analytical chain). Mints brand new concept DOI. Updates the cspi-conus README.md to backfill the DOI, commits.
2. **Tomorrow**: fire Action 2 once Action 1 DOI is known. Refreshes v2.0.0 metadata with the analytical link.
3. **When v7_qrf lands** (~36 hrs out): fire Action 3 v2.0.1 deposit.
4. **Future**: v2.1.0 once Zenodo quota expansion approved + 30m wall-to-wall surfaces ready.

## Sanity checks before firing Action 1

- [ ] Aaron reviews `README.md` for tone / completeness
- [ ] Aaron confirms `version = 1.0.0` is the right starting point (or wants v0.x.x as preliminary)
- [ ] Aaron confirms `publication_type = preprint` (alternative: `working_paper` or `report`)
- [ ] Aaron confirms forestry community membership (most useful for downstream discovery)
- [ ] Aaron confirms CC-BY-4.0 license (default; alternative CC-BY-NC-4.0 for commercial restriction)
- [ ] Token at `"$ZENODO_TOKEN_FILE"` on Cardinal is current 

## Risk and rollback

If the autopublish fires successfully but the metadata or files have errors:
- Files: can be replaced in a NEW VERSION (via `new_version.py`)
- Metadata: can be refreshed (via `update_metadata.py`)

What CANNOT be undone: the concept DOI itself once minted. So make sure the title and creator list are correct before firing.

A safer first deposit option: fire WITHOUT `--publish`, review the draft at the printed edit URL in the web UI, then publish from the UI. This adds ~10 minutes but catches metadata mistakes before they become permanent.
