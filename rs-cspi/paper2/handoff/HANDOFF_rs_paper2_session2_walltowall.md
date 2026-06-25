# CSPI Paper 2 handoff: session 2, wall to wall pivot
## 23 June 2026

## What changed

Session 1 fit the RS targets at the 61,656 FIA plot coordinates, which still leaned on the FIA frame. Aaron flagged that the point of the project is a fully FIA free surface: sample the wall to wall RS productivity rasters on the environmental grid, fit env to target, and predict a CONUS surface. Session 2 rebuilt the analysis that way and produced the consensus surface.

## Result that matters

On the wall to wall grid, every target predicts better than at the FIA plots:

| Target | wall to wall OOB R² | FIA plot OOB R² |
|---|---|---|
| MODIS NPP | 0.953 | 0.919 |
| GEDI AGBD | 0.873 | 0.743 |
| CMS AGB 2016 | 0.928 | 0.574 |
| CMS AGB change | 0.790 | 0.512 |

The structural targets gain the most because they suffered most from plot noise and coordinate fuzzing. The FIA frame was adding noise. This is the headline for the paper.

## Products (Cardinal `rs_target/wtw/`, key ones pulled to `paper2/zenodo/v4.0.0/surfaces/` and `paper2/figures/wtw/`)

- `WTW_consensus_productivity_idx_4p6km.tif` (0 to 100 consensus index, FIA free)
- `WTW_consensus_agreement_sd_4p6km.tif` (per cell agreement layer)
- `WTW_pred_{npp,agbd,cms16,chg}_4p6km.tif` (single target surfaces)
- `WTW1_oob_summary.csv`, `WTW2_cell_predictions.csv`
- maps `WTW_F1_consensus_map.png`, `WTW_F2_agreement_map.png`
- build script `cardinal_scripts/rs_wtw_consensus.r`; GEE NPP export `gee_npp_export.py`

## Design notes

- Grain 4.6 km, set by the climate to water predictor stack (the targets are finer but the predictors cap resolution). State this plainly in the paper. A finer surface needs a finer climate stack, a separate effort.
- Parent material dropped from the surface fits (H4 showed under 0.01 R squared; it was the only 30 m layer and not worth the extraction cost).
- MODIS NPP pulled wall to wall from GEE via getDownloadURL (project sae-followon is in Restricted Mode, so fire one export at a time to avoid 429).

## Next session

1. Spatially blocked CV for the wall to wall fits. The dense grid inflates OOB R² via spatial autocorrelation; a blocked CV gives the defensible number. This is the most important validation gap.
2. Add GPP (retry the GEE export alone) and a canopy height or Sentinel-2 greenness target to broaden the consensus.
3. Optionally downscale to 1 km for display, clearly labelled as env limited.
4. Finalize the Zenodo deposit (see below) and draft the manuscript around the wall to wall result.

## Zenodo deposit status

A deposit package is staged on Cardinal at `/users/PUOM0008/crsfaaron/zenodo_staging/rs_multitarget/` and mirrored at `paper2/zenodo/v4.0.0/`. Metadata reframed to the v4.0.0 wall to wall consensus surface. NOT published; minting a production DOI is held for Aaron's go. Open decision: publish as v4.0.0 of the existing CSPI concept record (10.5281/zenodo.20515034) via `new_version.py`, or as a standalone record. Recommend publishing only after the spatially blocked CV lands so the headline R² in the deposit description is the defensible one.

## Policy (unchanged)

Cardinal deletions prohibited from autopilot (rm as text only). Earthdata token in `~/.netrc` password field, pass as Bearer header, never echo. Zenodo token `~/.zenodo_token` mode 600. Funding CRSF only. Style: R first, no decorative hyphens. The FEM manuscript remains untouched at v0.10q. This RS-CSPI paper is single-author.
