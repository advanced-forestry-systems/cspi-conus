# Press release — DRAFT for UMaine Communications review

*Revised 14 June 2026 after v0.10b correction. The SICOND orthogonality framing in the earlier draft was found to be a base-age Simpson paradox; the SITECLCD finding is the robust headline and is rhetorically stronger.*

**FOR IMMEDIATE RELEASE**

**Date:** [PLACEHOLDER — coordinate with UMaine Communications]
**Contact:** Aaron R. Weiskittel, Center for Research on Sustainable Forests, University of Maine, 207-581-2851, aaron.weiskittel@maine.edu

---

## UMaine forestry research finds the Forest Service's own productivity classification has been tracking biomass growth more closely than site index

**Orono, ME** — For most of the past century, U.S. foresters have relied on a single measurement called site index to rank how productive a stand of trees is. Site index expresses height growth potential as the expected dominant tree height at a reference age. A new study from the University of Maine's Center for Research on Sustainable Forests (CRSF), conducted across 66,000 plus federal forest inventory plots covering the conterminous United States, shows that the Forest Service's own seven-class site productivity classification, used since the 1950s, agrees more closely with biomass growth than with site index.

The research, led by Aaron Weiskittel, Irving Chair of Forest Ecosystem Management at UMaine and director of CRSF, computed four operationally distinct productivity measures at each of the 66,000 plus plots: a unified-target site index trained on a continental compilation of height-and-age records, biomass growth increment from FIA remeasurement pairs, asymptotic biomass implied by a Chapman-Richards growth model, and net primary production from MODIS satellite data. The team then tested how well each measure could be used to predict the Forest Service's seven-class classification using a random forest.

Biomass growth increment alone reached a cross-validated R squared of 0.808. Site index alone reached only 0.751. A six percentage point gap that the field has been absorbing into the response variable for seventy years.

The pattern is clearest when one looks at the seven classes directly. Mean site index is essentially flat across the productivity rating, with values of 30.6 meters at the most productive class and 29.6 meters at the least productive class. Mean biomass growth drops from 2.11 to 0.92 megagrams per hectare per year across the same classes, a factor of 2.3 decline.

"What this tells us is that the federal classification system that practitioners have been using to rank productivity has been responding to biomass growth all along, not to height growth potential," Weiskittel said. "Site index captures one productivity dimension. Biomass growth captures a different one. The Forest Service's classification has been quietly tracking the second of these for almost seven decades."

The team also found that the correlation between site index and biomass growth depends strongly on stand age, on species, and on ecological region. In middle-age stands (60 to 80 years old), plots with tall trees for their age tend to be the slowest-accumulating plots right now, with a correlation of negative 0.57. In old-growth stands past 120 years, the relationship flips: the tallest stands are also the ones still accumulating biomass fastest, with a correlation of positive 0.33. The species-level correlation ranges from nearly zero in yellow-poplar to almost 0.5 in Douglas-fir. A national productivity ranking that uses any single measure implicitly assumes one relationship across all of these contexts, and the data show that one relationship does not hold.

To make the multi-dimensional view operational, the team has released the Composite Site Productivity Index (CSPI) version 2.0.0 as a 30-meter gridded dataset covering the conterminous United States. The release includes the composite plus the four component layers as standalone files, so that researchers and practitioners can either use the composite for general productivity ranking or pick the component that best fits their application. The data are openly available through Zenodo under a Creative Commons license. A manuscript reporting the findings has been prepared for submission to the journal Forest Ecology and Management.

The pipeline producing the dataset ran on the Ohio Supercomputer Center Cardinal cluster and is documented as open-source code on GitHub. The work was supported by the USDA National Institute of Food and Agriculture McIntire-Stennis Forestry Research Program through the Maine Agricultural and Forest Experiment Station, with supplemental support from the University of Maine.

"This is not a statement that site index has been wrong," Weiskittel said. "Site index works well within a narrow envelope: single-species pure stands, calibrated species ranges, even-aged structure. What we now show empirically is that outside that envelope, the relationship between site index and the productivity dimensions practitioners actually care about is unstable. The choice of productivity measure now depends on what you are trying to do. We have given the field the data to make that choice deliberately rather than by tradition."

The Center for Research on Sustainable Forests is part of the University of Maine's School of Forest Resources within the College of Natural Sciences, Forestry, and Agriculture. Weiskittel's research focuses on forest biometrics, growth and yield modeling, and the integration of new measurement technologies into operational forest management.

---

**Media kit:**

- Concept Zenodo DOI: 10.5281/zenodo.20515034 (always points to the latest version)
- Version 2.0.0 DOI: 10.5281/zenodo.20663652
- GitHub: https://github.com/holoros/fvs-conus
- Figures available for media use: contact aaron.weiskittel@maine.edu
- High-resolution headshot of Weiskittel available from CRSF communications

**Suggested headlines (for editor):**

1. Forest Service classification tracks biomass growth more closely than site index, UMaine study finds
2. UMaine forestry research challenges a century of single-metric productivity ranking
3. Forest productivity is multi-dimensional, UMaine study of 66,000 plots finds

**Background notes (for journalists):**

This research relates to but does not contradict prior work. Site index has been widely critiqued in the biometrics literature since the late twentieth century, and the recommendation to treat productivity as multi-dimensional dates to Bontemps and Bouriaud (Forestry 2014) and Skovsgaard and Vanclay (Forestry 2008). What this study provides that previous work has not is the empirical test at the conterminous United States scale with all four measures computed at the same plots from the same Forest Service inventory data. It joins the four-measure analysis to the Forest Service's own SITECLCD classification, providing the first quantitative demonstration that the operational classification system aligns with one productivity dimension while the operational measurement aligns with a different one.

Weiskittel is available for interviews in English. Specialized topics he can speak to include forest biometrics, individual-tree growth and yield modeling, the Forest Vegetation Simulator (FVS), forest carbon accounting, and the integration of remote sensing into forest measurement.

---

*[END OF PRESS RELEASE]*
