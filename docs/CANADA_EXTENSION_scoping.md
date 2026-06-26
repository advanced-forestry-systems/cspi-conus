# Extending the productivity map into Canada: Cardinal review and phased plan

*25 June 2026. Based on a review of Cardinal scratch and home. The short version: the site-index (ESI) layer can extend into Canada with what is already on disk and downloadable; the biomass-growth (BGI) and asymptotic-biomass (Asym) layers, and therefore the full composite, need Canadian remeasurement data (NFI and provincial PSPs) that is not yet staged.*

## What is already on Cardinal (relevant to Canada)

| Asset | Path | Canada relevance |
|---|---|---|
| NA site-tree compilation (ESI response) | `~/SiteIndex/NA_SITREE.csv` (167 MB) | 1,079,006 site-tree rows, 41,347 plots; **46,993 rows (4.4%) at lat > 49, ~3,890 Canadian-side plots**, lat to 65.6 N, lon to -154 (Alaska). The ESI response is already North America wide. |
| ClimateNA SI grids | `~/SiteIndex/ClimateNA_SI_m.tif`, `ALL_SI_m.csv`, `clim_ranger_spatial_model.rds` | ClimateNA covers all of North America by design; the projected grid extends well north of the border. The climate predictor stack is NA-ready. |
| AlphaEarth embeddings | `/fs/scratch/.../region_full/aef/{ME,NH,VT,NY,MA,NB}` | Coverage already includes **New Brunswick**; AlphaEarth is global, so the rest of Canada is downloadable on the same footing. |
| Soil / terrain | SoilGrids 2.0 (global), SRTM (to 60 N) | Already global or near-global; usable into southern and central Canada, gap above 60 N for SRTM. |

What is NOT on Cardinal: any Canadian NFI ground-plot or provincial PSP remeasurement data. A search for NFI / PSP / CanFI ground data returned nothing.

## Feasibility by layer

**ESI (site index): ready now.** The response already includes Canadian plots and the predictor stack (ClimateNA, SoilGrids, AlphaEarth) is North America wide. An ESI surface can be extended across the border by generating the Canadian predictor rasters and predicting with the existing model. The cleanest first product is an Acadian cross-border ESI (Maine plus the Maritimes / New Brunswick), where AlphaEarth NB tiles, the Canadian NA_SITREE plots, and Aaron's existing NB site-index relationships (Lamb et al. 2020) all line up.

**BGI and Asym: need Canadian remeasurement.** Both are computed from FIA remeasurement and AGB pairs, which stop at the border. The Canadian analogs are the National Forest Inventory (NFI) ground plots (repeated panels) and provincial permanent sample plots (New Brunswick has a strong PSP network used in Lamb et al. 2020). Acquiring and harmonizing remeasured biomass increment from those is the real lift.

**CSPI composite: phase 2.** The composite needs all three components, so a full Canadian composite waits on BGI and Asym from NFI/PSP.

## Recommended phased plan

1. **De-risk first (no new data needed): cross-border ESI transfer test.** Hold out the Canadian (lat > 49) NA_SITREE plots, predict them from the CONUS-trained ESI / ClimateNA model, and report R^2 and RMSE. This answers "does our site-index model generalize north of the border" before any surface is built. Tractable on disk once the climate covariates are sampled at the Canadian plots. This is the natural next analysis and I can run it on autopilot.

2. **Acadian ESI surface (Maine plus New Brunswick).** Generate the predictor rasters for the NB AlphaEarth footprint already on disk plus ClimateNA, and predict ESI across the Maine-Maritimes region as a cross-border pilot. Modest compute; uses staged data.

