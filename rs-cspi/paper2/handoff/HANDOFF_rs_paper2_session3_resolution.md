# CSPI Paper 2 handoff: session 3, resolution and deposit
## 23 June 2026

## Arc of this session

Took the wall-to-wall FIA-free consensus from 4.6 km to 1 km, then to an augmented 1 km build (climate + terrain + soil + canopy), stood up and validated a 30 m tiled pipeline, launched the full CONUS 30 m run, staged the v4.0.0 deposit, and started the spatially blocked CV. The deposit is held for publication pending the 30 m mosaic and the blocked CV (Aaron's decision).

## Resolution ladder (OOB R²)

| Build | grain | predictors | NPP | AGBD | biomass | change |
|---|---|---|---|---|---|---|
| FIA plot frame | point | water-balance + PM | 0.919 | 0.743 | 0.574 | 0.512 |
| Wall to wall | 4.6 km | water-balance + PM | 0.953 | 0.873 | 0.928 | 0.790 |
| Wall to wall | 1 km | ClimateNA only | 0.946 | 0.678 | 0.738 | 0.451 |
| **Wall to wall** | **1 km augmented** | **ClimateNA + terrain/soil/canopy (43)** | **0.948** | **0.791** | **0.894** | **0.602** |
| Wall to wall | 30 m | same 43, tiled | pilot validated; full CONUS running |

The 1 km augmented build is the recommended primary product. Predictor stacks: ClimateNA normals at `SiteIndex/rasters/ClimateNA/Normal_1991_2020_bioclim`; aligned terrain/soil/canopy at `cspi_v3/aligned_1km` and `aligned_30m` (elev, slope, aspect, bdod, cec, nitrogen, phh2o, sand, soc, h_tc2000, h_loss_raw). Forest mask `cspi_rs/CSPI_V3_CONUS_1km_forest.tif`.

## Running jobs (will finish after the session)

- **30 m array `11988510`**: 801 one-degree forest tiles, `--array=1-801%30`, 40 GB / 4 cpu each, about 30 min per tile. Writes `rs_target/wtw30m/WTW_consensus_z_30m_<tag>.tif`. Tile list in `rs_target/tiles.csv`. Script `rs_wtw_30m_tile.r` (bbox args), reuses the augmented models in `wtw1km_aug/`, z-params cached in `wtw1km_aug/zparams.rds`. Expect 11 to 15 hours wall.
- **Mosaic `11988601`** (`--dependency=afterany:11988510`): builds `WTW_consensus_z_30m_CONUS.tif` (COG) plus a 2000 px overview PNG from whatever tiles completed. Check it fired; if some tiles failed, rerun those array indices then resubmit the mosaic.
- **Blocked CV `11988793`**: spatial 1-degree block, 5-fold CV on the augmented 1 km data, 200k sample. Writes `wtw1km_aug/WTW1kmAUG_blocked_cv.csv` (blocked R² vs OOB). This is the conservative number for the deposit and the paper.

To monitor: `squeue -u crsfaaron`; completed tiles `ls wtw30m/WTW_consensus_z_30m_t*.tif | wc -l`.

## v4.0.0 deposit: staged, NOT published

Aaron chose to hold publication until the 30 m mosaic and blocked CV land, then publish a complete v4.0.0. Package staged and validated at Cardinal `/users/PUOM0008/crsfaaron/zenodo_staging/v4_surfaces/` (23 files, 1.7 GB) and mirrored at `paper2/zenodo/v4.0.0/`. Primary product the 1 km augmented consensus + agreement; 4.6 km companion; 4 trained models; OOB tables; validation tables; Smokies 30 m pilot tile. Metadata validates; all listed files present.

To publish when ready: add the CONUS 30 m surface and the blocked-CV numbers to README/metadata, then either `new_version.py --parent-doi 10.5281/zenodo.20515034` (new version of the CSPI concept record) or `upload_to_zenodo.py` (standalone). Decide concept-vs-standalone at that point. Zenodo token at `~/.zenodo_token` mode 600; never echo; Bearer header not URL param.

## Recommended next steps

1. Confirm the 30 m mosaic produced `WTW_consensus_z_30m_CONUS.tif`; rescale to a 0 to 100 index and render the CONUS map.
2. Fold the blocked-CV numbers into the deposit README and the manuscript (report blocked R² as the headline, OOB as the upper bound).
3. Re-run a spatially blocked CV at the tile/surface level if a reviewer wants surface-level rather than sample-level blocking.
4. Add GPP and a Sentinel-2 greenness target to broaden the consensus (GPP export blocked earlier by GEE Restricted Mode concurrency; fire one export at a time).
5. Draft the manuscript around the headline: gridded FIA-free sampling beats the FIA plot frame on every target, and the augmented 1 km consensus is the deliverable.

## Acquisition fixes locked in (do not re-derive)

- GEDI L4B v2.1: collection `GEDI_L4B_Gridded_Biomass_V2_1_2299`, files `GEDI04_B_MW019MW223_02_002_02_R01000M_{MU,SE}.tif`, ORNL DAAC, Authorization Bearer header (netrc password field holds an EDL JWT).
- NASA-CMS: collection `CMS_CONUS_Biomass_1752`, `CONUS_agb_{2005,2016}_v1.tif`.
- MODIS NPP wall-to-wall: GEE `getDownloadURL` single-shot at 5 km, one export at a time (Restricted Mode 429s on concurrency).

## Policy (unchanged)

Cardinal deletions prohibited from autopilot (rm as text only). Tokens never echoed; Bearer header. Funding CRSF only. R first, no decorative hyphens. The FEM manuscript remains untouched at v0.10q. This RS-CSPI paper is single-author.
