#!/usr/bin/env python3
"""
f1 interior-nodata lattice probe. Pre-registered 2026-08-25.

For each raster in the inventory, lay a regular lattice over the FULL declared
extent, sample the pixel value at each lattice cell, and compute the fraction
of nodata (or NaN) cells per jurisdiction (CONUS + 10 Canadian provinces + 3
territories). Flag INTERIOR_NODATA when a jurisdiction the file claims to
cover (via filename prefix, filename substring, working-record override, or
bbox inference) has nodata_fraction > 0.95 with >= 5 sampled lattice points
in that jurisdiction.

Lattice design: decimated read targeting ~20 km native ground spacing per
axis, capped to [20,500] columns and [20,350] rows. 20 km chosen because
Prince Edward Island (smallest Canadian jurisdiction, ~145 km x 65 km bbox)
still gets several lattice cells across its narrow axis at this spacing,
while a NA-wide raster stays under ~175,000 cells, cheap for a single bulk
GDAL decimated read (no per-point I/O).

Run on Cardinal (OSC) via SLURM batch job, submitted 2026-08-25. Uses rasterio
(confirmed present in the user's ~/.local site-packages under system
/usr/bin/python3, no module load needed; Cardinal has no dedicated gdal
Python-binding module, only a compiler-gated gdal/3.7.3 C library module).
"""
import csv, glob, math, os, sys, time, traceback
import numpy as np
import rasterio
from rasterio.enums import Resampling
from rasterio.warp import transform_bounds, transform as rio_transform
from rasterio.errors import RasterioIOError

BASE = "/fs/scratch/PUOM0008/crsfaaron"
OUT_CSV = "/fs/scratch/PUOM0008/crsfaaron/na_maps/f1_interior_nodata_probe_20260825.csv"
SKIP_LOG = "/fs/scratch/PUOM0008/crsfaaron/na_maps/f1_interior_nodata_probe_SKIPPED_20260825.csv"
DISCOVERY_LOG = "/fs/scratch/PUOM0008/crsfaaron/na_maps/f1_interior_nodata_probe_DISCOVERY_20260825.log"

TARGET_SPACING_M = 20000.0
NX_MIN, NX_MAX = 20, 500
NY_MIN, NY_MAX = 20, 350
FLAG_THRESHOLD = 0.95
MIN_POINTS = 5
MAX_FILES = 400  # hard cap, generous vs the 19-Aug sweep's 80; log any truncation
TILE_DIR_STRATIFY_THRESHOLD = 300  # directories with more .tif files than this are sampled, not enumerated whole
TILE_DIR_SAMPLE_N = 60             # evenly-spaced sample size per large tile directory

JURISDICTIONS = {
    "CONUS": (-125.0, 24.0, -66.0, 49.0),
    "AK":    (-179.9, 51.0, -129.9, 71.5),
    "AB":    (-120.2, 48.9, -110.0, 60.0),
    "BC":    (-139.3, 48.2, -114.0, 60.0),
    "MB":    (-102.1, 48.9,  -88.9, 60.0),
    "NB":    ( -69.2, 44.5,  -63.6, 48.1),
    "NL":    ( -67.9, 46.5,  -52.5, 60.4),
    "NS":    ( -66.5, 43.3,  -59.6, 47.2),
    "ON":    ( -95.3, 41.6,  -74.2, 57.0),
    "PE":    ( -64.5, 45.8,  -61.9, 47.1),
    "QC":    ( -79.9, 44.9,  -57.0, 62.7),
    "SK":    (-110.1, 48.9, -101.3, 60.0),
    "YT":    (-141.1, 59.9, -123.7, 69.7),
    "NT":    (-136.6, 59.9, -101.9, 78.9),
    "NU":    (-120.1, 59.9,  -61.1, 83.2),
}
CANADA_ALL = ["AB","BC","MB","NB","NL","NS","ON","PE","QC","SK","YT","NT","NU"]

