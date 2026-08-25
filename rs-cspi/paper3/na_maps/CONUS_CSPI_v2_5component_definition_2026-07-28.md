# The CONUS 30 m CSPI: confirmed five-component definition

*Reference note, 28 July 2026. Written to close defect 1 of the code-versus-disk audit, which is the false claim in `mosaic_na_30m.R` that CONUS has no 30 m CSPI product. Everything below was verified against files on the OSC Cardinal cluster rather than inferred from code.*

**STATUS BANNER, added 25 August 2026, per `cspi-component-count-reconciliation_FINAL_2026-08-19.md`.** The raster inventory below is accurate and verified as written. The title claim is withdrawn. `CSPI_v2_5component_30m.tif` is an experimental surface descended from the retired four-component definition plus the v2.1.0 MOD17 swap, from the `v2both` build line, and it is not the CSPI v2 of record. CSPI v2 of record, per every manuscript draft from v0.10 forward, the composite specification section 3.2, and the verified Cardinal build log (job 11555064, `CSPI_v21_3component_30m.tif`), is the three-component composite z(ESI) + z(BGI) + z(Asym), equal weight, with NPP and FIA SICOND as external validators that never enter the composite. See the reconciliation memo for the full evidence chain. The body text below documents a real object and stands unedited.

## The product exists

`/fs/scratch/PUOM0008/crsfaaron/cspi_v7/v2both/CSPI_v2_5component_30m.tif` is 41,755,385,529 bytes, that is 41.8 GB, dated 8 July 2026. `gdalinfo` reports 212,400 by 90,000 cells on EPSG:4326 at a pixel size of 0.000277778°, spanning −125° to −66° longitude and 24° to 49° latitude, one Float32 band with the description `CSPI_v2_5component` and a value range of 24.864 to 100.000. Two siblings sit beside it: the forest-masked variant `CSPI_v2_5component_30m_forest.tif` at 14.5 GB, and the 1 km aggregate `CSPI_v2_5component_1km.tif` at 42 MB on the same CRS and extent at 0.009166667°, with a range of 25.583 to 100.000.

## The five components

The five are the environmental site index, the biomass growth increment, the asymptotic biomass, the Miami net primary productivity climatology and the MOD17 satellite net primary productivity product. In the project's own naming they are ESI v7, BGI, Asym, MIAMI NPP and MOD17A3HGF NPP.

The evidence is on disk in the same two directories and is unambiguous. `cspi_v7/cspi_v2_aligned/` holds the three aligned component grids `Asym_on_esi_grid.tif` at 37.4 GB, `BGI_on_esi_grid.tif` at 40.3 GB and `NPP_MIAMI_on_esi_grid.tif` at 31.1 GB, all rendered onto the ESI v7 grid, which supplies the fourth component implicitly as the grid itself. `cspi_v7/v2both/` then holds the two productivity grids that distinguish this build from its ancestors: `mia_g.tif` at 40.6 GB, whose band description is `npp_miami_gDM_m2_yr`, and `mod_g.tif` at 50.5 GB, whose band description is `mod17a3hgf_npp_mean_2017_2023`, both at 212,400 by 90,000 on the identical 0.000277778° ESI grid. The directory name `v2both` is literal: it is the v2 composite carrying **both** net primary productivity products rather than one.

The lineage confirms the same reading from the other direction. `cspi_v21_3c_raw.tif` is the three-component build, ESI plus BGI plus Asym. `cspi_4c_raw.tif` is the four-component build, those three plus MIAMI NPP, and `CSPI_v2_1_0_release_plan.md` describes the planned v2.1 patch as swapping MIAMI NPP for MOD17 NPP while leaving ESI v7, BGI and Asym untouched. The five-component product is the build that keeps both rather than choosing, and the plot-level table `cspi_v7/multidim_v2/B3_three_component_composites.csv` carries exactly the columns `esi`, `bgi_v`, `asym_v` and `npp_v` with `c3_*` and `c4_old` composites, which is the same ladder one rung lower.

