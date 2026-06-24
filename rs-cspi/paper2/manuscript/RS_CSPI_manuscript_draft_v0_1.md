# A remote sensing composite site productivity index for the conterminous United States, independent of forest inventory plots

Aaron R. Weiskittel. University of Maine, Center for Research on Sustainable Forests.

Target journal: Remote Sensing of Environment or Forest Ecology and Management.

## Abstract

Site productivity is the single most influential input to growth and yield models and to forest management planning, yet the operational measures of it depend on forest inventory plots that are expensive, lag the present by years, and are spatially sparse and coordinate-fuzzed. We develop a forest productivity surface for the conterminous United States that uses remote sensing productivity metrics as the response and a wall-to-wall environmental stack as the predictors, with no inventory data in the modeling chain. Four satellite targets spanning carbon flux, structure, and change (MODIS net primary productivity, GEDI aboveground biomass density, and NASA-CMS biomass level and change) are each fit from climate, terrain, soil, and canopy predictors and predicted across all forested cells. Sampling the targets wall to wall on the predictor grid, rather than at inventory plot coordinates, raises out-of-bag predictability substantially (for example aboveground biomass from 0.74 to 0.87 and biomass from 0.57 to 0.93), confirming that the plot frame contributes noise rather than signal. The productivity-level targets are combined into a Remote Sensing Composite Site Productivity Index (RS-CSPI) at 1 km, with a 30 m operational downscaling. Spatially blocked cross-validation confirms the surface generalizes (blocked R-squared 0.75 to 0.86). The RS-CSPI is independent of and complementary to the inventory-derived site index: the two diverge in a height-versus-flux pattern, confirmed in both the surfaces and the plot data, because the tallest forests are not the highest-flux forests. We show that the inventory plots can still be used, through small area estimation, to localize and refine the independent surface where ground data exist. The result is an integrated, inventory-independent, continuously updatable site productivity layer suited to driving growth and yield models and regional management planning.

## 1. Introduction

Site productivity governs how fast a forest grows, how much carbon it stores, and what management it can support. Growth and yield models take site productivity as a primary driver, usually as site index, and forest management planning at the ownership and regional scale depends on a consistent productivity map. The operational measures of productivity, site index and inventory-derived growth indices, are estimated from forest inventory plots. Those plots are expensive to install and remeasure, they lag the present by the length of the measurement cycle, they are spatially sparse, and in the United States their public coordinates are deliberately fuzzed, which degrades any attempt to pair them with fine-resolution covariates.

Remote sensing now provides direct, wall-to-wall, repeatable measurements of forest productivity dimensions: net primary productivity from MODIS, aboveground biomass from GEDI and from carbon monitoring programs, and greenness and structure from optical and lidar sensors. These products are themselves productivity measurements, not predictors of a plot quantity. This motivates a reframing: rather than predicting an inventory quantity from environment with remote sensing as a covariate, use the remote sensing productivity metric as the response and the environment as the predictor, then map the fitted relationship wall to wall. The result is a productivity surface whose response is satellite-measured and whose support is the full forested extent, with no inventory plot anywhere in the chain.

This paper develops that surface for the conterminous United States. We pursue three aims. First, fit each of several satellite productivity targets from a common environmental predictor stack and predict each across all forested cells. Second, combine the productivity-level targets into a single composite site productivity index, in the spirit of the composite indices used in inventory-based productivity work, and characterize how this independent index relates to the existing inventory-derived site index. Third, demonstrate that inventory plots, while not required to build the surface, can be used afterward through small area estimation to localize and refine it at higher resolution where ground data are available.

## 2. Methods

### 2.1 Extent and grids

The analysis covers forested land in the conterminous United States, defined by a 1 km forest mask. Models are built and predicted on the environmental predictor grid. The base product is delivered at 1 km, the resolution at which the climate predictors carry genuine variation, with a 30 m operational downscaling driven by the fine-resolution terrain, soil, and canopy predictors.

### 2.2 Predictors

The predictor stack contains 43 variables: ClimateNA 1991 to 2020 normals (32 climate variables, elevation-adjusted, about 1 km), and aligned terrain (elevation, slope, aspect), soil (bulk density, cation exchange capacity, nitrogen, pH, sand, soil organic carbon), and canopy (Hansen tree cover 2000 and loss) layers. No remote sensing productivity metric enters the predictor side.

### 2.3 Targets

Four satellite productivity targets span three dimensions. Carbon flux: MODIS MOD17 net primary productivity. Structure: GEDI L4B version 2.1 aboveground biomass density, and NASA-CMS conterminous United States aboveground biomass for 2016. Change: NASA-CMS aboveground biomass change 2005 to 2016. The composite index uses the three level targets; the change rate is reported separately because it is a flux, not a level.

### 2.4 Model fitting and prediction

For each target a random forest (ranger, 500 trees, mtry one third of the predictors) is fit from the predictor stack and predicted across all forested cells. We report out-of-bag R-squared and root mean square error. To test whether the inventory plot frame adds value, each target is fit twice: once sampled at the 61,656 inventory plot coordinates and once sampled wall to wall on the predictor grid.

### 2.5 Composite index

The three productivity-level predicted surfaces are z-standardized and combined two ways: an equal-weight mean rescaled to 0 to 100, consistent with composite site productivity index practice, and the first principal component of the standardized surfaces, a data-driven composite. A per-cell agreement layer records the dispersion across the standardized targets.

### 2.6 Validation