RECORD_OVERRIDE_CONUS_SUBSTR = [
    "cspi_v2_5component", "asym_on_esi_grid", "bgi_on_esi_grid",
    "npp_miami_on_esi_grid", "mia_g.tif", "mod_g.tif",
]

KNOWN_INVENTORY = [
 f"{BASE}/na_maps/cspi/Canada_BGI_2km.tif",
 f"{BASE}/na_maps/cspi/Canada_BGI_gross_2km.tif",
 f"{BASE}/na_maps/cspi/Canada_BGI_gross_full_2km.tif",
 f"{BASE}/na_maps/cspi/Canada_BGI_min_2km_20260804.tif",
 f"{BASE}/na_maps/cspi/Canada_ESI_refit_2km.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_cog.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_componentmask.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_ncomponents.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_qaflags.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_strict.tif",
 f"{BASE}/na_maps/cspi/Canada_FIPI_composite_2km_uncertainty.tif",
 f"{BASE}/na_maps/cspi/Canada_land_mask_2km.tif",
 f"{BASE}/na_maps/cspi/NA_ESI_2km.tif",
 f"{BASE}/na_maps/cspi/NA_RS_CSPI_2km.tif",
 f"{BASE}/na_maps/cspi/_can2.tif",
 f"{BASE}/na_maps/cspi/_con2.tif",
 f"{BASE}/na_maps/cspi/_con_map.tif",
 f"{BASE}/na_maps/cspi/_intermediate_canada_climate34_2km.tif",
 f"{BASE}/na_maps/cspi/_intermediate_canada_soils_2km.tif",
 f"{BASE}/na_maps/cspi/_intermediate_conus_forest_frac_2km.tif",
 f"{BASE}/na_maps/cspi/_lat.tif",
 f"{BASE}/na_maps/rd/_conus_rd_1km.tif",
 f"{BASE}/na_rd_20260804/CONUS_RD_2km.tif",
 f"{BASE}/na_rd_20260804/Canada_RD_2km.tif",
 f"{BASE}/na_rd_20260804/NA_RD_2km.tif",
 f"{BASE}/na_rd_20260804/_raw_canada.tif",
 f"{BASE}/na_rd_20260804/_raw_conus.tif",
 f"{BASE}/na_rd_20260804/cov_canmask_2km.tif",
 f"{BASE}/na_rd_20260804/cov_climna33_2km.tif",
 f"{BASE}/na_rd_20260804/cov_npp_canada_2km.tif",
 f"{BASE}/na_rd_20260804/cov_npp_conus_2km.tif",
 f"{BASE}/na_rd_20260804/cov_nppcv_conus_2km.tif",
 f"{BASE}/na_rd_20260804/cov_srad12_2km.tif",
 f"{BASE}/cspi_v7/v2both/CSPI_v2_5component_1km.tif",
 f"{BASE}/cspi_v7/v2both/CSPI_v2_5component_30m.tif",
 f"{BASE}/cspi_v7/v2both/CSPI_v2_5component_30m_forest.tif",
 f"{BASE}/cspi_v7/v2both/mia_g.tif",
 f"{BASE}/cspi_v7/v2both/mod_g.tif",
 f"{BASE}/cspi_v7/cspi_v2_aligned/Asym_on_esi_grid.tif",
 f"{BASE}/cspi_v7/cspi_v2_aligned/BGI_on_esi_grid.tif",
 f"{BASE}/cspi_v7/cspi_v2_aligned/NPP_MIAMI_on_esi_grid.tif",
 f"{BASE}/cspi_v3/v4_climate_33_1km.tif",
 f"{BASE}/Disturbance_run/alphaearth/conus/conus_RD_30m_2022.tif",
]

WATCH_DIRS = [
    f"{BASE}/na_maps", f"{BASE}/na_maps/cspi", f"{BASE}/na_maps/rd",
    f"{BASE}/na_rd_20260804", f"{BASE}/cspi_v7/v2both",
    f"{BASE}/cspi_v7/cspi_v2_aligned", f"{BASE}/cspi_v3",
    f"{BASE}/Disturbance_run/alphaearth/conus", f"{BASE}/canada_nfi",
    f"{BASE}/canada/magplot/rd30m_tiles_ca",
]

