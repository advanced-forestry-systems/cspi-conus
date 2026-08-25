# RD30 A1 gap diagnosis, 9.9 percent median overshoot, and fix test

*25 August 2026. Track F of the same-day OODA follow-up pass on the RD30 CONUS assembly (job
13960109, `Disturbance_run/alphaearth` on Cardinal). Tests the mean-vs-median SAE calibration
hypothesis logged in `rd30-assembly-gatefix-and-diagnosis_FINAL_2026-08-25.md` against real data,
per the assignment, rather than reasoning about it in the abstract.*

## Headline verdict

The mean-versus-median hypothesis is confirmed as a real mechanism but is not the whole story, and
forcing it to be the whole story would have produced a wrong fix. `route_a_sae_calibrate.R` fits a
per-hex EBLUP that targets the plot RD_field **mean** within each roughly 12 km hex, then applies it
as a single multiplicative ratio (`factor = eblup / map_mean`) to every pixel in that hex. Algebra
alone shows this factor preserves whatever mean-to-median ratio the raw map already has inside a
hex, so it can only reproduce the plot median if the raw map's own within-hex skew happens to match
the plot RD_field's within-hex skew, which the data show it does not. That confirms the hypothesis.
But the actual 9.9 percent national gap turns out to be the net of two much larger, partly
offsetting defects that a single "skewed distribution" story does not predict on its own. First, a
compression pattern: plots in the bottom three RD_field deciles are calibrated two to four times too
high and plots in the top decile are calibrated to roughly half their true value, consistent with
Fay-Herriot shrinkage toward a synthetic regression mean plus the hard 1.5 output cap. Second, and
larger in absolute terms, 25.5 percent of all 123,173 plots (31,447 plots) sit on a raw,
pre-calibration pixel value of zero or less, and a multiplicative factor cannot lift a zero pixel,
so these plots stay pinned near zero after calibration regardless of calibration quality. That
second defect is heavily concentrated in ten low-forest-cover states (Iowa, North Dakota, Nebraska,
Utah, South Dakota, Kansas, Arizona, Nevada, Texas, New Mexico), where the calibrated median at plot
locations reads exactly 0.000 against plot RD_field medians of 0.44 to 1.07. Three candidate fixes
were tested on a genuine held-out split: none closes the gap to the 0.02 tolerance, though a
per-hex quantile-matching approach comes close (0.0244) and is the clear direction forward. RD30 is
not promotable on this pass. The A1 gate is doing its job and should keep blocking promotion.

## Evidence

`route_a_sae_calibrate.R` (read directly, not inferred) fits `u[, eblup := g*y + (1-g)*X%*%b]` with
`y = mean(RD_field)` by hex, a textbook Fay-Herriot small-area mean estimator, then computes
`cal[, factor := eblup/map_mean]` and applies that single scalar to every pixel in the hex (`v[ok]
<- v[ok]*f`, capped at 1500 in RD-times-1000 units). No median or quantile enters the calibration at
any point.

A server-side Cardinal job (13961904) reproduced the A1 gate's own extraction independently against
the actual `conus_RD_30m_calfix_2022_PROVISIONAL.tif` mosaic at all 123,173 plot locations from the
restricted `_private/sae_plot_enriched.csv`, and matched the production gate's reported median
exactly (0.7660), confirming the extraction methodology before drawing any conclusion from it.
Binning by RD_field decile shows the gap is neither uniform nor single-directional: ratio of
calibrated to true value runs 2.27, 1.49, 1.12, 0.99, 0.97, 1.07, 0.90, 0.75, 0.62, 0.47 across the
ten deciles from lowest to highest RD_field. Low values are inflated, high values are compressed,
and the crossover sits near the true population median, which is exactly the signature the
assignment asked to check for and rules out a simple constant multiplicative or additive
miscalibration.

