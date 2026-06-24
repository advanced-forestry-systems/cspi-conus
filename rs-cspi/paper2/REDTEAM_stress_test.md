# Red-team stress test: RS-CSPI

*23 June 2026. An adversarial review of the FIA-independent RS-CSPI, written as a hostile reviewer would, to find where it breaks before a reviewer does. Severity is High (could sink the paper), Medium (major revision), or Low (note it).*

## H1. MODIS NPP is a climate model, so predicting it from climate is partly circular. HIGH

MOD17 NPP is itself a light-use-efficiency model driven by climate reanalysis and fPAR. Predicting MOD17 NPP (R2 0.95) from a climate predictor stack is close to predicting a climate model from its own inputs. The high NPP number is the least trustworthy in the paper and a remote-sensing reviewer will say so immediately. GPP (0.965) has the same problem; both are MOD17.
Mitigation: lean the headline on the structurally independent targets, GEDI L4B AGBD (lidar) and NASA-CMS biomass (inventory-lidar fusion), whose lower R2 (0.75 to 0.89) is the honest, defensible signal. Quantify how much of NPP predictability survives when climate predictors are removed (non-climate-only fit). State the circularity explicitly.

## H2. The wall-to-wall versus plot-frame comparison is not apples to apples. HIGH

The headline "gridded beats the plot frame" (biomass OOB 0.57 to 0.93) compares OOB on a dense, highly spatially autocorrelated grid against OOB on dispersed FIA plots. OOB does not remove spatial autocorrelation, which is far stronger on the contiguous grid, so the grid's number is inflated for a reason that has nothing to do with signal. The comparison must be redone with spatially blocked CV on both frames. If the gap shrinks or reverses under blocked CV, the headline claim weakens.
Mitigation: run blocked CV on the plot-frame fits and compare to the wall-to-wall blocked CV. Report only the blocked comparison as the headline.

## H3. No validation against independent ground productivity. HIGH

Every validation (OOB, blocked CV) is RS-predicted-from-environment checked against the same RS target. Nothing is checked against an independent measure of actual forest productivity (flux towers, remeasured FIA growth). The paper validates internal consistency, not productivity accuracy.
Mitigation: validate the RS-CSPI and the predicted flux surfaces against AmeriFlux tower GPP/NPP at tower locations (the FEM paper did this). This is the single most important addition.

## M1. The SAE refinement gain is mostly spatial interpolation, not the RS layer. MEDIUM

For asym, RS-only blocked R2 was 0.15 and RS-plus-spatial 0.75. Almost all of the gain is the spatial smooth, which is kriging-like interpolation of the FIA values, not the RS-CSPI contributing information. Claiming the RS backbone is refined by SAE overstates the RS role.
Mitigation: decompose into RS-only, spatial-only, and combined. If spatial-only is near 0.75, say plainly that the localization is spatial interpolation of inventory and the RS layer adds modestly; frame SAE as inventory interpolation guided by, not driven by, the RS layer.

## M2. The composite mixes non-commensurable axes with arbitrary weights. MEDIUM

Equal-weight z-averaging of flux (NPP), structure (AGBD, biomass) treats different quantities as one productivity axis. PC1 explaining 69 percent helps, but the index has no physical units and cannot directly drive a growth and yield model, which needs productivity in real units (site index in metres, or volume increment). The "drives G&Y" claim is aspirational.
Mitigation: soften to "a relative productivity index" and show the path to absolute units (calibrate the index to remeasured FIA increment). The SAE-to-asym surface is the start of that.

## M3. Microsite variance is model-induced, not validated. MEDIUM

The 32 percent sub-1 km variance is variance the RF propagates from the 30 m terrain, soil, and canopy predictors. No independent evidence that the 30 m surface captures real microsite productivity differences. A reviewer will note the microsite signal could be predictor texture, not productivity.
Mitigation: validate the 30 m surface against any fine-scale productivity data available (dense lidar AGB, or stand-level growth); failing that, state clearly it is predictor-resolved potential, not validated realized microsite productivity.

## L1. Dropping the change target to align with site index is inconsistent with the framing. LOW

The narrative says site index is the limitation, then drops biomass change partly because it correlated most negatively with site index. If site index is not the benchmark, that is not a reason to drop it.
Mitigation: justify dropping change purely on its being a flux not a level, independent of site index.

## L2. Temporal stability layer inherits MOD17 circularity. LOW

NPP interannual CV is MOD17 interannual variability, which is climate-driven, so the stability layer partly re-expresses climate variability.
Mitigation: present as a MODIS-derived stability indicator, not an independent productivity-stability measurement.

## Bottom line

The construct is sound and the FIA-free design is a real contribution, but three High items must be addressed before submission: the NPP circularity, the unfair wall-to-wall comparison, and the absence of independent ground validation. The hardening analyses below target all three plus the SAE attribution.