def is_prev_stale(path):
    b = os.path.basename(path).upper()
    return ("PREV" in b) or ("STALE" in b)

def stratified_sample(hits, n):
    """Evenly-spaced sample across a sorted file list, preserving spatial spread
    when filenames encode tile grid position (row/col order)."""
    if len(hits) <= n:
        return hits
    step = len(hits) / float(n)
    idxs = sorted(set(int(i * step) for i in range(n)))
    return [hits[i] for i in idxs]

def add_dir(d, found, log, tile_summary):
    if not os.path.isdir(d):
        log.write(f"DIR {d}: MISSING (not found on this run)\n")
        return
    hits = sorted(glob.glob(os.path.join(d, "*.tif")))
    if len(hits) == 0:
        log.write(f"DIR {d}: exists, 0 .tif files (CLAIMED_BUT_EMPTY if this dir is named as a data source)\n")
        tile_summary.append((d, 0, 0, "empty"))
        return
    if len(hits) > TILE_DIR_STRATIFY_THRESHOLD:
        sample = stratified_sample(hits, TILE_DIR_SAMPLE_N)
        log.write(f"DIR {d}: exists, {len(hits)} .tif files -> STRATIFIED SAMPLE of {len(sample)} "
                  f"(rule: evenly-spaced by sorted filename, step={len(hits)/float(len(sample)):.1f})\n")
        tile_summary.append((d, len(hits), len(sample), "stratified_sample"))
        found.extend(sample)
    else:
        log.write(f"DIR {d}: exists, {len(hits)} .tif files (all included)\n")
        tile_summary.append((d, len(hits), len(hits), "all_included"))
        found.extend(hits)

def discover(log):
    found = []
    tile_summary = []
    for d in WATCH_DIRS:
        add_dir(d, found, log, tile_summary)
    # canada_nfi and the Canada RD30 tile mirror were empty at the top level;
    # check recursively in case content lives in an unanticipated subdirectory
    for d in [f"{BASE}/canada_nfi", f"{BASE}/canada/magplot/rd30m_tiles_ca"]:
        if os.path.isdir(d):
            rec_hits = sorted(glob.glob(os.path.join(d, "**", "*.tif"), recursive=True))
            log.write(f"RECURSIVE CHECK {d}: {len(rec_hits)} .tif files found below top level\n")
            if rec_hits:
                if len(rec_hits) > TILE_DIR_STRATIFY_THRESHOLD:
                    sample = stratified_sample(rec_hits, TILE_DIR_SAMPLE_N)
                else:
                    sample = rec_hits
                found.extend(sample)
                tile_summary.append((d + " (recursive)", len(rec_hits), len(sample),
                                      "stratified_sample" if len(rec_hits) > TILE_DIR_STRATIFY_THRESHOLD else "all_included"))
    try:
        import subprocess
        r = subprocess.run(
            ["find", BASE, "-maxdepth", "4", "-type", "d",
             "-iname", "*RD30*", "-o", "-maxdepth", "4", "-type", "d", "-iname", "*ESI30*"],
            capture_output=True, text=True, timeout=60)
        extra_dirs = [l for l in r.stdout.splitlines() if l.strip()]
        log.write(f"RD30/ESI30-named dirs found: {extra_dirs}\n")
        for d in extra_dirs:
            add_dir(d, found, log, tile_summary)
    except Exception as e:
        log.write(f"broad RD30/ESI30 scan failed: {e}\n")
    log.write("TILE_SUMMARY: " + "; ".join(
        f"{d}[{pop} files, sampled {n}, {policy}]" for d, pop, n, policy in tile_summary) + "\n")
    return found

