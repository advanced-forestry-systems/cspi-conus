# Remote Sensing of Environment submission checklist

*RS-CSPI manuscript (Paper 2). Status as of 25 June 2026.*

## Required manuscript elements

| element | status | note |
|---|---|---|
| Title | done | "Beyond site index: a remote sensing composite site productivity index..." |
| Author and affiliation | done | Aaron R. Weiskittel, University of Maine, CRSF (single author) |
| Highlights (3 to 5, max 85 characters each) | done | added; all under 85 characters |
| Abstract (unstructured, about 250 words) | done | ~250 words; verify count at upload |
| Keywords (about 6) | done | added after abstract |
| Introduction | done | site-index limits, BC PSPL comparator, response-side reframing |
| Methods | done | extent, predictors, targets, fitting, validation, composite, SAE; seed and versions now stated |
| Results | done | Sec 3.1 to 3.9, all headline numbers spatially blocked |
| Discussion | done | divergence, SAE decomposition, BC cross-jurisdiction test, limitations |
| Conclusions | done | claims scoped to validated use |
| Acknowledgments | done | OSC allocation PUOM0008; CRSF funding only (no MAFES/NIFA) |
| CRediT author statement | done | "Author contributions" section |
| Declaration of competing interest | done | none declared |
| Declaration of generative AI in writing | done | added per Elsevier policy |
| Data and code availability | done | Zenodo concept DOI 10.5281/zenodo.20827436 (latest v4.1.0); GitHub PR under advanced-forestry-systems/cspi-conus |
| References (Elsevier name-year) | done | author-date style; all DOIs CrossRef-verified |
| Figures (high resolution, separate files) | done | Fig 1 to 4; PDF vector and 320 dpi PNG on Cardinal and in figures/ |

## Submission-portal items (to assemble at upload)

| item | status | note |
|---|---|---|
| Cover letter | drafted | see COVERLETTER_RSE.md |
| Suggested reviewers (4 to 6) | to do | name remote-sensing-productivity and forest-biometrics reviewers; avoid recent co-authors |
| Graphical abstract | optional | the 1 km CONUS map (Figure 1) would serve; not required |
| Word count and abstract count | verify | confirm at upload; abstract near the 250-word guide |
| Funding declaration | done | University of Maine CRSF |
| Data availability statement in portal | done | mirror the manuscript statement |

## Pre-upload verification (passed this pass)

- Numbers-and-claims audit against the analysis files: complete. Abstract and discussion corrected to the honest wall-to-wall and SAE framings; AmeriFlux n corrected to 29; composite-vs-site-index numbers reconciled (level composite -0.12, change-inclusive -0.39).
- Figures: Fig 2 (AmeriFlux, annotated r, CI, n) and Fig 3 (plot-level divergence) regenerated journal-ready; Fig 3 caption corrected to match new content.
- Deposits: Zenodo v4.1.0 published and concept DOI resolves to latest; GitHub PR #2 open and current.

## Open items before clicking submit

1. Reconcile the Figure 2 CI annotation [0.38, 0.85] to the registered [0.35, 0.85] (trivial rerun with the registered seed), or cite the fresh resample in both places.
2. Compile the figures as individual high-resolution files named per the portal (Fig1.tif/pdf, etc.).
3. Draft the suggested-reviewer list.
4. Confirm abstract word count at upload.
