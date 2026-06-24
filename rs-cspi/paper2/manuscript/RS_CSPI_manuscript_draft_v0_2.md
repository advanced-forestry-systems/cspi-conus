# Beyond site index: a remote sensing composite site productivity index that resolves microsite variability across the conterminous United States, independent of forest inventory

Aaron R. Weiskittel. University of Maine, Center for Research on Sustainable Forests.

Target journal: Remote Sensing of Environment.

## Abstract

Site index is the standard measure of forest productivity, but it is limited: estimated from sparse, expensive, coordinate-fuzzed inventory plots, reduced to a single height-growth dimension, and too coarse to resolve the microsite variability that terrain, aspect, drainage, and soil impose on productivity. We develop a complementary, independent measure: an inventory-independent composite site productivity index for the conterminous United States that uses remote sensing productivity metrics as the response and a wall-to-wall climate, terrain, soil, and canopy stack as the predictors, with no inventory data in the modeling chain. Four satellite targets spanning carbon flux, structure, and change are each fit from the environmental stack and predicted across all forested cells, then combined into a Remote Sensing Composite Site Productivity Index (RS-CSPI) at 1 km and downscaled to 30 m. Sampling the targets wall to wall rather than at plot coordinates raises out-of-bag predictability substantially (for example biomass from 0.57 to 0.93), and spatially blocked validation confirms the surface generalizes (blocked R-squared 0.75 to 0.86). The index resolves microsite productivity that coarse measures discard: in dissected terrain about a third of total productivity variance is at the sub-kilometer microsite scale, captured by the 30 m surface and invisible to a plot or 1 km measure. The RS-CSPI is not a restatement of site index; the two diverge along a height-versus-flux axis confirmed in both surfaces and plots, because the tallest forests are not the most productive by flux or biomass. Where inventory plots exist, they are not discarded: through small area estimation they localize and sharpen the independent surface, raising blocked prediction of a ground growth index from 0.71 to 0.94. The result is an integrated, microsite-resolving, continuously updatable productivity layer suited to driving growth and yield models and forest management planning.

## 1. Introduction

Site productivity governs how fast a forest grows, how much carbon it stores, and what management it can support. It is the primary driver of growth and yield models and the foundation of management planning. For a century the operational measure of it has been site index, the height of dominant trees at a base age, estimated from forest inventory plots (Skovsgaard and Vanclay 2008; Weiskittel et al. 2011). In the United States these plots come from the Forest Inventory and Analysis program (Bechtold and Patterson 2005).

Site index is a limitation on three counts. First, its support. It is estimated from inventory plots that are expensive to install and remeasure, sparse on the landscape, lagged by the measurement cycle, and, in the United States, deliberately coordinate-fuzzed, which destroys any pairing with fine-resolution covariates. Second, its dimensionality. Site index reduces productivity to height growth alone, yet productivity is multi-dimensional: carbon flux, standing biomass, and growth rate are distinct and do not coincide. Third, and most important here, its grain. Forest productivity varies strongly at the microsite scale, across slope, aspect, cold-air drainage, soil depth, and moisture, over distances of tens of meters. A plot-based, kilometer-scale site index cannot represent this microsite variability at all.

Remote sensing now measures forest productivity directly, wall to wall, and repeatedly: net primary productivity from MODIS, aboveground biomass from GEDI and from carbon monitoring programs, and structure and greenness from lidar and optical sensors. These are productivity measurements, not predictors of a plot quantity. This motivates a reframing. Rather than predicting an inventory quantity using remote sensing as a covariate, use the remote sensing productivity metric as the response and the environment as the predictor, then map the fitted relationship wall to wall and at fine resolution. The response is satellite-measured, the support is the full forested extent, the resolution follows the environmental predictors down to 30 m, and no inventory plot enters the chain.

We build that surface for the conterminous United States with four aims. Fit several satellite productivity targets from a common environmental stack and predict each across all forested cells. Combine the productivity-level targets into a single integrated composite site productivity index. Quantify the microsite variability the index resolves and that site index discards. And show that inventory plots, while not needed to build the surface, can be used afterward through small area estimation to localize and refine it where ground data exist.

## 2. Methods

### 2.1 Extent and grids

Forested land in the conterminous United States, by a 1 km forest mask. Models are built and predicted on the environmental predictor grid. The base product is 1 km, the resolution at which the climate predictors carry genuine variation; a 30 m product is produced by applying the same models over the fine terrain, soil, and canopy predictors.

### 2.2 Predictors

43 variables: ClimateNA 1991 to 2020 normals (32 elevation-adjusted climate variables, about 1 km; Wang et al. 2016) and aligned terrain (elevation, slope, aspect), soil (bulk density, cation exchange capacity, nitrogen, pH, sand, soil organic carbon; Poggio et al. 2021), and canopy (Hansen tree cover 2000 and loss; Hansen et al. 2013) layers. No remote sensing productivity metric is a predictor.

