# Resolution: 1 km build result and 30 m assessment

*23 June 2026. Increasing the wall to wall consensus from the 4.6 km env grain to 1 km, and an honest assessment of 30 m.*

## 1 km build (done)

Switched the predictor stack from the coarse 4.6 km climate-water layers to the ClimateNA 1991-2020 normals (32 variables at about 1 km, elevation-adjusted, EPSG:4326), on the CSPI v3 1 km CONUS forest grid (6556 x 2778, 5,349,396 forest cells). Same four wall to wall targets, fit env to target, predicted every forest cell, consensus and agreement layers.

| Target | OOB R² at 1 km (ClimateNA) | OOB R² at 4.6 km (water-balance stack) |
|---|---|---|
| MODIS NPP | 0.946 | 0.953 |
| GEDI AGBD | 0.678 | 0.873 |
| CMS AGB 2016 | 0.738 | 0.928 |
| CMS AGB change | 0.451 | 0.790 |

The 1 km consensus map resolves real fine structure (Appalachian ridge and valley, Pacific Northwest coastal band, western mountain ranges) that the 4.6 km surface could not show.

Important and honest result: explained variance falls at 1 km for the structural and change targets. Two reasons. First, the 1 km stack is climate-only (ClimateNA); the 4.6 km stack also carried water balance, N deposition, and distance to coast, which matter for biomass. Second, finer grain exposes fine-scale biomass and disturbance variation that climate cannot explain. NPP, a climate-driven flux, holds at 0.95. The takeaway: higher resolution is not free; for the structural targets a 1 km surface needs more than climate predictors to keep the fit strong.

Recommended next step for 1 km: add terrain derivatives (elevation, slope, aspect, TPI, TWI from a DEM, all available at 30 m and aggregable to 1 km) and SoilGrids to the 1 km stack. That should recover much of the lost structural R² because biomass responds to terrain and soils, not just climate.

## 30 m assessment

Can we go to 30 m? Yes, but with two honest caveats that make it a deliberate, dedicated job rather than an ad hoc run.

1. Predictors. Climate does not vary meaningfully below about 1 km, so a 30 m surface built from climate predictors alone is just the 1 km surface resampled, with no new information. Genuine 30 m detail must come from 30 m terrain (DEM derivatives), canopy (Hansen, 30 m), and soil (SoilGrids, 250 m) predictors. That is exactly the stack behind the existing CSPI v3 30 m and Asym v9 30 m surfaces, and those predictors live on Google Earth Engine. Assembling or exporting that 30 m stack for CONUS is the main setup cost, and the GEE service account is currently in Restricted Mode (concurrency limited), which slows large exports.

2. Targets. The productivity targets are all 500 m or coarser (MODIS 500 m, GEDI 1 km, CMS about 100 m to 1 km). A 30 m productivity surface is therefore a terrain and canopy driven downscaling of 1 km or coarser productivity information, not new 30 m productivity signal. That is legitimate and useful for operational and visualization purposes (it is what the CSPI 30 m site index surface already does), but it should be described as downscaling.

3. Compute. CONUS at 30 m is about 30 billion cells, roughly 6 billion forested. Prediction must be tiled. The existing CSPI 30 m surfaces are 13 to 18 GB each. A four target 30 m consensus is a multi hour to multi day tiled batch pipeline on Cardinal.

Recommendation. Treat 1 km as the scientifically honest resolution for a climate to environment driven productivity surface, and improve it first by adding terrain and soil predictors (cheap, recovers structural R²). Build the 30 m product as a deliberate downscaling deliverable using the CSPI 30 m terrain and canopy stack, run as a dedicated tiled job. I can set up the 30 m tiled pipeline on request; it is feasible, just heavy, and benefits from the GEE Restricted Mode limit being lifted or from using the on-disk 30 m predictor rasters that produced the Asym v9 surface.
