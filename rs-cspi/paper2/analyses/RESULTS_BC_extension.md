# British Columbia extension and the BC PSPL comparison

*23 June 2026. Following the BC Provincial Site Productivity Layer (PSPL) as a comparator.*

## What was done

1. Manuscript: the BC PSPL is now the operational comparator in the Introduction (a classification- and mapping-intensive site-index product that motivates an inventory-free RS alternative) and the Discussion (the RS-CSPI is the biophysical gap-fill BC uses, done everywhere and without ecosystem polygons). Single-author throughout.

2. Transferability: the RS-CSPI was extended to British Columbia. ClimateNA covers BC, so climate-only models for the globally available targets (MODIS NPP, OOB 0.90; GEDI AGBD, OOB 0.65) were trained on the CONUS plot frame and predicted over a 1 km BC grid (2.03 million cells). The result is a plausible BC productivity gradient: high along the wet coast (Vancouver Island, coastal mainland), low through the cold interior and north. Surface at `bc/BC_RS_CSPI_climate_1km.tif`, map `bc/BC_RS_CSPI_map.png`.

## Honest caveats on the BC surface

This is exploratory, not a validated BC product. It extrapolates CONUS-trained models beyond their climate envelope (BC is colder and wetter than most of CONUS, with different species), uses climate predictors only (no BC terrain, soil, or canopy stack assembled), drops the CONUS-only CMS biomass target, and has no land or forest mask applied. It demonstrates that the method transfers and produces a sensible gradient; it is not calibrated or validated for BC.

## The benchmark is blocked on data

The head-to-head against the BC PSPL could not be run on autopilot. The PSPL is distributed by Timber Supply Area through an ArcGIS web app or a BC Geographic Warehouse order; the data catalogue page is JavaScript-rendered and the CKAN API returned nothing usable. Obtaining the PSPL needs either a manual download of one or more TSAs, a BCGW order, or driving a browser through the Site Productivity Data Locator app.

## To complete the benchmark (next session)

1. Acquire the PSPL (one TSA or the provincial layer) as raster or polygon site index by species.
2. For a fair test, train BC-specific models on BC ground data or restrict to the climate overlap, rather than extrapolating CONUS models; and assemble a BC terrain/soil/canopy stack (SRTM, SoilGrids, Hansen are global) for the augmented predictors.
3. Compare RS-CSPI to PSPL site index by scale-invariant correlation. Expect a moderate, not high, relationship given the height-versus-flux divergence already shown against FIA site index; that is the anticipated result and the point.
