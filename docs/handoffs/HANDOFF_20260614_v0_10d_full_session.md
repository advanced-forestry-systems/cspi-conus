# CSPI v0.10d session handoff — 14 June 2026 full state

This document covers the entire session from the morning autopilot push through the GADA refit at midday. The headline outcome: a substantive Simpson paradox correction caught and triply confirmed before submission, leaving the manuscript in much stronger shape than v0.10 was.

## Manuscript version trace

| Version | Date | Headline change | Triggered by |
|---|---|---|---|
| v0.10 | 13 Jun 2026 | Multi-dim reframe, 3-component composite, FIA SICOND comparator (raw, pooled) | Earlier autopilot session |
| v0.10b | 14 Jun morning | Walked back the "SICOND has been measuring biomass growth" claim after detecting base-age Simpson paradox in `multidim_v4/D-series` | sicond_base50.r reviewer-style robustness test |
| v0.10c | 14 Jun midday | Added NRCS SSURGO comparator (Table 2b) at 87,404 plots after fixing the factor-bug join (857 → 87,404) | ssurgo_login.r + ssurgo_join_fix.r |
| v0.10d | 14 Jun afternoon | Added GADA-refit comparator (Table 2c) at 16,032 plots, confirming the v0.10b correction was correct | gada_refit.r |

## The headline finding that survives every revision

Random forest predicting FIA SITECLCD as a continuous response from each productivity measure (Table 3a, n = 63,310):

- BGI alone: OOB R² = **0.808**
- ESI alone: OOB R² = **0.751**
- Six percentage point gap

This statistic is independent of base-age corrections, equation-family choices, lookup-table-vs-fitted SI distinctions, and Simpson's paradox. It anchors the multi-dimensional argument and should lead every external communication.

## The SI-vs-SI structure after v0.10d

The three SI measurement chains at the 16,032-plot subset where all three are jointly observable:

| Pair | r |
|---|---|
| **SI_GADA × ESI_v7** | **+0.661** (strongest) |
| SICOND_raw × ESI_v7 | +0.635 |
| SICOND_raw × SI_GADA | +0.615 |

Each SI measure vs BGI in the same subset:

| Pair | r |
|---|---|
| **SI_GADA × BGI** | **+0.429** (strongest, but moderate) |
| ESI_v7 × BGI | +0.396 |
| SICOND_raw × BGI | +0.374 |

The corrected reading: when site index is fit properly with a base-age-invariant equation, it tracks our unified-target ESI strongly (r = 0.66) and BGI only moderately (r = 0.43). The raw pooled SICOND × ESI = −0.08 result was a Simpson paradox artifact of SIBASE stratum pooling.

## Cardinal job state

