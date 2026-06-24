# Beyond site index: a remote sensing composite site productivity index that resolves microsite variability across the conterminous United States, independent of forest inventory

Aaron R. Weiskittel. University of Maine, Center for Research on Sustainable Forests.

Target journal: Remote Sensing of Environment or Forest Ecology and Management.

## Abstract

Site index is the standard measure of forest productivity, but it is a limitation. It is estimated from sparse, expensive, coordinate-fuzzed inventory plots; it reduces productivity to a single height-growth dimension; and it cannot resolve the high microsite variability that terrain, aspect, drainage, and soil impose on productivity at fine scale. We develop a replacement: an integrated, inventory-independent site productivity index for the conterminous United States that uses remote sensing productivity metrics as the response and a wall-to-wall climate, terrain, soil, and canopy stack as the predictors, with no inventory data in the modeling chain. Four satellite targets spanning carbon flux, structure, and change are each fit from the environmental stack and predicted across all forested cells, then combined into a Remote Sensing Composite Site Productivity Index (RS-CSPI) at 1 km and downscaled to 30 m. Sampling the targets wall to wall rather than at plot coordinates raises out-of-bag predictability substantially (for example biomass from 0.57 to 0.93), and spatially blocked validation confirms the surface generalizes (blocked R-squared 0.75 to 0.86). The index resolves microsite productivity that coarse measures discard: in dissected terrain about a third of total productivity variance is at the sub-kilometer microsite scale, captured by the 30 m surface and invisible to a plot or 1 km measure. The RS-CSPI is not a restatement of site index; the two diverge along a height-versus-flux axis confirmed in both surfaces and plots, because the tallest forests are not the most productive by flux or biomass. Where inventory plots exist, they are not discarded: through small area estimation they localize and sharpen the independent surface, raising blocked prediction of a ground growth index from 0.71 to 0.94. The result is an integrated, microsite-resolving, continuously updatable productivity layer suited to driving growth and yield models and forest management planning.

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

### 3.1 Wall-to-wall sampling beats the inventory plot frame

On the gridded design every target predicts better than at plot coordinates: net primary productivity 0.953 vs 0.919, aboveground biomass density 0.873 vs 0.743, biomass 0.928 vs 0.574, change 0.790 vs 0.512. The structural targets gain most. The plot frame was adding noise, not signal.

### 3.2 Predictor resolution and the augmented stack

At 1 km with climate alone the flux target holds (0.946) but structural targets fall (biomass 0.738); adding terrain, soil, and canopy recovers them (biomass 0.894, aboveground biomass density 0.791). Predictor resolution, not target resolution, sets achievable detail.

### 3.3 Spatially blocked validation

Blocked cross-validation confirms generalization: net primary productivity 0.858, biomass 0.862, aboveground biomass density 0.748, change 0.485, modestly below out-of-bag.

### 3.4 The composite site productivity index

The three level targets combine into a coherent 1 km integrated productivity index with a clear continental gradient. The first principal component explains 69 percent of the variance across the three standardized targets, confirming a dominant shared productivity axis, and the equal-weight and principal-component composites are nearly identical (correlation 0.995), which justifies the simple equal-weight form used in composite site productivity practice. Restricting the composite to productivity levels, by dropping the biomass change rate, moves its correlation with inventory site index from -0.39 to -0.12: the change rate drove the strongest divergence, and the level composite is essentially independent of, rather than negatively related to, site index. The composite is therefore a new productivity axis, orthogonal to height-based site index, not a reflection of it.

### 3.5 Microsite variability resolved

The index resolves productivity variation that a plot or kilometer measure cannot. In dissected terrain (southern Appalachians, 30 m), 31.6 percent of total productivity variance is at the sub-kilometer microsite scale, with a median within-kilometer standard deviation of 0.27 against a full range of 2.2 (standardized units). Roughly a third of the productivity signal lives below the resolution of any plot-based or kilometer-scale site index and is recovered only by the fine-resolution surface.

### 3.6 Site index is the narrower measure

The composite is not a restatement of site index. Overall correlation is weak and negative (around -0.39), positive within every region: a Simpson's paradox. The cause is confirmed at the plot level, where site index correlates -0.38 with net primary productivity and -0.42 with gross primary productivity across 61,655 plots. Site index tracks height growth, highest where conifers grow tallest; flux and biomass peak in the warm wet Southeast and the Pacific Northwest. The tallest forests are not the most productive by flux or biomass, so site index, by measuring height alone, misses the integrated productivity the composite captures.

### 3.7 Inventory plots refine the surface through small area estimation

Where plots exist they sharpen the independent surface. Adding a spatial small area estimation component to the remote sensing signal raises blocked-cross-validation prediction of an inventory growth index from 0.71 to 0.94, and of biomass asymptote from 0.15 to 0.75. Inventory data are not required to build the surface, but they localize it substantially where available.