One point of possible confusion is worth heading off. `cspi_v7/multidim_v2/B1_5measure_correlation.csv` is also a five-way matrix, over ESI, BGI, Asym, NPP and SICOND. That is a *diagnostic* five-measure correlation table in which SICOND, the FIA site index condition variable, appears as an external validator. SICOND is not a component of the CSPI_v2 raster.

## The construction

Each component is z-standardised at the plot level against fixed reference parameters, the five z-scores are averaged with equal weight, a cell is set to missing unless at least three of the five components are present, the mean z is clamped to plus or minus 3, and the result is rescaled to 0 to 100. The authoritative build is `repos/conus-hcs/harvest_model/cspi_full.R`, and `CSPI_v2_1_0_release_plan.md` states the same sequence for the composition step, namely reproject the coarse component onto the ESI 30 m grid by bilinear interpolation, standardise, sigma-clip at plus or minus 3, average with the other components and rescale to 0 to 100. The landed minimum of 24.864 rather than 0 is consistent with a rescale computed over a wider reference range than the forest-domain values that survive.

Two rules in that list are exactly the rules the North American 2 km composite dropped, and they are why the CONUS product is the stronger ancestor: the minimum component count keeps membership from collapsing to one relabelled z-score, and the clamp keeps implausible tails off the map.

## The asymptotic component, and why it matters beyond CONUS

The Asym component is the reason the CONUS product could be built at 30 m at all, and its estimator is documented in `/users/PUOM0008/crsfaaron/FIA/asym_agb_analysis/02_estimate_blups.r`. Aboveground biomass is fitted as a Chapman-Richards function in which **top height, not stand age, is the developmental axis**, relative density enters the asymptote, and the plot-specific asymptote is taken as the best linear unbiased predictor of the plot random effect evaluated at a relative density of 0.60. The landed result, `results/blup_plot_asymptotes.csv`, covers 135,516 FIA plots across 48 states, and a genuine 30 m CONUS Asym surface exists as 2,419 tiles under `results/conus30m_asym_tiles/` with a virtual mosaic.

That specification is directly relevant to the Canadian side. The earlier Canadian attempt at an asymptote was routed through a provisional stand-age layer, and age does not order biomass in the open MAG data, so the fit collapsed onto the observation. The CONUS estimator never needed age. Canada has measured biomass, measured top height and relative density at the plots, so the Canadian asymptote is blocked on a model that was never fitted with the CONUS specification, not on a missing age layer. See `canada_asym_QUARANTINE_2026-07-28.md`.

## Units and grain

CSPI_v2_5component is unitless by construction, an index on a 0 to 100 scale. Its components carry their own units before standardisation: ESI in m as dominant-height site index at base age 50, BGI in Mg ha⁻¹ yr⁻¹, Asym in Mg ha⁻¹, MIAMI NPP in g dry matter m⁻² yr⁻¹, and MOD17A3HGF NPP as the 2017 to 2023 mean on its native scale. The grain is nominal: 0.000277778° of longitude is about 28 m at 24° N and about 20 m at 49° N, so the product is 30 m only in the loose geographic sense. Any North American successor must be declared on an equal-area projection before the word 30 m can be used honestly at Canadian latitudes.

## What this changes in `mosaic_na_30m.R`

The header claim and the `na_cspi30_status` provenance field are corrected, and the script now registers the CONUS product as a first-class input, warps it into the common CSPI CRS as a VRT and offers it to the mosaic. The canonical `NA_CSPI30_30m.vrt` name remains with the Canada surface, but for the correct reason: the two sides are on different definitions, CONUS being a five-component productivity index and the Canada CSPI30 being a z-composite of basal area, top height and relative density. That gate is the `CSPI30_HARMONIZED` switch. See `DEFECT_FIXES_2026-07-28.md`.
