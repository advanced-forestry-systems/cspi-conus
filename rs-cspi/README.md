# cspi-rs-conus

Remote Sensing Composite Site Productivity Index (RS-CSPI) for the conterminous United States: a FIA-independent, microsite-resolving forest productivity surface.

This is the follow-on to the inventory-target CSPI work (advanced-forestry-systems/cspi-conus). It inverts the modeling design: remote sensing productivity metrics are the response (Y) and a wall-to-wall climate, terrain, soil, and canopy stack is the predictor (X). No forest inventory data enter the modeling chain. The fitted relationships are predicted across all forested cells to produce an integrated site productivity index at 1 km and 30 m, intended to drive growth and yield models and management planning where inventory site index is unavailable, out of date, or too coarse to resolve microsite variability.

## What is here

- `paper2/manuscript/` manuscript draft (RS_CSPI_manuscript_draft_v0_2.md) and the methods/results outline.
- `paper2/cardinal_scripts/` the R and Python pipeline: per-target fits, wall-to-wall consensus (4.6 km, 1 km, augmented 1 km), 30 m tiled prediction, blocked cross-validation, FIA comparison, small-area-estimation refinement, GEE exports.
- `paper2/analyses/` result tables and the written results memos (OOB and blocked CV, cross-target agreement, ecoregion residuals, FIA comparison, microsite variance partition, SAE prototype).
- `paper2/figures/` consensus and agreement maps, comparison figures, the 30 m CONUS overview.
- `paper2/zenodo/v4.0.0/` deposit metadata, README, data dictionary, and citation file.
- `paper2/handoff/` session handoffs.

## Data and models

Surfaces (1 km and 30 m GeoTIFF), trained random forest models, and the full analysis bundle are archived at Zenodo (CSPI v4.0.0), building on the v3.0.0 inventory-target dataset (DOI 10.5281/zenodo.20763197). Large rasters and models are not committed here; they live on Cardinal and Zenodo.

## Headline results

Sampling remote sensing productivity targets wall to wall on the predictor grid, rather than at FIA plot coordinates, raises out-of-bag predictability on every target (for example CMS biomass 0.57 to 0.93). Spatially blocked cross-validation confirms the surface generalizes (blocked R squared 0.75 to 0.86 for the level targets). The index resolves microsite productivity that coarse measures discard: about a third of total productivity variance in dissected terrain is at the sub-kilometer scale. The RS-CSPI is independent of inventory site index along a height-versus-flux axis, and where inventory plots exist they localize the surface through small area estimation (blocked prediction of a ground growth index rises from 0.71 to 0.94).

Funding: University of Maine Center for Research on Sustainable Forests. Computation: Ohio Supercomputer Center, allocation PUOM0008.