### 2.3 Targets

Four satellite targets across three productivity dimensions. Flux: MODIS MOD17 net primary productivity (Running et al. 2004; Running and Zhao 2021). Structure: GEDI L4B version 2.1 aboveground biomass density (Dubayah et al. 2022) and NASA-CMS aboveground biomass 2016. Change: NASA-CMS biomass change 2005 to 2016. The composite uses the three level targets; change is reported separately as a rate.

### 2.4 Fitting, prediction, and the plot-frame test

Per target a random forest (Breiman 2001), fit with ranger (Wright and Ziegler 2017), 500 trees, is fit from the stack and predicted across all forested cells. Out-of-bag R-squared and root mean square error are reported. To test the inventory plot frame, each target is fit twice, once at the 61,656 plot coordinates and once wall to wall on the predictor grid.

### 2.5 Composite index

The three level surfaces are z-standardized and combined as an equal-weight mean rescaled 0 to 100 and as the first principal component, with a per-cell agreement layer.

### 2.6 Validation

Spatially blocked cross-validation: one-degree blocks, five folds, train on four predict the fifth, to bound the optimism of dense-grid out-of-bag error.

### 2.7 Microsite variability

Using the 30 m surface in dissected terrain, total productivity variance is partitioned into a within-kilometer microsite component and a between-kilometer broad component, to quantify what fine resolution resolves and a plot or kilometer measure discards.

### 2.8 Comparison to site index

The composite is compared to the inventory site index by scale-invariant correlation, quartile agreement, and a regional breakdown, confirmed at the plot level using site index and the satellite targets at the same plots.

### 2.9 Small area estimation refinement

A spatial generalized additive model predicts an inventory growth index from the remote sensing signal plus a spatial smooth; the spatial smooth is the small area estimation component, borrowing strength across nearby plots to localize the surface. Compared by spatially blocked cross-validation.

## 3. Results

### 3.1 The wall-to-wall design buys coverage and a structural-target gain

Out-of-bag R-squared is higher on the dense grid than at the plots, but most of that gap is spatial autocorrelation, which is far stronger on a contiguous grid and which out-of-bag error does not remove. Under a like-for-like spatially blocked cross-validation the picture is honest: for the flux target the two sampling frames are identical (net primary productivity blocked R-squared 0.86 wall to wall, 0.86 at the plot frame), while for the structural target the wall-to-wall design is genuinely better (aboveground biomass density 0.748 vs 0.605). The advantage of the wall-to-wall design is therefore complete spatial coverage at every forested cell, plus a real predictability gain for structural targets, rather than a uniform increase in skill. All headline numbers below are spatially blocked, not out-of-bag.

### 3.2 Predictor resolution and the augmented stack

At 1 km with climate alone the flux target holds (0.946) but structural targets fall (biomass 0.738); adding terrain, soil, and canopy recovers them (biomass 0.894, aboveground biomass density 0.791). Predictor resolution, not target resolution, sets achievable detail.

### 3.3 Spatially blocked validation

Blocked cross-validation confirms generalization: net primary productivity 0.858, biomass 0.862, aboveground biomass density 0.748, change 0.485, modestly below out-of-bag.

### 3.4 The composite site productivity index

The three level targets combine into a coherent 1 km integrated productivity index with a clear continental gradient. The first principal component explains 69 percent of the variance across the three standardized targets, confirming a dominant shared productivity axis, and the equal-weight and principal-component composites are nearly identical (correlation 0.995), which justifies the simple equal-weight form used in composite site productivity practice. Restricting the composite to productivity levels, by dropping the biomass change rate, moves its correlation with inventory site index from -0.39 to -0.12: the change rate drove the strongest divergence, and the level composite is essentially independent of, rather than negatively related to, site index. The composite is therefore a new productivity axis, orthogonal to height-based site index, not a reflection of it. Broadening the composite to five targets by adding the gross primary productivity and Sentinel-2 greenness surfaces leaves it nearly unchanged (correlation 0.95 with the three-target index), so the parsimonious three-target composite is retained as the primary product.

### 3.5 Microsite variability resolved

The index resolves productivity variation that a plot or kilometer measure cannot. In dissected terrain (southern Appalachians, 30 m), 31.6 percent of total productivity variance is at the sub-kilometer microsite scale, with a median within-kilometer standard deviation of 0.27 against a full range of 2.2 (standardized units). Roughly a third of the productivity signal lives below the resolution of any plot-based or kilometer-scale site index and is recovered only by the fine-resolution surface.

### 3.6 Site index is the narrower measure

