# Repo and Zenodo reorganization plan: separating CSPI from fvs-conus

*14 June 2026. Plan for the suggested cleavage of the CSPI work into its own repository and deposit lineage. Aaron's instinct that this work has grown beyond the fvs-conus scope is correct.*

## Current state

| Asset | Location | Status |
|---|---|---|
| Manuscript draft v0.10g | `holoros/fvs-conus/manuscript_v0_10/` | Mixed with FVS work |
| Pipeline scripts | `holoros/fvs-conus/scripts_v0_10/` | 12+ R and Python scripts |
| Analysis CSVs | `holoros/fvs-conus/analyses_v3/v4/v5/v5_L3/v5_ML/` | 30+ result files |
| Outreach package | `holoros/fvs-conus/outreach/` | 4 markdown files |
| Combined FEM submission | `holoros/fvs-conus/manuscript_v0_10/CSPI_v10_FEM_combined.docx` | 4 MB |
| F8–F11 figures | `holoros/fvs-conus/figures_v10/` | 5 PNGs + 1 SVG |
| F7 3-component map | `holoros/fvs-conus/figures_v10/F7_cspi_v21_3c_map.png` | 1.6 MB |
| NEWS.md | `holoros/fvs-conus/NEWS.md` | Top-level |
| Synthesis doc | `holoros/fvs-conus/SYNTHESIS_unified_cspi_recommendations.md` | Top-level |
| Handoff docs | `holoros/fvs-conus/HANDOFF*.md` | Top-level |
| Self-review report | `holoros/fvs-conus/manuscript_v0_10/manuscript_v0_10b_self_review.md` | Buried |
| Zenodo concept 10.5281/zenodo.20515034 | "Composite Site Productivity Index for the conterminous United States" | v1.0.0 + v2.0.0 |

## Proposed reorganization

### New repository: `holoros/cspi-conus`

**Scope:** the conceptual paper + analytical chain + data release supporting documentation.

**Structure:**

```
cspi-conus/
├── README.md                       # what is CSPI; pointers to data, paper, code
├── NEWS.md                          # release history (v0.10b correction, etc.)
├── manuscript/
│   ├── CSPI_v0_10g_draft.md         # the v0.10g manuscript draft
│   ├── FEM_submission_combined.md   # cover + title + highlights + manuscript + supplements
│   ├── FEM_submission_combined.docx
│   ├── self_review.md
│   └── figures/                     # F1-F11 + Sn supplements
├── analyses/
│   ├── multidim_v3/                 # C1-C5 disturbance, treatment, stand size, per-state, SITECLCD
│   ├── multidim_v4/                 # D-series SICOND base-50, E-series SSURGO, F-series compilation SI, G-series GADA, H-series bootstrap
│   └── multidim_v5/                 # L3 ecoregion + multilevel ML
├── scripts/
│   ├── ecoregion_composite.r
│   ├── ecoregion_L3_composite.r
│   ├── multilevel_from_L3.r
│   ├── gada_refit.r
│   ├── ssurgo_login.r
│   ├── sicond_base50.r
│   ├── compilation_si.r
│   ├── bootstrap_cis.r
│   └── (others)
├── outreach/
│   ├── 01_crsf_news_article.md
│   ├── 02_social_posts.md
│   ├── 03_press_release_draft.md
│   ├── 04_coauthor_review_email.md
│   └── README.md
├── docs/
│   ├── synthesis_unified_cspi.md
│   ├── prototype_v3_ecoregion.md
│   ├── stress_test_v0_10g.md
│   ├── reorg_plan.md (this file)
│   └── handoffs/                    # session handoff docs
└── presentations/
    └── CSPI_v10_collaborators_overview.pptx
```

### Keep `holoros/fvs-conus` for:

- The original FVS modernization (Fortran)
- DG-Kuehne calibration scripts
- FIA + CEM Maine work
- Original v2 pipeline scripts that are also used elsewhere