### 3.8 Thirty-meter downscaling

The composite downscales to 30 m by applying the models over the fine terrain, soil, and canopy stack, resolving ridge and valley structure the kilometer surface blurs.

## 4. Discussion

Forest productivity needs a measure better suited to its nature than site index. The integrated, inventory-independent composite developed here is wall to wall by construction, repeatable as the satellite products update, free of the cost, lag, sparsity, and coordinate fuzzing of the plot network, and, decisively, able to resolve the microsite variability that controls productivity at the scale management actually operates. About a third of productivity variation in dissected terrain is microsite-scale and invisible to a plot-based site index; the fine-resolution composite recovers it.

The divergence from site index clarifies what site index is and is not. It is a height-growth measure, one narrow axis of productivity, estimated at coarse grain. The composite integrates flux and biomass and resolves them to 30 m. For growth and yield modeling and management planning the composite supplies an integrated productivity driver wherever measured height and age are unavailable, which is most of the landscape between remeasurements.

Small area estimation reconciles independence with local accuracy. The base surface needs no plots, but where they exist they fold back in to localize it, and the gain is large, lifting prediction of a ground growth index from 0.71 to 0.94. This points to an operational design: a remote sensing base layer everywhere, sharpened by inventory wherever inventory is dense.

Limitations include predictor-limited resolution, the smoothing inherent in environmental prediction, and dense-grid validation optimism, which the blocked cross-validation bounds. Adding gross primary productivity and an optical greenness target would broaden the flux dimension.

## 5. Conclusions

Treating remote sensing as the response and environment as the predictor yields an integrated, inventory-independent site productivity index for the conterminous United States at 1 km and 30 m that resolves microsite variability a plot-based site index cannot. It predicts its satellite targets strongly under blocked validation, it captures an integrated productivity that site index misses, and it can be locally refined with inventory plots through small area estimation. It is a practical replacement for site index as a productivity driver for growth and yield models and management planning.

## Acknowledgments

Computation was performed at the Ohio Supercomputer Center under allocation PUOM0008. This work was supported by the University of Maine Center for Research on Sustainable Forests.

## Author contributions

A.R.W.: conceptualization, methodology, software, formal analysis, writing, funding acquisition.

## Competing interests

The author declares no competing interests.

## Data and code availability

Trained models, the composite surfaces, and the analysis code are deposited at Zenodo (CSPI v4.0.0), building on the v3.0.0 inventory-target dataset (DOI 10.5281/zenodo.20763197). Source remote sensing products are public: MODIS MOD17 (LP DAAC), GEDI L4B and NASA-CMS (ORNL DAAC), and Sentinel-2 (Copernicus, via Google Earth Engine). Environmental predictors are ClimateNA, SoilGrids 2.0, and the Global Forest Change product.

## References

Note: this reference list is provisional and must pass the CrossRef verification protocol (VERIFIED / NOT_FOUND / MISMATCH) before submission.

Bechtold, W.A., Patterson, P.L. (Eds.), 2005. The enhanced Forest Inventory and Analysis program: national sampling design and estimation procedures. USDA Forest Service General Technical Report SRS-80.

Breiman, L., 2001. Random forests. Machine Learning 45, 5 to 32.

Dubayah, R., et al., 2022. GEDI L4B Gridded Aboveground Biomass Density, Version 2.1. ORNL DAAC, Oak Ridge, Tennessee.

Hansen, M.C., et al., 2013. High-resolution global maps of 21st-century forest cover change. Science 342, 850 to 853.

Poggio, L., et al., 2021. SoilGrids 2.0: producing soil information for the globe with quantified spatial uncertainty. SOIL 7, 217 to 240.

Rao, J.N.K., Molina, I., 2015. Small Area Estimation, 2nd ed. Wiley, Hoboken.

Running, S.W., et al., 2004. A continuous satellite-derived measure of global terrestrial primary production. BioScience 54, 547 to 560.

Running, S.W., Zhao, M., 2021. User's guide: MOD17 daily and annual GPP and NPP, Version 6.1. University of Montana.

Skovsgaard, J.P., Vanclay, J.K., 2008. Forest site productivity: a review of the evolution of dendrometric concepts for even-aged stands. Forestry 81, 13 to 31.

Wang, T., et al., 2016. Locally downscaled and spatially customizable climate data for historical and future periods for North America. PLoS ONE 11, e0156720.

Weiskittel, A.R., et al., 2011. Forest Growth and Yield Modeling. Wiley, Chichester.

Wright, M.N., Ziegler, A., 2017. ranger: a fast implementation of random forests for high dimensional data in C++ and R. Journal of Statistical Software 77, 1 to 17.
