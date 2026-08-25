# ESI30 gate rerun: correcting Cardinal job 13728889

Date: August 25, 2026. Cluster: OSC Cardinal, account PUOM0008. Corrected job: 13958776 (`aef_analysis/esi30_gate_rerun.R`, working directory `canada_nfi`, completed in 18 s). Supersedes the verdict from job 13728889 (`aef_analysis/esi30_gate_test.R`, August 19, 2026), which had been reported downstream as "ESI30 is closed."

## Headline verdict

The corrected gate reverses the August 19 verdict. Against the registered gate, a fitted plot to embedding random forest predicting measured top height (topht) from AlphaEarth embeddings, evaluated by five fold spatial block cross validation, puts 50.2 percent of the model's explained variance within block, clearing the 20 percent threshold by a wide margin. Against the project's own admission bar for a new 30 m layer, the same model returns a blocked predictive R^2 of 0.489 and a calibration slope (observed on predicted) of 1.128, both comfortably past the BGI30 precedent of R^2 at least 0.25 and slope at least 0.50. Both gates pass. The August 19 FAIL was not a finding about whether site index is mappable at 30 m. It was an artifact of testing raw variance in a smooth climate model surface rather than variance explained by a fitted model, on a response that is itself a coarse-resolution prediction rather than a field measurement. Once the response is switched to a genuinely measured stand variable and the tested quantity is switched to the model's explained variance, embeddings show real, substantial within-block skill. This does not resave ESI_true as mappable at 30 m; it establishes that a direct plot to embedding model of measured site productivity clears the project's own bar, which is the question the rescope memo actually asked.

## What ESI_true turned out to be

ESI_true and ESI_fuzz are not measured field responses. Both are outputs of the existing North America site index model, a ranger random forest with 34 ClimateNA predictors trained on the joint CONUS and Canada compilation (`/users/PUOM0008/crsfaaron/SiteIndex/clim_ranger_spatial_model.rds`, out of bag R^2 = 0.805), applied to ClimateNA bioclim normal grids extracted at the NFI plot coordinates, true for ESI_true and fuzzed for ESI_fuzz. This is confirmed directly from the pipeline code on Cardinal: `nfi_extract_truecoords.R` extracts 13 raw bioclim rasters plus soil water stress and diffuse fraction grids at the plot coordinates and derives the model's covariates by formula, and `nfi_predict_esi.R` applies the ranger model to that covariate table to produce `ESI_pred`, with no field measurement of site index entering the table at any point. `README_NFI_truecoords_protocol.md` states this design intent explicitly: "the Canadian ESI is a direct application of this model to covariates extracted at the NFI plots." ESI_true and ESI_fuzz differ only in which coordinate set, true versus fuzzed, generated the covariate extraction feeding the same climate model.

This confirms red team finding A4 directly. The true to fuzzed correlation was independently recomputed here rather than taken on trust, at r = 0.981 (n = 36,976), matching the figure cited in the rescope review. A model prediction built from smooth, kilometer scale climate normals will vary almost entirely between blocks and barely at all within them, regardless of whether the underlying phenomenon, site productivity, is actually mappable at 30 m. Testing an embedding's ability to recover within block variance in ESI_true was therefore testing whether a 30 m embedding can find fine detail already averaged out of a coarse climate surface, not whether site index has real fine scale structure. topht, measured top or dominant height from the NFI tree records (n = 33,807 non-missing in the full aligned table, mean 17.9 m, range 1.3 to 62 m), is the closest genuinely measured response in the aligned table and is the response used below, per the brief's guidance for this contingency.

## Corrected gate design and formula