### Migration steps

1. **Create new repo** `holoros/cspi-conus` (private initially; flip to public when v0.10g manuscript posts)
2. **Move CSPI artifacts** from fvs-conus to cspi-conus via `git filter-branch` or simple `git mv` + commit
3. **Leave a stub README in fvs-conus** pointing to `holoros/cspi-conus` for the CSPI work
4. **Update all cross-references** in NEWS.md, manuscript text, and Zenodo metadata
5. **Update the Zenodo concept metadata** to point to the new repo as the canonical source

### Zenodo organization

**Recommendation:** keep the existing Zenodo concept 10.5281/zenodo.20515034 for data deposits but reorganize what each version contains:

| Version | Concept DOI | Contents |
|---|---|---|
| v1.0.0 (released June 2026) | 10.5281/zenodo.20515035 | Single-metric CSPI v3 + v4 surfaces (data only) |
| v2.0.0 (released June 2026) | 10.5281/zenodo.20663652 | Multi-metric composite + components (data only, lightweight files) |
| v2.0.1 (pending v7_qrf) | TBD | + 30m quantile-RF uncertainty raster |
| v2.1.0 (planned) | TBD | + 30m wall-to-wall surfaces + MOD17 NPP upgrade |
| v3.0.0 (future) | TBD | + multilevel composite family (if separate paper accepted) |

**Add a new Zenodo concept for the analytical archive:**

- Suggested DOI request: "Composite Site Productivity Index (CSPI) analytical chain and pipeline for the conterminous United States"
- Contains: manuscript drafts, all multidim_v3/v4/v5 result CSVs, pipeline scripts, outreach package
- Versioned alongside the data deposits (v0.10g manuscript = analytical v1.0.0)
- Citable as "Weiskittel 2026 CSPI analytical chain" alongside the "Weiskittel 2026 CSPI data surfaces"

This gives downstream users two clear citation paths:
- Cite the data deposit when using the surfaces in modeling
- Cite the analytical deposit when reproducing the methods or extending the multidim analyses

## What this enables for the future

1. **Cleaner search / discovery.** A researcher searching "CSPI" finds the dedicated repo immediately rather than digging through fvs-conus
2. **Independent versioning.** CSPI v3.0.0 can ship even if FVS is on a different release cycle
3. **Reduced cognitive load.** New collaborators see only CSPI-relevant code in cspi-conus
4. **Better citation tracking.** Concept DOI for data + concept DOI for analytical chain = clean separation in citation databases
5. **Easier proposals.** When pitching v3.0.0 work, point to a self-contained repo rather than a subset of fvs-conus
6. **Open-source posture.** When the manuscript posts, the public repo cspi-conus becomes the canonical citation; fvs-conus stays focused on FVS modernization

## Estimated effort

- Repo creation + initial commit: 1 hour
- Migration of artifacts + cross-reference updates: 2-3 hours
- Zenodo concept creation: 1 hour (metadata + initial deposit + DOI mint)
- README and documentation polish: 2 hours
- **Total: roughly half a day**

## Risk considerations

- **Lost commit history** if done as a `git mv` rather than `git filter-branch`. Acceptable for the analytical work; not ideal for the manuscript draft history which has substantial revision trace
- **Broken links** in the existing FEM submission docx that reference figures by repo-relative paths. Easy to fix on rebuild
- **Zenodo cross-references** in the v2.0.0 README that point to `github.com/holoros/fvs-conus` would need updating in a v2.0.0.1 metadata-only update

## Recommended next steps

1. **Confirm the reorganization is desired** (Aaron decision)
2. **Initialize the new repo** `holoros/cspi-conus` via `gh repo create`
3. **Run the migration script** — `git mv` approach with explicit history-preservation flags for the manuscript directory
4. **Update Zenodo metadata** on the existing concept to add a note about the new repo
5. **Create the new analytical-chain Zenodo concept** at the time of v0.10g manuscript submission