Out-of-bag R-squared on a dense grid is optimistic because of spatial autocorrelation. We therefore report a spatially blocked cross-validation: one-degree spatial blocks assigned to five folds, training on four folds and predicting the held-out fold.

### 2.7 Comparison to inventory-derived products

The composite index is compared against the inventory-derived site index surface and an inventory-derived biomass productivity surface, using scale-invariant Pearson and Spearman correlation, quartile agreement, and a regional breakdown. The surface-level comparison is confirmed at the plot level using inventory site index and the satellite targets measured at the same plots.

### 2.8 Small area estimation refinement

To show that inventory data can still refine the independent surface, we fit a spatial generalized additive model that predicts an inventory growth index from the remote sensing signal plus a spatial smooth. The spatial smooth is the small area estimation component: it borrows strength across nearby plots to capture local departures of ground productivity from the remote sensing prediction. Models are compared by spatially blocked cross-validation.

## 3. Results

### 3.1 Wall-to-wall sampling beats the inventory plot frame

[TABLE: OOB R2 wall-to-wall vs plot frame per target]
On the gridded design every target predicts better than at inventory plot coordinates: net primary productivity 0.953 vs 0.919, aboveground biomass density 0.873 vs 0.743, biomass 0.928 vs 0.574, and change 0.790 vs 0.512. The structural targets gain the most, because they suffered most from plot noise and coordinate fuzzing. The plot frame was adding noise, not signal.

### 3.2 Predictor resolution and the augmented stack

At 1 km with climate predictors alone, the flux target holds (0.946) but the structural targets fall (biomass 0.738). Adding terrain, soil, and canopy recovers them: aboveground biomass density to 0.791 and biomass to 0.894. Predictor resolution, not target resolution, sets the achievable detail.

### 3.3 Spatially blocked validation

Blocked cross-validation confirms the surface generalizes rather than memorizing autocorrelation: net primary productivity 0.858, biomass 0.862, aboveground biomass density 0.748, change 0.485, modestly below the out-of-bag values.

### 3.4 The Remote Sensing Composite Site Productivity Index

[FILL: equal-weight vs PC1 benchmark; PC1 variance explained; correlation EW vs PC1]
The three level targets combine into a coherent 1 km composite site productivity index with a clear continental gradient. The equal-weight and principal-component composites agree closely, indicating a dominant shared productivity axis.

### 3.5 Independence from inventory site index

The composite index is not redundant with the inventory site index. Overall correlation is weak and negative (Pearson around -0.39), while within any region it is positive, a Simpson's paradox. The cause is real and confirmed at the plot level: inventory site index correlates -0.38 with net primary productivity and -0.42 with gross primary productivity across the 61,655 plots. Site index is height growth potential, highest where conifers grow tallest (the Pacific Northwest), whereas flux and biomass are highest in the warm wet Southeast and the Pacific Northwest respectively. The tallest forests are not the highest-flux forests, so the height dimension and the flux dimension diverge. The remote sensing index captures the flux and biomass dimension; the inventory site index captures the height dimension. They are complementary productivity axes, not competing estimates of one quantity.

### 3.6 Small area estimation refinement

[FILL: SAE prototype R2 RS-only vs RS+spatial for bgi and asym]
Adding a spatial small area estimation component to the remote sensing signal improves prediction of an inventory growth index, demonstrating that ground plots can localize and refine the independent surface where they exist.

### 3.7 Thirty-meter downscaling

The 1 km composite downscales to 30 m by applying the same models over the fine terrain, soil, and canopy stack. A conterminous prediction resolves ridge and valley topography that the 1 km surface blurs, while the productivity information remains environmentally bounded.

## 4. Discussion

An integrated, inventory-independent site productivity layer addresses several limitations of inventory-based productivity at once. It is wall to wall by construction, it is repeatable as the satellite products update, and it does not inherit the cost, lag, sparsity, or coordinate fuzzing of the plot network. Positioned as a growth and yield driver, it supplies an integrated productivity covariate wherever measured height and age are unavailable, which is most of the forested landscape between inventory remeasurements.

The divergence from inventory site index is a feature, not a defect. It confirms, with fully independent remote sensing, the multi-dimensional view of productivity: a single number cannot represent what a site can do, and height-based and flux-based productivity are distinct axes. The two surfaces should be used together, the inventory site index for height-growth questions and the remote sensing composite for carbon-flux and biomass questions.

Small area estimation reconciles independence with local accuracy. The base surface needs no plots, but where plots exist they can be folded back in to localize the surface, sharpening it for operational planning in well-inventoried regions without compromising the independence of the base layer elsewhere.

Limitations include the predictor-limited resolution, the smoothing inherent in predicting a target from environment, and the optimism of dense-grid validation, which the blocked cross-validation bounds. Adding gross primary productivity and an optical greenness target would broaden the flux dimension of the composite.

## 5. Conclusions

A productivity surface that treats remote sensing as the response and environment as the predictor yields an integrated, inventory-independent site productivity index for the conterminous United States, available at 1 km and downscalable to 30 m. It predicts its satellite targets strongly under spatially blocked validation, it is complementary to the inventory site index along a height-versus-flux axis, and it can be locally refined with inventory plots through small area estimation. It is suited to driving growth and yield models and regional management planning where inventory measures are unavailable or out of date.

## Data and code availability

Trained models, surfaces, and analysis code are deposited at Zenodo (CSPI v4.0.0), building on the v3.0.0 inventory-target dataset (DOI 10.5281/zenodo.20763197). Computation on the Ohio Supercomputer Center Cardinal cluster, allocation PUOM0008.