A second Cardinal job (13962092) built a VRT directly over the raw, pre-calibration tile set
(`conus/rd30m_tiles`, the same input `route_a_sae_calibrate.R` reads) and extracted the true raw
pixel value at every plot location, replacing an earlier, weaker proxy (the OOF covariate `RS_RD`,
which correlated only 0.45 with the real extracted mosaic value and was discarded once this better
source was available, an instance of firewall F9, catching an inherited number before it reached a
decision). The raw extraction found 91,726 of 123,173 plots (74.5 percent) on a positive raw pixel
and 31,447 (25.5 percent) on a pixel that is zero, negative, or nodata, which
`route_a_sae_calibrate.R`'s own `v>0` filter leaves untouched by any calibration factor. State-level
aggregation (STATECD, no coordinates) shows this is not diffuse: ten states, comprising roughly
15,400 of the 31,447 affected plots in the state-level table alone, show a calibrated median of
exactly 0.000 against plot RD_field medians of 0.44 to 1.07, an undershoot of 0.44 to 0.80
concentrated in Iowa, North Dakota, Nebraska, Utah, South Dakota, Kansas, Arizona, Nevada, Texas, and
New Mexico, all low forest-cover states where the underlying remote sensing model evidently predicts
at or near zero. This is a distinct, spatially structured defect from the compression pattern above,
and it pulls the national median down while compression pulls it up, so the reported 9.9 percent
overshoot is the net of two larger opposing errors and understates the compression problem's true
severity.

The per-hex skew argument itself holds up directionally: among 9,230 hexes with at least five
plots, the median plot-level mean-to-median ratio is 1.0845 while the median raw-map ratio (using
the better raw-pixel source) is close to 1.0, and 70.8 percent of hexes have a raw-map ratio below
the plot ratio, the direction that predicts a mean-anchored factor will overshoot the median. This
confirms the mechanism without needing the compound compression and zero-floor findings to be
explained by it.

## Fix tested and result

Three candidate calibrations were fit on a genuine 70/30 held-out split of plots (not the full
sample the production factors were fit on, which the prior diagnosis flagged as a live circularity
concern for the A1 gate itself) and evaluated only on the held-out 30 percent, using the real raw
pixel value from the second Cardinal job.