def classify_claim(path, measured_frac_conus, measured_frac_canada, bbox_ok):
    base = os.path.basename(path)
    stripped = base.lstrip("_")
    lower = stripped.lower()
    if lower.startswith("na_"):
        return "NA_WIDE", "prefix"
    if lower.startswith("conus"):
        return "CONUS", "prefix"
    if lower.startswith("canada"):
        return "CANADA_ALL", "prefix"
    lname = base.lower()
    for pat in RECORD_OVERRIDE_CONUS_SUBSTR:
        if pat in lname:
            return "CONUS", "working_record"
    has_canada = "canada" in lname
    has_conus = "conus" in lname
    if has_canada and has_conus:
        return "OPEN", "name_conflict"
    if has_canada:
        return "CANADA_ALL", "name_substring"
    if has_conus:
        return "CONUS", "name_substring"
    # path-based fallback: directory placement is a working-record signal
    # (e.g. .../alphaearth/conus/rd30m_tiles/tile_0042.tif has no filename
    # prefix or substring, but its parent directory unambiguously claims CONUS)
    dpath = os.path.dirname(path).lower()
    dhas_canada = "canada" in dpath
    dhas_conus = "conus" in dpath
    if dhas_canada and dhas_conus:
        return "OPEN", "path_conflict"
    if dhas_canada:
        return "CANADA_ALL", "path_substring"
    if dhas_conus:
        return "CONUS", "path_substring"
    if not bbox_ok:
        return "OPEN", "crs_bbox_artifact"
    if measured_frac_conus >= 0.95 and measured_frac_canada < 0.30:
        return "CONUS", "bbox_inferred_weak"
    if measured_frac_canada >= 0.95 and measured_frac_conus < 0.30:
        return "CANADA_ALL", "bbox_inferred_weak"
    if measured_frac_conus >= 0.95 and measured_frac_canada >= 0.95:
        return "NA_WIDE", "bbox_inferred_weak"
    return "OPEN", "no_claim_found"

def claim_cells(claim):
    if claim == "CONUS":
        return ["CONUS"]
    if claim == "CANADA_ALL":
        return list(CANADA_ALL)
    if claim == "NA_WIDE":
        return ["CONUS"] + list(CANADA_ALL)
    return []

