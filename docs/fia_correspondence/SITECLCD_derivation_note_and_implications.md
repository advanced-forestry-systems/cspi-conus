# How FIA derives SITECLCD, and what it means for the manuscript

*21 June 2026. Distilled from the David Diaz / FIA-staffer correspondence (March to April 2024, NRS and RMRS), saved alongside this note. This is a primary-source clarification of the SITECLCD derivation chain and it bears directly on the paper's headline.*

## What the correspondence establishes

SITECLCD is a classification of MAICF, the mean annual increment of cubic-foot volume at culmination. It is not a direct classification of site index. The chain is:

site index (height growth potential) -> species-specific yield equation -> MAICF (potential cubic-volume growth at culmination) -> binned into the 7 SITECLCD classes.

Regional methods differ, which matters for the East-West and per-region results:

- **NRS (Northeast, 13 states):** site index from Westfall et al. (2017, Forest Science 63:283-290); **Midwest (11 states):** Carmean, Hahn, Jacobs (1989, GTR NC-128). Site index is assigned to the condition from a selected site tree, then a site class is determined from the site index value via break points. In young stands site index is estimated from forest type.
- **RMRS:** condition-level MAICF is computed directly from site-tree yield equations (Brickell 1970 INT-75; Mowrer 1986; Stage 1966, 1969 for grand fir), stocking-weighted across species groups, with default MAICF of 10 (woodland types) or 10 to 20 (unstocked). Site index, base age, and species come from the dominant site-tree species group.

## Why this matters for the headline

The paper's headline is that FIA's SITECLCD is recovered by biomass growth increment (BGI alone OOB R^2 = 0.808) better than by the unified-target site index (ESI alone 0.751), framed as a mismatch between what the field classifies as productivity and what it measures.

The correspondence does two things to that result, and both should be addressed before submission.

**It supplies the mechanism (strengthens the paper).** SITECLCD classifies MAICF, a cubic-volume-growth-at-culmination quantity. Volume growth is much closer to biomass growth than to height-growth potential. So the empirical finding that SITECLCD aligns with BGI is mechanistically expected once you know SITECLCD is a volume-growth classification. The paper can now state the mechanism rather than presenting the alignment as an unexplained empirical surprise. The species-specific site-index-to-MAICF yield transform is precisely what reorients the classification away from the height-SI value and toward volume-and-biomass-growth structure, and it does so differently across species, which is the source of the per-species and East-West sign behavior the paper documents.

**It creates a reviewer-attack surface (must be pre-empted).** Because SITECLCD is derived from site index, a reviewer can argue the SITECLCD-vs-BGI result is mechanical or circular. The honest defense is that the transform from height-potential site index to volume-growth MAICF is strongly species-dependent and is the operative step: the classification the field uses is a volume-growth construct even though the value the field reports and feeds into FVS (SICOND, a height-growth site index) is a different dimension. The contribution is naming and quantifying that the operative productivity construct in U.S. forest classification is volume-and-biomass growth at culmination, not height growth, and showing how far the two diverge across species and region. This also tightens the §4.7.1 FIA-on-FIA framing: SITECLCD is not independent of site index, so the result is a representation result about what the classification encodes, not an independent prediction.

## References to add (from the correspondence)

- Westfall, J.A., Hatfield, M.A., Sowers, P.A., O'Connell, B.M. (2017). Site index models for tree species in the northeastern United States. Forest Science 63 (3): 283-290. doi:10.5849/FS-2016-090.
- Carmean, W.H., Hahn, J.T., Jacobs, R.D. (1989). Site index curves for forest tree species in the eastern United States. GTR NC-128. USDA Forest Service.
- Brickell, J.E. (1970). Equations and computer subroutines for estimating site quality of eight Rocky Mountain species. Res. Pap. INT-75. USDA Forest Service.
- Mowrer, H.T. (1986). Site productivity estimates for aspen in the central Rocky Mountains. Western Journal of Applied Forestry 1 (3): 89-91.
- Stage, A.R. (1966). Simultaneous derivation of site-curve and productivity rating procedures. SAF Proceedings 1966: 134-136. (and Stage 1969, Res. Note INT-98, grand fir.)

## Recommended next steps

1. **Add a short SITECLCD-derivation paragraph to Methods (§2.3 FIA context joins or a new §2.x) and sharpen §4.2 and §4.7.1** with the MAICF mechanism and the references above. Highest priority; it both strengthens the headline and closes the circularity attack.
2. **Reproduce MAICF from SICOND (new analysis).** Using the documented yield equations, recompute MAICF at the FIA plots from SICOND and species, then show MAICF correlates strongly with BGI (both volume/biomass-growth quantities) and weakly with ESI (height). This directly demonstrates the mechanism and converts the reviewer attack into a confirmed result. The RMRS species-group equations (Brickell 1970, etc.) and the NE/Midwest site-index sources give a tractable path for at least the timber forest types. SITECLCD class break points can be requested from Chuck Barnett (offered in the correspondence).
3. **Request the SITECLCD break points and site-tree species list** from Barnett (NRS) and the equation parameters; he explicitly offered them. This makes the reproduction exact for the eastern states.
4. **Engage David Diaz.** He assembled the FIA-methods correspondence, works on Climate Smart Wood MMRV at Vibrant Planet, and the SITECLCD-carbon-offset relevance (Hoover and Smith 2012, already cited) is squarely his domain. Consider him for coauthorship or as the natural FIA-FS engagement partner already noted for Q4 2026.
5. **Note the regional derivation heterogeneity** (NRS site-index-to-breakpoint vs RMRS direct-MAICF) in the East-West discussion as a partial driver of the regime behavior.