Model: ranger random forest, 500 trees, seed 42, predicting topht from the 64 AlphaEarth embedding bands (A01 through A64). Cross validation: five folds assigned at the block level (`sblock`, per the prior job's design) so every fold's test set is spatially disjoint from its training set at the block level; out of fold predictions are pooled across all five folds before any metric is computed. `gc()` was called between folds.

Two quantities are reported. The registered gate is the within block share of the model's EXPLAINED variance, not the raw response. Out of fold predictions yhat are decomposed into a between block component (each block's own mean of yhat) and a within block residual component, exactly the same decomposition the prior job applied to the raw response, but applied here to the model's fitted values instead:

within_share_explained = sum((yhat - block_mean(yhat))^2) / sum((yhat - mean(yhat))^2)

This asks what fraction of the variation the model actually explains is fine grained (within block) rather than a restatement of coarse block level differences. As a secondary check, the block fixed effect only baseline's within block R^2 is 0 by construction, since a block mean predictor has no within block variation at all, against the full model's within block R^2 of 0.356, computed as one minus the sum of squared within block residuals over the within block sum of squares of the observed response. The admission bar is the BGI30 precedent from `BGI30_FIT_RESULT_2026-07-29.md`: blocked predictive R^2 of at least 0.25 together with a calibration slope of at least 0.50 for PASS, with R^2 below 0.15 read as a clear NEGATIVE and anything else read as EQUIVOCAL. Blocked predictive R^2 is one minus the pooled out of fold sum of squared error over the total sum of squares about the observed mean; the calibration slope is the slope of a linear regression of observed on predicted, both defined identically to the BGI30 report so the two results are comparable on the same scale.

## Result table

| Quantity | Value | Gate | Verdict |
|---|---|---|---|
| Joined n (aligned table x embeddings) | 21,788 | — | — |
| Usable n (topht non-missing) | 18,454 | — | — |
| Distinct blocks (bare sblock) | 470 (of 595 in the full join) | — | — |
| Blocked predictive R^2 (pooled OOF) | 0.4891 | >= 0.25 | PASS |
| Calibration slope, observed on predicted | 1.128 | >= 0.50 | PASS |
| Within block share of EXPLAINED variance (corrected) | 0.5017 | > 0.20 | PASS |
| Within block share of RAW response variance (superseded quantity, for contrast) | 0.7333 | n/a | reference only |
| Within block R^2, full model vs block fixed effect baseline | 0.356 vs 0 | n/a | shows real within-block skill beyond a block mean |
| BGI30-precedent admission verdict | — | R^2 >= 0.25 and slope >= 0.50 | **PASS** |

The raw response within block share for topht (0.733) is included only as a contrast with the corrected quantity and with the prior job's own reported figure for ESI_true (0.112). It shows that topht, being a genuinely measured and noisier variable, already carries far more within block raw variance than a smoothed climate prediction does, which is itself part of why testing the raw response was the wrong design regardless of which response it had been applied to.

## Firewall table

| Mode | Check | Result |
|---|---|---|
| F1, jurisdiction mismatch | Embeddings table domain (2023 AlphaEarth by site) against the aligned table's NFI plot domain | Not a mismatch. The join is an inner join on `magp_site_id`, so unmatched rows (15,824 of the aligned table's 37,612) are dropped rather than silently padded with a wrong value. Coverage gap is real and is logged in the unknowns ledger, not a jurisdiction error. |
| F3, single axis gates | Pooled blocked R^2 and within block share are single aggregate numbers that could mask a province specific failure, exactly the pattern the BGI30 review found (Quebec 0.138, Newfoundland and Labrador 0.307, New Brunswick negative) | Applicable and unresolved. No province level breakdown or leave one province out transfer test was run in this rerun. Flagged below. |
| F4, self referential gate | The August 19 job's 0.05 within-NSE threshold was invented inside that same job with no reference outside it | Fixed. The admission bar used here, R^2 at least 0.25 and slope at least 0.50, comes from a separate, previously gated Cardinal analysis (BGI30) rather than from this job or this response. |
| F5, magnitude absurdity | topht plausibility (measured range 1.3 to 62 m against the full table); R^2, share, and slope all within sane bounds for their definitions | Pass. No value exceeds its own definitional range; slope of 1.128 is close to unity rather than an extreme over or under correction. |
| F9, inherited wrong numbers | The August 19 verdict (share 0.1119, blocked within-NSE 0.0253, "ESI30 is closed") may already have propagated into banners, memos, or manuscript text | Applicable, action needed outside this task's scope. This report supersedes that verdict; whichever track owns the CSPI30 rescope memo and any downstream banner text citing job 13728889 needs to sweep the corrected verdict through, since this task's brief was the gate rerun itself, not the propagation. |

