# The Forest Service's own productivity classification disagrees with site index, new UMaine analysis shows

*Draft news article for crsf.umaine.edu, approximately 650 words. Target audience: extension partners, state agencies, NGO collaborators, agency staff.*

---

For nearly a century, U.S. foresters have used site index, the expected height of a dominant tree at a reference age, as the standard way to rank how productive a forest stand is. New research from the Center for Research on Sustainable Forests (CRSF) at the University of Maine finds that the Forest Service's own seven-class site productivity rating, the operational classification used in U.S. forest assessment since the 1950s, agrees more closely with how fast a stand is accumulating biomass right now than with its expected dominant tree height at a reference age.

The result emerges from one of the largest comparisons of forest productivity measures ever attempted: four productivity quantities computed at the same 66,000 plus FIA Phase 2 plots covering the conterminous United States, then joined to the Forest Service's own seven-class classification (SITECLCD) and stand context tables.

"Site index is one of the most widely used quantities in American forestry, but it is not the only signal of how a site performs, and the federal classification system that practitioners have been using to rank productivity has been responding to biomass growth all along, not to height growth potential," said Aaron Weiskittel, Irving Chair of Forest Ecosystem Management at UMaine and director of CRSF, who led the analysis.

The team computed four productivity measures at each plot: a unified-target site index trained on a continental compilation of height-and-age records, the annual biomass growth increment from FIA remeasurement pairs, the asymptotic biomass implied by a Chapman-Richards growth model, and net primary production from MODIS satellite data. They then tested how well each measure could be used to predict the Forest Service's seven-class classification. Biomass growth increment alone reached a cross-validated R squared of 0.808; site index alone reached only 0.751. A six percentage point gap that the field has been absorbing into the response variable for seventy years.

The pattern is even clearer when one looks at the seven classes directly. Mean site index is essentially flat across the productivity rating, with values of 30.6 meters at the most productive class and 29.6 meters at the least productive class. Mean biomass growth drops from 2.11 to 0.92 megagrams per hectare per year across the same classes, a factor of 2.3.

"What this tells us is that the federal classification system that practitioners have been using to rank productivity has been responding to biomass growth all along," Weiskittel said. "Site index captures one productivity dimension. The biomass growth measurement captures a different one. The Forest Service's classification has been quietly tracking the second of these for almost seven decades."

The team also found that the correlation between site index and biomass growth depends strongly on stand age, on species, and on ecological region. In middle-age stands (60 to 80 years old), plots with tall trees for their age tend to be slower-accumulating plots right now, with a correlation of negative 0.57. In old-growth stands past 120 years, the relationship flips: the tallest stands are also the ones still accumulating biomass fastest, with a correlation of positive 0.33. The species-level correlation ranges from nearly zero in yellow-poplar to almost 0.5 in Douglas-fir. A national productivity ranking that uses any single measure implicitly assumes one relationship across all these contexts, and the data show that one relationship does not hold.

To make the multi-dimensional view operational, the team has released the Composite Site Productivity Index (CSPI) version 2.0.0 as a 30-meter gridded dataset covering the conterminous United States. The release includes the composite plus the four component layers as standalone files, so that researchers and practitioners can either use the composite for general productivity ranking or pick the component that best fits their application. The data are openly available through Zenodo under a Creative Commons license. A manuscript reporting the findings has been prepared for submission to the journal Forest Ecology and Management.

"This is not a statement that site index has been wrong," Weiskittel said. "Site index works well within a narrow envelope. What we now show empirically is that outside that envelope, the relationship between site index and the productivity dimensions practitioners actually care about is unstable. The choice of productivity measure now depends on what you are trying to do. We have given the field the data to make that choice deliberately rather than by tradition."

The pipeline that produced CSPI v2 ran on the Ohio Supercomputer Center Cardinal cluster and is documented at https://github.com/holoros/fvs-conus. The work was supported by the USDA National Institute of Food and Agriculture, McIntire-Stennis Forestry Research Program (Maine Agricultural and Forest Experiment Station), with supplemental support from the University of Maine.

---

*Contact: Aaron Weiskittel, aaron.weiskittel@maine.edu, 207-581-2851. Photos and accompanying figures available at the CSPI Zenodo deposit.*