A mean-anchored factor, rebuilt the same simplified way as production but on the held-out split
alone, reproduced the overshoot (calibrated median 0.2755 away from the target, worse than
production's net 0.069 because this test population excludes the offsetting zero-floor states). A
median-anchored factor, the fix implied by the hypothesis, cut that gap by roughly five times to
0.0555, still outside the 0.02 tolerance. A third candidate, per-hex quantile matching (mapping each
raw pixel's within-hex rank onto the corresponding plot RD_field quantile rather than scaling by any
single moment), cut the gap to 0.0244 on a denser hex subsample (n = 9,243, hexes with at least ten
training plots), an eleven-fold improvement over the mean-anchored baseline and just outside the
tolerance. None of the three passes the 0.02 gate on held-out data. The ordering is unambiguous and
in the predicted direction (moment-matching improves on the mean anchor; distribution-shape matching
improves further on moment-matching), which supports recommending quantile matching as the fix
direction, but none is validated to production quality yet, and none of the three tested fixes
addresses the separate zero-floor defect in the ten low-forest-cover states, since no multiplicative
or quantile transform of a zero input can produce a nonzero output.

## Firewall table

| Mode | Applies | Check | Result |
|---|---|---|---|
| F4, self-referential gate | Yes | A1's anchor (plot RD_field median 0.6970) is drawn from the same plot population used to fit the SAE calibration factors being tested | Partially mitigated in this pass by a genuine 70/30 held-out split for the fix test, but the production factors in `route_a_hex_factors.csv` were still fit on the full population; full independence is not achieved and is carried to the unknowns ledger below, unchanged from the prior diagnosis |
| F5, magnitude absurdity | Yes | Is a 25.5 percent zero-or-negative raw pixel rate at plot locations plausible against an external anchor | Plausible in direction (concentrated in low forest-cover arid and plains states where near-zero RD is expected) but not independently verified against an external non-forest fraction for those ten states in this pass; flagged, not closed |
| F9, inherited wrong numbers | Yes | Two numbers were re-derived rather than carried forward: the plot RD_field median/mean (0.6970, 0.9424, reproduced exactly from primary data in this pass) and the raw pixel value at plot locations (first attempted via the RS_RD proxy, corr 0.45 with the real extracted value, discarded once the real raw-tile extraction ran) | Caught and corrected within this pass before either number reached a decision; the RS_RD-based fix-test numbers from the first Cardinal job were not carried into the headline verdict above |

## Unknowns ledger

Known known: the mean-anchored calibration mechanism in `route_a_sae_calibrate.R` is real and
directly confirmed from the script. Known known: the A1 gate's own extraction methodology is
correct, independently reproduced to four decimal places (0.7660) before any further analysis was
built on it.

Live known unknown, the most consequential item here: whether the zero-floor defect (31,447 plots,
25.5 percent, on a non-positive raw pixel) reflects a genuine near-zero RD signal in low
forest-cover states, or a separate defect in the upstream RS model or tile generation there.
Distinguishing these needs a direct look at raw tiles in the ten flagged states against known
inventory locations, not attempted in this pass.

Known unknown, carried forward unchanged from the prior diagnosis: whether the hex-SAE calibration
factors were fit using the same 123,173 plots the A1 gate and this diagnosis both test against (F4
above), which limits how independent any of these checks, including the held-out fix test, can
claim to be, since the underlying factors in `route_a_hex_factors.csv` are still full-sample.

Unknown unknown surfaced this pass: the quantile-matching candidate's near-tolerance result (0.0244)
was measured only on the denser hex subsample with at least ten training plots per hex. Whether it
holds on the full, sparser hex population, which includes the zero-floor states, is untested.

## Implementation notes

Two Cardinal batch jobs ran to completion, both server-side, both writing only aggregate output. No
true plot coordinate, and no per-plot pid-keyed row, was printed, logged, or written to any file at
any point in either script. Job 13961904 (`rd30_a1_gap_diagnosis.R`, 35 seconds) covers the A1
reproduction, decile and state-level pattern, and a first-pass fix test using the RS_RD proxy. Job
13962092 (`rd30_a1_fixtest2.R`, 3 minutes 7 seconds) covers the raw-tile VRT extraction, the
corrected fix test, and the quantile-matching candidate. Both scripts and their aggregate CSV
outputs remain on Cardinal at
`/fs/scratch/PUOM0008/crsfaaron/Disturbance_run/alphaearth/rd30_a1_gap_diagnosis_out/`. No `rm`
command was issued or is proposed, and no file was deleted, renamed, or promoted.

Deviation from the assignment's literal wording, per F9: the RS_RD-proxy fix test ran first for
speed, produced an implausible reconstruction (correlation 0.45 with the real mosaic, median pegged
at the 1.5 cap), and was superseded rather than reported as the answer. The raw-tile extraction is
the trustworthy source for every number in the headline verdict and evidence sections above; the
RS_RD-based numbers appear only in the firewall table as a record of the caught error.

Failed attempt, recorded per F8: interactive `cardinal_run` calls for file discovery failed with
"Connection closed" on roughly two-thirds of attempts this session, above the documented ~45 percent
rate, and cleared on reissue with no case needing more than a handful of retries and no timeout
increase. Both analysis jobs were submitted via `cardinal_submit_job` rather than interactively, per
the project's standing convention, and both completed cleanly once queued.

Deferred: extending quantile matching to the full, sparser hex population; a structurally separate
fix for the zero-floor states, since no scalar or quantile transform of a zero produces a positive
output, likely needing an additive floor correction or different upstream treatment; and
independently verifying the 25.5 percent zero-raw-pixel rate against an external non-forest fraction
for the ten flagged states. None of these were fabricated a resolution to.

## Recommendation

Do not promote the RD30 products on this diagnosis. The A1 gate remains correctly failing and
should stay in place. The mean-vs-median hypothesis is confirmed as one real contributing mechanism,
but the dominant, larger-magnitude problem is the zero-floor defect in ten specific states, which no
version of the anchor-statistic fix tested here addresses. The recommended next step is two
separable pieces of work, not one: refine the quantile-matching calibration (closest tested
candidate, 0.0244 against 0.02) with better handling of sparse hexes, and separately investigate and
repair the zero-raw-pixel population in the ten flagged states before any rev 5 assembly attempt.
This is Aaron's call to schedule and to decide whether it is one pipeline change or two.
