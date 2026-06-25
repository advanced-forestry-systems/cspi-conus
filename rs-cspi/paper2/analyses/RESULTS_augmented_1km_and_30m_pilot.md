# Augmented 1 km and 30 m pilot: results

*23 June 2026. Both follow-on recommendations executed: add terrain and soil to the 1 km stack, and stand up the 30 m tiled pipeline.*

## Recommendation 1: augmented 1 km (done)

Added the CSPI v3 aligned terrain, soil, and canopy predictors (elevation, slope, aspect, bulk density, CEC, nitrogen, pH, sand, soil organic carbon, Hansen tree cover 2000, Hansen loss) to the 32 ClimateNA variables, giving a 43 predictor 1 km stack. Same four wall to wall targets, same grid.

| Target | 1 km climate only | 1 km augmented (43 preds) | 4.6 km water-balance |
|---|---|---|---|
| MODIS NPP | 0.946 | 0.948 | 0.953 |
| GEDI AGBD | 0.678 | **0.791** | 0.873 |
| CMS AGB 2016 | 0.738 | **0.894** | 0.928 |
| CMS AGB change | 0.451 | **0.602** | 0.790 |

Adding terrain, soil, and canopy recovered most of the structural fit lost when moving from 4.6 km to 1 km, exactly as expected: biomass responds to terrain and soils, not just climate. The augmented 1 km surface is now both finer than the 4.6 km build and close to it in skill. The fitted models were saved for reuse at 30 m.

## Recommendation 2: 30 m tiled pipeline (set up and validated)

Built a tiled 30 m predictor and prediction pipeline that reuses the augmented models. For any tile it crops the aligned 30 m terrain, soil, and canopy stack, resamples ClimateNA to the tile 30 m grid, assembles the 43 predictor brick, predicts each target in memory bounded row chunks, and writes a 30 m consensus tile. Global z standardisation parameters are computed once from a 1 km sample and cached.

Pilot tile: southern Appalachians and Great Smokies (1 degree box, 12.96 million cells, 11.35 million forested). The output resolves ridge and valley topography that the 1 km surface blurs, with productivity tracking drainages and aspect. End to end validation passed. Output `WTW_consensus_z_30m_smokies.tif` (39 MB).

Engineering note: the first pilot was OOM killed at 48 GB; the fix was to free the predictor rasters after extraction and predict in 2 million cell chunks, at 120 GB. The tile then ran in about 33 minutes, most of it in the chunked prediction.

## Full CONUS 30 m: runtime and plan

CONUS forest spans roughly 200 to 470 one degree tiles (depending on how empty ocean and non forest tiles are skipped). At about 30 minutes per tile, a SLURM job array running 20 to 40 tiles concurrently finishes the full 30 m CONUS consensus in roughly half a day to a day of wall clock. The pipeline is ready to launch as an array (`rs_wtw_30m_tile.r` takes a bbox and tag per array task; a driver script maps array index to tile bbox over the CONUS forest extent, mosaics the tiles, and computes the agreement layer).

Recommendation before launching the full array: throttle to a reasonable concurrent tile count to stay within the PUOM0008 allocation, and confirm the compute budget. The pilot proves correctness; the full run is a deliberate batch.

## Resolution summary across all builds

| Build | Grain | Predictors | NPP R² | AGBD R² | Biomass R² | Change R² |
|---|---|---|---|---|---|---|
| Plot frame (FIA) | point | water-balance + PM | 0.919 | 0.743 | 0.574 | 0.512 |
| Wall to wall | 4.6 km | water-balance + PM | 0.953 | 0.873 | 0.928 | 0.790 |
| Wall to wall | 1 km | ClimateNA only | 0.946 | 0.678 | 0.738 | 0.451 |
| Wall to wall | 1 km | ClimateNA + terrain/soil/canopy | 0.948 | 0.791 | 0.894 | 0.602 |
| Wall to wall | 30 m | same 43, tiled (pilot) | model reused | | | |

The 1 km augmented build is the recommended primary product. The 30 m build is the operational downscaling layer, validated and ready to run at full CONUS extent on request.