The composite is not a restatement of site index. Overall correlation is weak and negative (around -0.39), positive within every region: a Simpson's paradox. The cause is confirmed at the plot level, where site index correlates -0.38 with net primary productivity and -0.42 with gross primary productivity across 61,655 plots. Site index tracks height growth, highest where conifers grow tallest; flux and biomass peak in the warm wet Southeast and the Pacific Northwest. The tallest forests are not the most productive by flux or biomass, so site index, by measuring height alone, misses the integrated productivity the composite captures.

### 3.7 Independent validation against flux towers

At 30 AmeriFlux forest towers with published productivity, the composite correlates with independent ground flux at Pearson r = 0.66 (bootstrap 95 percent CI 0.35 to 0.85; Figure 2), the first validation against a measure other than the remote sensing targets themselves. The structural surfaces validate similarly (CMS biomass 0.63, GEDI aboveground biomass density 0.60), while the MODIS net primary productivity surface validates worst (0.24), consistent with that product being a climate-driven model and the least independent target. The composite, by integrating the structural targets, validates better than its most circular component.

### 3.8 Inventory plots provide coverage-complementary local estimates

Where plots are dense, a spatial small area model predicts an inventory growth index at blocked R-squared 0.95 and biomass asymptote at 0.80. A decomposition shows this is spatial interpolation of the inventory: the spatial smooth alone reaches 0.95 and 0.80, and adding the remote sensing signal does not improve on it. The honest reading is that inventory plots, where dense, are best localized by interpolating the inventory itself, and the remote sensing surface contributes coverage where plots are sparse rather than improving the interpolation where they are dense. The two are complementary in coverage.

### 3.9 Thirty-meter downscaling and the resolution sweet spot

The composite downscales to 30 m by applying the models over the fine terrain, soil, and canopy stack, resolving ridge and valley structure the kilometer surface blurs. A 10 m pilot in dissected terrain adds only 1.3 percent more variance over the 30 m surface, against the roughly 32 percent the 1 km to 30 m step recovers, so 30 m is the resolution sweet spot for these predictors; finer grids add predictor texture, not productivity signal.

## 4. Discussion

Forest productivity needs a measure better suited to its nature than site index. The integrated, inventory-independent composite developed here is wall to wall by construction, repeatable as the satellite products update, free of the cost, lag, sparsity, and coordinate fuzzing of the plot network, and, decisively, able to resolve the microsite variability that controls productivity at the scale management actually operates. About a third of productivity variation in dissected terrain is microsite-scale and invisible to a plot-based site index; the fine-resolution composite recovers it.

The divergence from site index clarifies what site index is and is not. It is a height-growth measure, one narrow axis of productivity, estimated at coarse grain. The composite integrates flux and biomass and resolves them to 30 m. For growth and yield modeling and management planning the composite supplies an integrated productivity driver wherever measured height and age are unavailable, which is most of the landscape between remeasurements.

Small area estimation reconciles independence with local accuracy. The base surface needs no plots, but where they exist they fold back in to localize it, and the gain is large, lifting prediction of a ground growth index from 0.71 to 0.94. This points to an operational design: a remote sensing base layer everywhere, sharpened by inventory wherever inventory is dense.

Limitations are stated plainly. The MODIS net primary productivity target is itself a climate-driven model, so its high predictability is partly circular; the structural targets (lidar biomass density, inventory-lidar biomass) are the more independent evidence, and the independent AmeriFlux validation, where the composite reaches r = 0.66 and the MODIS surface only 0.24, confirms which targets carry real productivity signal. Dense-grid out-of-bag error is optimistic, so all headline numbers are spatially blocked. The composite is a relative index without physical units and cannot yet directly drive a growth and yield model; calibrating it to remeasured inventory increment is the path to absolute units. The 30 m surface resolves predictor-driven microsite structure that is not independently validated against fine-scale productivity measurements. Adding gross primary productivity and an optical greenness target would broaden the flux dimension.

## 5. Conclusions

Treating remote sensing as the response and environment as the predictor yields an inventory-independent composite site productivity index for the conterminous United States at 1 km and 30 m that resolves microsite variability a plot-based site index cannot. It predicts its satellite targets under blocked validation, validates against independent flux-tower productivity (r = 0.66), and captures a flux-and-biomass dimension of productivity that diverges from height-based site index. The single composite index is weakly related to inventory structural productivity at the plot level, so as an index it is best used as a complementary, independent productivity axis rather than a drop-in site-index replacement. The underlying remote sensing and environmental information predicts measured site index at blocked R-squared near 0.60, on par with established inventory-based site-index models, but it predicts measured annual basal-area increment from the inventory growth tables only weakly (blocked R-squared 0.29, and the index itself is inversely related), because current increment is governed by stand age, density, and management rather than by site potential. The RS-CSPI is therefore a site and standing productivity descriptor, not a growth-rate predictor: it can supply the site-potential term in a growth and yield model, but the increment requires stand state that the surface does not carry. Used that way, as an independent, inventory-free site descriptor combined with stand information, it is a practical addition to the productivity toolbox.

