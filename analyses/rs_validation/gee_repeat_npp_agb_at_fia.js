// Repeat productivity increment extraction at FIA plots, for CSPI external validation.
// Extracts at each FIA plot point:
//   (1) MOD17A3HGF annual NPP 2017-2023 and a per-plot linear NPP trend (slope on year)
//   (2) ESA CCI Biomass AGB for 2017 and 2021 and the 4-year AGB increment
// Exports one CSV to Drive. Matches the gee_extract_* convention already used in this project.
//
// PREREQUISITE: an EE FeatureCollection of FIA plot points with an 'ID' property.
// The project already uploads FIA points (see scripts/gee_extract_fia_bgi.js). Set the
// asset id below. If reusing the BGI extraction points, point at that same asset.

var FIA = ee.FeatureCollection('users/REPLACE_WITH_YOUR_FIA_POINTS_ASSET');  // must have property 'ID'

// ---------- 1. MOD17A3HGF annual NPP trend 2017-2023 ----------
var years = ee.List.sequence(2017, 2023);
var npp = ee.ImageCollection('MODIS/061/MOD17A3HGF')
  .filterDate('2017-01-01', '2023-12-31')
  .select('Npp');

// build an image with one band per year, plus the slope of Npp on year
var nppYearly = ee.ImageCollection(years.map(function (y) {
  y = ee.Number(y);
  var img = npp.filter(ee.Filter.calendarRange(y, y, 'year')).first();
  return ee.Image(img).multiply(0.0001)          // MOD17 scale -> kgC/m2/yr
           .rename(ee.String('npp_').cat(y.format('%d')))
           .set('year', y);
}));

// per-pixel linear trend: regress Npp on year
var nppTrendImg = npp.map(function (img) {
  var yr = ee.Number.parse(img.date().format('YYYY'));
  return img.multiply(0.0001).addBands(ee.Image.constant(yr).toFloat())
           .rename(['npp', 'year']);
}).select(['year', 'npp'])
  .reduce(ee.Reducer.linearFit());             // bands: scale (slope), offset
var nppSlope = nppTrendImg.select('scale').rename('npp_slope_2017_2023');
var nppMeanObs = npp.mean().multiply(0.0001).rename('npp_mean_obs');

// ---------- 2. ESA CCI Biomass AGB increment 2017 -> 2021 ----------
// ESA CCI AGB annual maps via the community catalog ImageCollection.
var cci = ee.ImageCollection('projects/sat-io/open-datasets/ESA/ESA_CCI_AGB');
function agbYear(y) {
  return cci.filter(ee.Filter.calendarRange(y, y, 'year')).mosaic()
            .select(0).rename('agb_' + y);
}
var agb2017 = agbYear(2017);
var agb2021 = agbYear(2021);
var agbDelta = agb2021.subtract(agb2017).rename('agb_delta_2017_2021');     // Mg/ha over 4 yr
var agbRate  = agbDelta.divide(4).rename('agb_rate_Mgha_yr');

// ---------- 3. stack and sample at plots ----------
var stack = nppSlope.addBands(nppMeanObs)
                    .addBands(agb2017).addBands(agb2021)
                    .addBands(agbDelta).addBands(agbRate)
                    .addBands(nppYearly.toBands());

var sampled = stack.reduceRegions({
  collection: FIA,
  reducer: ee.Reducer.mean(),
  scale: 500,          // MOD17 native; CCI is 100 m, mean within 500 m is acceptable for plot validation
  tileScale: 4
});

Export.table.toDrive({
  collection: sampled,
  description: 'fia_repeat_npp_agb_increment',
  fileFormat: 'CSV',
  selectors: ['ID', 'npp_slope_2017_2023', 'npp_mean_obs',
              'agb_2017', 'agb_2021', 'agb_delta_2017_2021', 'agb_rate_Mgha_yr']
});

// After the export lands in Drive, download to Cardinal and run the R join/correlation
// step (template in REPEAT_RS_VALIDATION_memo.md, "Next steps queued"): correlate
// npp_slope and agb_rate against ESI, BGI, Asym, and the composite at the plots, with
// special attention to agb_rate vs BGI (satellite AGB increment vs FIA biomass growth).
