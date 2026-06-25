# Paper 3 concept: a North American extension with exact-coordinate microsite validation

*25 June 2026. Scoping note. Companion to Paper 2 (the CONUS RS-CSPI, in submission to Remote Sensing of Environment).*

## The opening Paper 2 leaves

Paper 2's single largest limitation is that the 30 m microsite structure is not independently validated against fine-scale ground productivity, because FIA coordinates are fuzzed and cannot be paired with 30 m predictors. A dataset with exact plot coordinates would close that gap directly. Canada has one.

## The data: MAGPlot

The Multi-Agency Ground Plot database (NRCan, Canadian Forest Service) harmonizes the National Forest Inventory and 12 provincial and territorial networks into one analysis-ready schema under the Open Government Licence. The open package inspected on Cardinal contains:

- 39,131 sites (province, lat, lon, elevation, aspect class, slope class, slope position)
- 257,032 plot measurements across sites, so a large share are remeasured, which yields actual increment, not just a standing snapshot
- 7,771,042 tree records (species, DBH, height, crown class, stems per ha, status)
- treatment, disturbance, condition, and removal tables

Productivity attributes are derivable exactly as for the BC VRI work: top height plus age gives site index; DBH and stems per ha give basal area; remeasured plots give basal-area increment; species are carried per tree.

## The coordinate catch (decisive for the design)

The open package coordinates are randomized within 5 km of true location, coarser than FIA fuzzing. Exact coordinates require a formal NFI Data Request plus a Data Use Agreement, with some jurisdictions needing an extra form. So the design splits into two tiers:

- Tier 1, open 5 km data, available now: a pan-Canadian 1 km RS-CSPI (the RS-as-response method transfers, ClimateNA covers Canada), national-scale validation of the divergence and of standing productivity, and a test of whether the BC null generalizes across boreal and montane Canada. No exact coordinates needed because 5 km randomization is tolerable at 1 km aggregation.
- Tier 2, exact coordinates, by request: the exact-located 30 m microsite validation that FIA forbids and that closes Paper 2's main limitation. This is the headline contribution and the reason to do Paper 3.

## Aims

1. Extend the RS-CSPI across forested Canada at 1 km using the open MAGPlot frame for validation, testing the height-versus-flux divergence over a far wider climate and species range than CONUS.
2. With exact coordinates, validate the 30 m surface against precisely located ground productivity, the fine-scale validation FIA cannot support.
3. Use the remeasured plots to test the standing-versus-growth distinction at continental scale: confirm whether the RS-CSPI tracks standing productivity but not current increment, as found from the FIA growth tables.
4. Generalize the BC null: determine whether plot-level ground site index is environmentally unpredictable across jurisdictions, framing the RS surface as a validation target rather than a site-index predictor.

## The BC lesson, carried forward

BC plot-level site index was not environmentally predictable at any grain, because it is governed by species and stand state. Paper 3 must therefore be framed around validating the RS productivity surface against exactly located plots, not around predicting ground site index. The expected and honest result is divergence from height-based site index plus a positive but modest relationship to standing biomass productivity, now at continental scale and, for the first time, at exact coordinates.

## Practical path

- Now: prototype Tier 1 from the open package (derive site index, basal area, increment; build the Canada 1 km surface; run the national validation). No agreements required.
- In parallel: submit the NFI Data Request and Data Use Agreement for exact coordinates, justified by the 30 m microsite validation. Requires Aaron's signature and likely a CFS collaborator.
- Keep Paper 2 moving to RSE independently; Paper 3 is a follow-on, not a revision.

## Status

Open package downloaded and inspected on Cardinal at `canada/magplot/pkg`. Tier 1 prototype can start on request. Tier 2 is gated on the data agreement.