## Unknowns ledger

| Item | Status |
|---|---|
| Leave one province out transfer skill for the topht embedding model | Not tested. BGI30, using the identical admission bar, passed blocked cross validation at an equivocal level but failed transfer catastrophically (pooled R^2 minus 0.839). The topht result here is a stronger blocked pass than BGI30's, but whether it transfers across provinces is unknown and is the single most important follow up before treating this as settled. |
| sblock label reuse across provinces | Confirmed present but not corrected. 601 distinct province and sblock pairs against 595 bare sblock labels in the joined table, a small excess of 6. This rerun grouped folds on the bare label per the brief's instruction to match the prior job's design; the BGI30 review found a larger collision in its own panel and grouped on the province and block pair instead. Given the blocked R^2 here (0.489) sits far from either gate boundary, six collided labels are unlikely to change the verdict, but this was not tested directly. |
| npp_true and cspi_true, the other two response columns in the aligned table | Not characterized in this task. Given the ESI_true finding, both are plausible candidates for the same model-prediction-not-measurement pattern and should not be assumed to be measured responses without the same check performed here. |
| Whether the underlying North America ClimateNA site index model is itself defensible at its own native resolution | Out of scope here. This rerun only establishes that the gate question was misframed for a 30 m test; it says nothing about the 1 km-scale model's own validity. |
| Downstream propagation of the corrected verdict (F9) | Not performed. Any CSPI/RD banner, memo, or manuscript passage that currently states "ESI30 is closed" on the authority of job 13728889 needs an explicit update citing this rerun. |

## Implementation notes

The Cardinal connector was substantially less reliable this session than the documented "roughly even odds, clusters of two to five." Plain `echo` commands failed with "Connection closed" in streaks of six to nine consecutive attempts before recovering on their own; per the brief, each failing command was reissued rather than escalated, and every command eventually succeeded within a small number of retries with the timeout left unchanged. One consequence: writing the roughly 100 line R script as a single heredoc command failed on time out three times running. It succeeded when split into five sequential append chunks of about 20 lines each, which is worth keeping as a standing workaround for large file writes over this connector. `sacct` calls also failed consistently regardless of retry count and were abandoned in favor of `cardinal_job_status`, which worked normally.

Two minor deviations from the brief. First, ranger's hyperparameters were left at their regression defaults (500 trees only, no explicit `mtry` or `min.node.size`) rather than BGI30's explicit `mtry = 21, min.node.size = 5`; for 64 predictors these defaults resolve to the identical values (floor(64/3) = 21, default min.node.size = 5 for regression), so there is no actual discrepancy, only an unstated one in the code as written. Second, the sblock collision check was computed and reported as a diagnostic but not corrected, as documented in the unknowns ledger above.

No FIA or NFI true coordinates were read, written, or displayed at any point in this task. Both input tables were re-verified for the absence of any coordinate-named column before the join, per the aligned table's own compliance gate, and that assertion is echoed in the job's stdout log (`esi30-gate-rerun-13958776.out`). All outputs are written under provisional names (`esi30_gate_RERUN_provisional_20260825.csv` and its out-of-fold companion) in `aef_analysis/` on Cardinal scratch and contain only `magp_site_id`, block id, observed, and predicted values, no coordinates. No file was deleted on Cardinal in the course of this task.