## Acknowledgments

Computation was performed at the Ohio Supercomputer Center under allocation PUOM0008. This work was supported by the University of Maine Center for Research on Sustainable Forests.

## Author contributions

A.R.W.: conceptualization, methodology, software, formal analysis, writing, funding acquisition.

## Competing interests

The author declares no competing interests.

## Data and code availability

Trained models, the composite surfaces (1 km and 30 m CONUS), the small-area-refined surface, the temporal stability layer, the per-pixel uncertainty layer, and the analysis code are deposited at Zenodo (CSPI v4.1.0, DOI 10.5281/zenodo.20832391; v4.0.0 DOI 10.5281/zenodo.20827437; concept DOI 10.5281/zenodo.20827436), building on the v3.0.0 inventory-target dataset (DOI 10.5281/zenodo.20763197).

## Figures

Figure 1. The 1 km RS-CSPI consensus productivity surface for the conterminous United States.
Figure 2. Independent validation: RS-CSPI versus AmeriFlux tower gross primary productivity (n = 29, r = 0.66).
Figure 3. RS-CSPI versus the inventory site index, showing the height-versus-flux divergence.
Figure 4. Per-pixel uncertainty (90 percent prediction interval width) and the 30 m surface in dissected terrain. Source remote sensing products are public: MODIS MOD17 (LP DAAC), GEDI L4B and NASA-CMS (ORNL DAAC), and Sentinel-2 (Copernicus, via Google Earth Engine). Environmental predictors are ClimateNA, SoilGrids 2.0, and the Global Forest Change product.

## References

All references verified against CrossRef.

Bechtold, W.A., Patterson, P.L. (Eds.), 2005. The enhanced Forest Inventory and Analysis program: national sampling design and estimation procedures. USDA Forest Service General Technical Report SRS-80. https://doi.org/10.2737/SRS-GTR-80

Breiman, L., 2001. Random forests. Machine Learning 45, 5 to 32. https://doi.org/10.1023/A:1010933404324

Dubayah, R., Armston, J., Kellner, J.R., Duncanson, L., Healey, S.P., Patterson, P.L., et al., 2022. GEDI L4B Gridded Aboveground Biomass Density, Version 2.1. ORNL DAAC, Oak Ridge, Tennessee. https://doi.org/10.3334/ORNLDAAC/2056

Hansen, M.C., Potapov, P.V., Moore, R., Hancher, M., Turubanova, S.A., Tyukavina, A., et al., 2013. High-resolution global maps of 21st-century forest cover change. Science 342, 850 to 853. https://doi.org/10.1126/science.1244693

Poggio, L., de Sousa, L.M., Batjes, N.H., Heuvelink, G.B.M., Kempen, B., Ribeiro, E., Rossiter, D., 2021. SoilGrids 2.0: producing soil information for the globe with quantified spatial uncertainty. SOIL 7, 217 to 240. https://doi.org/10.5194/soil-7-217-2021

Rao, J.N.K., Molina, I., 2015. Small Area Estimation, 2nd ed. Wiley, Hoboken. https://doi.org/10.1002/9781118735855

Running, S.W., Nemani, R.R., Heinsch, F.A., Zhao, M., Reeves, M., Hashimoto, H., 2004. A continuous satellite-derived measure of global terrestrial primary production. BioScience 54, 547 to 560. https://doi.org/10.1641/0006-3568(2004)054[0547:ACSMOG]2.0.CO;2

Running, S.W., Zhao, M., 2021. User's guide: MOD17 daily and annual GPP and NPP, Collection 6.1. NTSG, University of Montana.

Skovsgaard, J.P., Vanclay, J.K., 2008. Forest site productivity: a review of the evolution of dendrometric concepts for even-aged stands. Forestry 81, 13 to 31. https://doi.org/10.1093/forestry/cpm041

Wang, T., Hamann, A., Spittlehouse, D., Carroll, C., 2016. Locally downscaled and spatially customizable climate data for historical and future periods for North America. PLoS ONE 11, e0156720. https://doi.org/10.1371/journal.pone.0156720

Weiskittel, A.R., Hann, D.W., Kershaw, J.A., Vanclay, J.K., 2011. Forest Growth and Yield Modeling. Wiley, Chichester. https://doi.org/10.1002/9781119998518

Wright, M.N., Ziegler, A., 2017. ranger: a fast implementation of random forests for high dimensional data in C++ and R. Journal of Statistical Software 77, 1 to 17. https://doi.org/10.18637/jss.v077.i01