def process_one(path, log):
    try:
        ds = rasterio.open(path)
    except RasterioIOError as e:
        return {"file": path, "error": f"open_failed: {e}"}
    xsize, ysize = ds.width, ds.height
    nodata = ds.nodata
    crs = ds.crs

    try:
        wxmin, wymin, wxmax, wymax = transform_bounds(crs, "EPSG:4326", *ds.bounds, densify_pts=21)
        bbox_ok = (-180.5 <= wxmin <= 180.5 and -180.5 <= wxmax <= 180.5
                   and -90.5 <= wymin <= 90.5 and -90.5 <= wymax <= 90.5
                   and (wxmax - wxmin) < 200 and (wymax - wymin) < 150)
    except Exception as e:
        wxmin = wymin = wxmax = wymax = float("nan")
        bbox_ok = False
        log.write(f"BBOX_TRANSFORM_FAILED {path}: {e}\n")

    try:
        is_geographic = crs.is_geographic
    except Exception:
        is_geographic = False
    try:
        lin_unit = 1.0 if is_geographic else 1.0  # rasterio CRS units already meters for the
    except Exception:                              # projected CRSs used in this project
        lin_unit = 1.0

    px_w = abs(ds.transform.a)
    px_h = abs(ds.transform.e)
    if is_geographic:
        px_w_m = px_w * 111000.0
        px_h_m = px_h * 111000.0
    else:
        px_w_m = px_w * lin_unit
        px_h_m = px_h * lin_unit

    nx = int(round((xsize * px_w_m) / TARGET_SPACING_M)) if px_w_m > 0 else NX_MIN
    ny = int(round((ysize * px_h_m) / TARGET_SPACING_M)) if px_h_m > 0 else NY_MIN
    nx = max(NX_MIN, min(NX_MAX, nx))
    ny = max(NY_MIN, min(NY_MAX, ny))

    t0 = time.time()
    try:
        arr = ds.read(1, out_shape=(ny, nx), resampling=Resampling.nearest)
    except Exception as e:
        return {"file": path, "error": f"decimated_read_failed: {e}"}
    read_s = time.time() - t0

    scale_x = xsize / float(nx)
    scale_y = ysize / float(ny)
    dec_transform = ds.transform * ds.transform.scale(scale_x, scale_y)

    cols = np.arange(nx) + 0.5
    rows = np.arange(ny) + 0.5
    cc, rr = np.meshgrid(cols, rows)  # shape (ny, nx)
    native_x = dec_transform.a * cc + dec_transform.b * rr + dec_transform.c
    native_y = dec_transform.d * cc + dec_transform.e * rr + dec_transform.f

    try:
        lon_flat, lat_flat = rio_transform(crs, "EPSG:4326",
                                            native_x.ravel().tolist(),
                                            native_y.ravel().tolist())
        lon_arr = np.array(lon_flat).reshape(ny, nx)
        lat_arr = np.array(lat_flat).reshape(ny, nx)
    except Exception as e:
        return {"file": path, "error": f"point_transform_failed: {e}"}

    if nodata is not None and not (isinstance(nodata, float) and math.isnan(nodata)):
        nd_mask = (arr.astype("float64") == float(nodata))
    else:
        nd_mask = np.zeros(arr.shape, dtype=bool)
    try:
        nan_mask = np.isnan(arr.astype("float64"))
    except Exception:
        nan_mask = np.zeros(arr.shape, dtype=bool)
    nd_mask = nd_mask | nan_mask

    counts = {k: [0, 0] for k in JURISDICTIONS}
    for jname, (jxmin, jymin, jxmax, jymax) in JURISDICTIONS.items():
        in_cell = (lon_arr >= jxmin) & (lon_arr <= jxmax) & (lat_arr >= jymin) & (lat_arr <= jymax)
        tot = int(in_cell.sum())
        nd = int((in_cell & nd_mask).sum())
        counts[jname] = [tot, nd]

    crs_label = crs.to_epsg()
    crs_label = f"EPSG:{crs_label}" if crs_label else str(crs)

    return {
        "file": path, "error": "", "native_crs": crs_label,
        "nodata_declared": nodata, "xsize": xsize, "ysize": ysize,
        "lattice_nx": nx, "lattice_ny": ny, "lattice_n": nx * ny,
        "wgs84_xmin": round(wxmin, 3) if bbox_ok else wxmin,
        "wgs84_ymin": round(wymin, 3) if bbox_ok else wymin,
        "wgs84_xmax": round(wxmax, 3) if bbox_ok else wxmax,
        "wgs84_ymax": round(wymax, 3) if bbox_ok else wymax,
        "bbox_ok": bbox_ok, "read_seconds": round(read_s, 2),
        "counts": counts,
    }