3. **Acquire Canadian remeasurement for BGI and Asym.** NFI ground-plot data (Canada's NFI is partly open through Natural Resources Canada) and New Brunswick PSPs (provincial agreement; the Lamb et al. relationship is the obvious channel). This is the gating step for the composite and is a data-agreement and harmonization task, not a compute task. Note the same data-protection care that applies to FIA true coordinates applies to PSP locations.

4. **North America composite.** Once Canadian BGI and Asym exist, rebuild the three-component composite across the joined CONUS-plus-Canada extent.

## How this connects to the current paper

The current FEM manuscript is explicitly CONUS and should stay that way for submission; a Canada extension is a strong follow-on paper, not a scope change to the paper in review. Two clean hooks already in the manuscript: the ESI response is described as a unified North America compilation (so the Canadian extension is a natural realization of that framing), and the iBGI / Sentinel-2 and AlphaEarth work is Acadian in origin (Lamb et al. 2020), so a Maine-Maritimes pilot is the coherent first cross-border product. David Diaz and the New Brunswick PSP community are natural collaborators for the NFI side.

## Other manuscript next steps and refinements (independent of Canada)

- When Chuck Barnett returns the NRS site-class break points, complete the exact MAICF reproduction for the eastern states as a supplementary confirmation of the §2.3 / §4.2 mechanism.
- Fire the staged MOD17 NPP-slope increment job when the Cardinal allocation frees (the daily check handles this) and fold the repeat-NPP-trend validation into §3.9.
- Add DOIs to the reference entries that lack them (15 of 22) for final submission.
- After coauthor review, run the simulated-review gate once more on the revised draft.

## Update (25 June): cross-border transfer test launched + a key finding

Ran the source composition of the Canadian-side (lat > 49) plots in the ESI training compilation (`ALL_SI_m.csv`). The Canadian data is not incidental high-latitude FIA; it is dedicated Canadian sources already in the compilation:

| SOURCE | plots (lat > 49) |
|---|---|
| CAN (Canadian national compilation) | 12,793 |
| BC (British Columbia) | 3,469 |
| FIA_AK (Alaska FIA, US) | 4,418 |
| FIA (CONUS spillover) | 8 |

So roughly 16,000 Canadian site-index plots (CAN + BC) are already in the training set with the full ClimateNA covariate stack. This materially de-risks the ESI extension: a Canadian ESI surface is trained-on-Canada, not extrapolated blind. The cross-border transfer test (CONUS-trained model predicting the Canadian plots, vs within-CONUS CV baseline and within-Canada CV ceiling) was submitted (job 12040655); the within-CONUS CV baseline on ~340k plots is the slow step, so the R^2 / RMSE numbers will be written to `CANADA_esi_transfer.csv` and `CANADA_esi_transfer_byband.csv` when it completes.

Implication: because dedicated Canadian sources are already in the compilation, the immediate ESI extension does not even depend on the transfer test passing; the test mainly tells us how far a CONUS-only model would carry vs how much the Canadian plots add. The Acadian (Maine + New Brunswick) ESI pilot is well supported either way.

## Transfer-test result (job 12040655, complete) and the methodological conclusion

| Test | n | R^2 | RMSE (m) |
|---|---|---|---|
| Within-CONUS 5-fold CV (baseline) | 339,558 | 0.785 | 3.73 |
| CONUS-trained -> Canada (transfer) | 20,688 | 0.122 | 12.35 |
| Within-Canada 5-fold CV (ceiling) | 20,688 | 0.850 | 5.11 |

Transfer by Canadian latitude band: R^2 = 0.54 (49-52 N), 0.32 (52-55 N), -2.14 (55-60 N), -7.19 (60+ N).

**Conclusion: do not extrapolate the CONUS model north; train on the full North America compilation.** A CONUS-only model fails into Canada (R^2 = 0.12 overall, strongly negative in the boreal above 55 N) because boreal climate space is outside the CONUS training envelope. But the ~16,000 Canadian plots already in the compilation support a within-Canada model that predicts site index very well (R^2 = 0.85, RMSE 5.1 m). The operational path is therefore to fit ESI on the joint CONUS + Canada compilation (which `ALL_SI_m.csv` already is) and predict Canada from that, not to push the CONUS model across the border. The boreal (> 55 N) is where in-region training matters most and where the existing SRTM gap (> 60 N) and any covariate gaps should be watched.

## Radiation gap (the monthly radiation-and-moisture approach)

Confirmed: no solar-radiation raster is staged on Cardinal and the TerraClimate download scripts do not pull srad. ClimateNA lacks incident shortwave radiation, which is the sticking point for a monthly radiation-and-moisture (light-use-efficiency style) productivity formulation. Concrete fix that uses existing project infrastructure: TerraClimate distributes monthly downward surface shortwave radiation (srad) plus PET and soil moisture at ~4 km, 1958 to present; the project already has TerraClimate download tooling (`scripts/download_terraclimate_conus.r`). Adding the srad (and PET / soil-moisture) bands gives the monthly radiation-and-moisture inputs without a new data source. Higher-resolution alternatives if 4 km is too coarse: gridMET srad (4 km, daily, CONUS only), NASA POWER (0.5 deg, global, monthly), or CERES/MODIS. Terrain-derived potential radiation (heat load index, northness, eastness) is already in the ESI v7 stack but captures topographic insolation, not cloud-corrected incident radiation, so it does not substitute for srad.