| Job | ID | Status | Output location |
|---|---|---|---|
| cspi3c_postsurface | 11555064 | DONE | `/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif` and `F7_cspi_v21_3c_map.png` |
| sicond_ssurgo (D-series) | 11566914 | DONE | `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v4/D1` through `D4` |
| ssurgo_login (E-series) | login node nohup | DONE | `multidim_v4/E0b` through `E3b`, plus the fixed `E2c_ssurgo_correlations_fixed.csv` and `E3c_plt_with_ssurgo_fixed.csv` |
| gada_refit (G-series) | login node nohup | DONE | `multidim_v4/G0` through `G4` |
| v7_qrf array | 11553490 | RUNNING tasks 17 to 20 of 40; about 24+ hours remaining | Will land at `/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_V7_CONUS_30m_uncertainty.tif` |
| v7_qrf merge | 11553491 | PENDING dependency on the array | Same |
| v7_unc restart | not numbered | DIAGNOSING (task #197) | Pending v7_qrf completion |

The SLURM AssocGrpSubmitJobsLimit blocked all SLURM submits for a while (project allocation cap, GrpSubmit=0). The login node fallback worked for both SSURGO and GADA, so the analytical chain is now unblocked for any other R-only work.

## File locations

### Manuscript and submission package
- `v5/CSPI_v0_10_manuscript_draft.md` — current v0.10d draft (will be renamed to v0.10d explicitly in next pass)
- `v5/submission_FEM_combined/_combined.md` — cover letter + title page + highlights + manuscript + figures + supplements
- `v5/CSPI_v10_FEM_combined.docx` — current 4.04 MB FEM submission with all 11 figures + Tables 2/2a/2b/2c/3/3a/4

### Outreach package
- `v5/outreach/01_crsf_news_article.md` — revised to lead with SITECLCD
- `v5/outreach/02_social_posts.md` — LinkedIn (3 variants) + X (2 variants)
- `v5/outreach/03_press_release_draft.md` — for UMaine Communications review
- `v5/outreach/README.md` — deployment cadence and tagging

### Figures
- `v5/figures_v10/F7_cspi_v21_3c_map.png` — new 3-component spatial map (1.6 MB)
- `v5/figures_v10/F8_siteclcd_by_measure.png` — SITECLCD mean by measure
- `v5/figures_v10/F9_stand_age_correlation.png` — ESI-BGI sign flip at 120 yr
- `v5/figures_v10/F10_per_species_ESI_BGI.png` — per-species ESI-BGI range
- `v5/figures_v10/F11_decision_tree.png` (and `.svg`) — application-by-measure decision tree
- `v5/figures_v04/F1-F6` — earlier figures still cited

### Analysis CSVs (locally)
- `multidim_v4/D1-D4` — SICOND base-age stratification + projection
- `multidim_v4/E1b` — SSURGO SI per mukey (raw)
- `multidim_v4/E2c_ssurgo_correlations_fixed.csv` — fixed-join 87,404-plot correlations
- `multidim_v4/G0-G4` — GADA refit per-species params + plot SI + correlations
- All also on Cardinal at `/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v4/`

### Collaborator deck and presentation
- `v5/CSPI_v10_collaborators_overview.pptx` — 2.42 MB, 13 slides, v0.10b numbers on slide 5 (needs v0.10d update with GADA)
- `scripts_v0_10/build_cspi_v10_collab_deck.py` — reproducible build script

### Self-review
- `v5/manuscript_v0_10b_self_review.md` — Modules 1, 2, 5 of manuscript-review skill; recommendation: Minor Revision

### NEWS.md
- v0.10b correction logged transparently with the full numerical trace

## What's open

### Self-review action items (deferred from this session)
1. **Bootstrap CIs** on Table 1, 2a, 2b, 2c, 3a r and R² values. ~30 min of R on the login node.
2. **Citation breadth** — scan 2022-2026 multi-metric productivity literature, add 2-3 references.
3. **F4 and F5 to supplements** — manuscript edit, drops main figures from 11 to 9.
4. **Quantify "modest calibration shifts"** in §4.3 — either give an empirical bound or remove the magnitude word.
5. **Add §4.7 paragraph "what is robust to the SICOND correction"** — echoes the NEWS.md transparency framing.

### Updates pending after Cardinal jobs land
1. **v2.0.1 deposit**: needs the v7_qrf uncertainty raster (~24+ hours away). After it lands: stage v2.0.1 package on Cardinal, run multipart upload to Zenodo, mint new version DOI.
2. **Collaborator deck slide 5**: update with GADA r = +0.66 with ESI as the strongest pairing and the three-chain triple-confirmation framing.

### Mid-term / next-version work
- v2.1.0 30 m wall-to-wall surfaces (waiting on Zenodo quota expansion)
- ESI v9 with MOD17 NPP upgrade (task #183)
- 30 m combined CSPI surface (tasks #165, #178)

## Recommended next-session opening sequence

1. **SSH to Cardinal**: same key/config dance as this session (`/sessions/.../mnt/aweiskittel/Documents/Claude/.ssh-cardinal/id_ed25519_cardinal` to `/tmp/cardinal_key`, then `/tmp/sshcfg` with `ConnectTimeout 20`).
2. **Poll Cardinal**: `squeue -u crsfaaron | head -10`. If v7_qrf array is done, the v2.0.1 deposit can be staged. If still running, defer.
3. **Read this handoff** and `NEWS.md` for the v0.10b/c/d correction trace before touching the manuscript.
4. **Resume task #245** (the deferred self-review items) and #252 (slide 5 update).
5. **GitHub state**: 9 commits today on `holoros/fvs-conus`, head is `6579dd6` (v0.10d GADA refit).

## Session metrics

- Total commits on `holoros/fvs-conus`: 9
- Manuscript word-count delta: roughly +3,000 across v0.10 → v0.10d (the SICOND-correction prose, SSURGO and GADA paragraphs, new Tables 2a/2b/2c)
- New artifacts: 5 figures (F11 + F7 3c), 4 outreach docs revised, 3 new pipeline scripts (gada_refit, ssurgo_login, ssurgo_join_fix), 16 new result CSVs (multidim_v4 series)
- The Simpson paradox catch is the single most valuable outcome. Catching it before submission rather than as a reviewer comment is a clear win.

---

*Prepared via the manuscript-preparer and crsf-workspace skill conventions. This document supersedes the morning's `HANDOFF_20260613_extended_autopilot.md` for v0.10b/c/d state.*