def main():
    os.makedirs(os.path.dirname(OUT_CSV), exist_ok=True)
    with open(DISCOVERY_LOG, "w") as log:
        discovered = discover(log)
        all_paths = list(dict.fromkeys(KNOWN_INVENTORY + discovered))
        all_paths = [p for p in all_paths if not is_prev_stale(p)]
        log.write(f"Total candidate rasters after inventory+discovery+PREV/STALE exclusion: {len(all_paths)}\n")

        skipped = []
        if len(all_paths) > MAX_FILES:
            skipped = all_paths[MAX_FILES:]
            all_paths = all_paths[:MAX_FILES]
            log.write(f"TRUNCATION: {len(skipped)} rasters skipped due to MAX_FILES={MAX_FILES} cap\n")

        fieldnames = ["file", "in_known_inventory", "error", "native_crs", "nodata_declared",
                      "xsize", "ysize", "lattice_nx", "lattice_ny", "lattice_n",
                      "wgs84_xmin", "wgs84_ymin", "wgs84_xmax", "wgs84_ymax", "bbox_ok",
                      "read_seconds", "claim", "claim_basis", "tested_jurisdictions",
                      "worst_jurisdiction", "worst_frac_nodata", "worst_points",
                      "flag", "per_jurisdiction_detail"]

        with open(OUT_CSV, "w", newline="") as fcsv:
            w = csv.DictWriter(fcsv, fieldnames=fieldnames)
            w.writeheader()
            for p in all_paths:
                row = {"file": p, "in_known_inventory": p in KNOWN_INVENTORY}
                if not os.path.exists(p):
                    row.update({"error": "file_not_found", "flag": "SKIPPED_MISSING"})
                    w.writerow(row)
                    log.write(f"MISSING: {p}\n")
                    continue
                try:
                    res = process_one(p, log)
                except Exception as e:
                    row.update({"error": f"exception: {e}", "flag": "SKIPPED_ERROR"})
                    w.writerow(row)
                    log.write(f"ERROR {p}: {e}\n{traceback.format_exc()}\n")
                    continue
                if res.get("error"):
                    row.update({"error": res["error"], "flag": "SKIPPED_ERROR"})
                    w.writerow(row)
                    log.write(f"ERROR {p}: {res['error']}\n")
                    continue

                counts = res["counts"]
                fc = counts["CONUS"]
                frac_conus = (fc[1] / fc[0]) if fc[0] else 0.0
                canada_total = sum(counts[k][0] for k in CANADA_ALL)
                canada_nd = sum(counts[k][1] for k in CANADA_ALL)
                frac_canada = (canada_nd / canada_total) if canada_total else 0.0

                claim, basis = classify_claim(p, frac_conus, frac_canada, res["bbox_ok"])
                cells = claim_cells(claim)

                worst_j, worst_frac, worst_pts = "", 0.0, 0
                flag = ""
                for j in cells:
                    tot, nd = counts[j]
                    frac = (nd / tot) if tot else None
                    if tot >= MIN_POINTS and frac is not None and frac > worst_frac:
                        worst_frac, worst_j, worst_pts = frac, j, tot
                if worst_j and worst_frac > FLAG_THRESHOLD:
                    flag = "INTERIOR_NODATA"
                elif claim == "OPEN":
                    flag = "OPEN"
                else:
                    flag = ""

                all_detail = ";".join(f"{j}:{counts[j][1]}/{counts[j][0]}" for j in JURISDICTIONS)

                row.update({
                    "error": "", "native_crs": res["native_crs"],
                    "nodata_declared": res["nodata_declared"],
                    "xsize": res["xsize"], "ysize": res["ysize"],
                    "lattice_nx": res["lattice_nx"], "lattice_ny": res["lattice_ny"],
                    "lattice_n": res["lattice_n"],
                    "wgs84_xmin": res["wgs84_xmin"], "wgs84_ymin": res["wgs84_ymin"],
                    "wgs84_xmax": res["wgs84_xmax"], "wgs84_ymax": res["wgs84_ymax"],
                    "bbox_ok": res["bbox_ok"], "read_seconds": res["read_seconds"],
                    "claim": claim, "claim_basis": basis,
                    "tested_jurisdictions": ";".join(cells),
                    "worst_jurisdiction": worst_j, "worst_frac_nodata": round(worst_frac, 4),
                    "worst_points": worst_pts, "flag": flag,
                    "per_jurisdiction_detail": all_detail,
                })
                w.writerow(row)
                fcsv.flush()
                log.write(f"OK {p}: claim={claim}({basis}) worst={worst_j} frac={worst_frac:.3f} flag={flag} "
                          f"lattice={res['lattice_nx']}x{res['lattice_ny']} read_s={res['read_seconds']}\n")
                log.flush()

            with open(SKIP_LOG, "w", newline="") as fs:
                ws = csv.writer(fs)
                ws.writerow(["file", "reason"])
                for s in skipped:
                    ws.writerow([s, f"MAX_FILES cap ({MAX_FILES}) exceeded"])

        log.write("DONE\n")

if __name__ == "__main__":
    main()
