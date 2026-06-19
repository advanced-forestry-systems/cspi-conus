# cspi-conus

Composite Site Productivity Index (CSPI) for the conterminous United States — manuscript drafts, analytical chain, pipeline scripts, and outreach materials.

## Citation

If you use any of the CSPI data products or analytical chain, please cite:

Weiskittel, A. R. (in preparation). Beyond site index: FIA's own classification system disagrees with site index but agrees with a multi-dimensional composite of forest productivity at 30 m across the conterminous United States. Forest Ecology and Management.

## Data releases

| Version | DOI | Contents |
|---|---|---|
| Concept (parent record) | [10.5281/zenodo.20515034](https://doi.org/10.5281/zenodo.20515034) | All CSPI versions |
| v1.0.0 | [10.5281/zenodo.20515035](https://doi.org/10.5281/zenodo.20515035) | SICOND-target v3 and v4 surfaces |
| v2.0.0 | [10.5281/zenodo.20663652](https://doi.org/10.5281/zenodo.20663652) | 1 km ESI v6 surface + MOD17A3HGF NPP at 500 m + documentation |
| **v3.0.0** | **[10.5281/zenodo.20763197](https://doi.org/10.5281/zenodo.20763197)** | **Asym v9 corrective surface at 30 m (forest-masked and unmasked), parent material 30 m CONUS overlay, trained ranger model object, release notes** |
| Analytical chain v1.0.0 | [10.5281/zenodo.20693106](https://doi.org/10.5281/zenodo.20693106) | All analysis CSVs and supplementary tables |

## v3.0.0 deposit contents (most recent release)

- `ASYM_V9_CONUS_30m_fm.tif` (forest-masked, 6.7 GB): headline product for existing forest assessment. Hansen tree cover 2000 ≥ 30% definition.
- `ASYM_V9_CONUS_30m.tif` (unmasked, 13 GB): for reforestation planning. Non-forest pixels carry model-estimated potential mature carrying capacity given local environmental conditions.
- `parent_material_30m_CONUS_4326.tif`: gSSURGO 10-class overlay (Residuum, Alluvial, Marine, Glacial, Colluvium, Eolian, Other, Organic, Volcanic, Lacustrine).
- `m_asym_v9_v3stack.rds`: trained ranger random forest model, OOB R² = 0.836.
- `NEWS_v3.0.0.md`: release notes.

## Repository structure

| Directory | Contents |
|---|---|
| `manuscript/` | v0.10 manuscript draft (md, docx) and v0.10k collaborator PPTX |
| `analyses/` | Underlying CSV outputs for tables and figures |
| `figures_v10/` | F1–F13b figures (PNG + PDF) |
| `zenodo/` | Zenodo deposit metadata templates |

## License

All data products are CC-BY-4.0. Code is MIT. See `LICENSE` (when added).

## Acknowledgments

This work was supported by the University of Maine Center for Research on Sustainable Forests. Computation was performed on the Ohio Supercomputer Center Cardinal cluster under allocation PUOM0008.
