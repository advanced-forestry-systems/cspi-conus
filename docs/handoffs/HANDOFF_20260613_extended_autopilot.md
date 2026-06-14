# Extended autopilot session handoff — 13 June 2026

## Status summary

| Track | Status | Detail |
|---|---|---|
| 1. multidim_v3 (B4d fix + 5 new C analyses) | DONE | SLURM 11554988 completed. C1–C5 CSVs pulled and integrated into manuscript Tables 3a, 5, 6 |
| 2. Fact-check v0.10 numbers | DONE | All numbers spot-check against source CSVs (multidim, multidim_v2, multidim_v3). One discrepancy fixed: 40,933 → 66,433 / 114,587 |
| 3. F11 decision tree | DONE | SVG hand-coded, converted to PNG (375 KB) via inkscape, added to combined FEM submission with caption |
| 4. Outreach package | DONE | CRSF news article (~650 words), LinkedIn (3 variants), X (2 variants), UMaine Communications press release |
| 5. 3c surface F7 update | IN PROGRESS | SLURM 11555064 (mask + F7 figure) fired at 11:00, ETA 60–90 min |
| 6. v2.0.1 release prep | WAITING | v7_qrf array 11553490 still running (4/40 active, 36 pending, 4:49 hr in). Tasks complete asynchronously |

## What landed in v5/

```
v5/CSPI_v0_10_manuscript_draft.md         # v0.10 with C1-C5 integrated, F11 referenced, n=66,433 fix
v5/CSPI_v10_FEM_combined.docx              # 2.86 MB, 11 figures (F1-F11), v0.10 main + v2 supplements
v5/submission_FEM_combined/_combined.md    # Updated highlights + v0.10 main paper swap
v5/figures_v10/                            # F8, F9, F10, F11 (SVG + PNG)
v5/outreach/                               # 4 files: news, social, press release, README
v5/HANDOFF_20260613_extended_autopilot.md  # This file
```

## What landed on Cardinal

```
/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif   # 42.5 GB, mean 38.51, sd 11.32
/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v3/                            # C1-C5 CSVs
/users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/multidim_v3_analyses.r     # pipeline
/users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/mask_cspi3c.r              # forest mask for 3c
/users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/fig_F7_3c.r                # F7 figure script
```

## What landed on holoros/fvs-conus GitHub

Three commits during this session:
1. `acc21fa` — v0.10 manuscript + multidim_v3 + F11 decision tree + outreach package
2. `17a53d5` — fact-check fix: 40,933 → 66,433/114,587, swap v0.10 reframe into combined FEM submission
3. `e3aea28` — v0.10 pipeline scripts (multidim_v3, mask_cspi3c, fig_F7_3c, post-surface chain)

## Manuscript headline changes from v0.9 to v0.10

Inserted Table 3a after Section 3.6: BGI alone reaches OOB R² = 0.808 when predicting FIA SITECLCD; ESI alone reaches 0.751. A six-percentage-point gap; the empirical cost of single-metric studies using site index as a proxy for the FIA productivity class.

Inserted Section 3.12 (Disturbance, Treatment, Stand size): fire/insect/disease plots have higher mean ESI but lower mean BGI than undisturbed plots; treatment regen plots show the opposite pattern; stand size shows the inverse correlation between the measures. Cleanest visual of the dimension separation.

Inserted Section 3.13 (Per-state correlations): r(ESI, BGI) ranges 0.013 in NC to 0.526 in ID; r(BGI, Asym) ranges −0.802 in OK to +0.908 in MN.

Inserted Section 4.6.1 (Decision tree commentary): refers to F11; identifies the three common failure modes (SITECLCD ranking miss, stand-age sign flip miss, species heterogeneity miss); maps applications (FVS calibration → ESI v7; carbon stock → BGI; long-run carbon accounting → Asym; flux modeling → NPP; cross-study ranking → CSPI v2).

Number fixes throughout: 40,933 → 66,433 (cross-prediction set) and 114,587 (FIA-joined set); §2.2 clarifies that z-score parameters were locked at the v0.9 cycle's 40,933 historical subset for cross-version numerical stability.

## What is pending in the queue

**Cardinal SLURM jobs in flight:**
- `11553490_5..40` v7_qrf array — 36 tasks queued, 4 running. Total ~36 hr remaining at current rate.
- `11553491` v7_qrf_m merge — pending dependency on the v7_qrf array.
- `11555064` cspi3c_post — mask + F7 figure, ETA 60–90 min from 11:00.
- `11505310_x` cem2100 — unrelated (Maine CEM run), running independently.

**Manuscript steps not yet done (out of scope for this autopilot pass):**
- Compile v0.10 docx with F7 spatial map (Section 3.10) once 11555064 lands.
- Add F7 caption to the combined FEM submission figure list.
- Update collaborator PPTX with the F7 3-component spatial map.

**v2.0.1 deposit prep (Track 6):**
- Waits on v7_qrf merge to produce CSPI_V7_CONUS_30m_uncertainty.tif.
- Then stage in /fs/scratch/PUOM0008/crsfaaron/zenodo_v2_0_1/ with QRF layer + updated NEWS + README.

## Resumption next session

1. SSH to Cardinal: copy key from `/sessions/.*/mnt/aweiskittel/Documents/Claude/.ssh-cardinal/id_ed25519_cardinal` to /tmp, build a non-default ssh config (workspace `/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf` has wrong perms so default ssh fails).
2. Check queue: `squeue -u crsfaaron`.
3. If 11555064 done, pull `/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/F7_cspi_v21_3c_map.png` to v5/figures_v10/, update manuscript, re-export docx, commit.
4. If v7_qrf done, stage v2.0.1 deposit and request Zenodo new-version upload.
5. Active tasks tracker holds the chain in task #229 (poll Cardinal) and #232 (pull F7 when ready).

## Session metrics

- Total commits to fvs-conus: 3
- Manuscript word count change: roughly +2,000 (new sections 3.12, 3.13, 3a, 4.6.1)
- New artifacts: 5 figures (F11), 4 outreach docs, 5 result CSVs, 3 pipeline scripts
- Bench-test fact-checks: all reported numbers in v0.10 verified against source CSVs
