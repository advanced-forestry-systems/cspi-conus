#!/usr/bin/env python3
"""
Staged increment job: MOD17A3HGF annual NPP 2017-2023, per-plot temporal slope at FIA plots.
Resumable (skips downloaded granules). Uses Earthdata creds in ~/.netrc (present on Cardinal).
Fully autonomous; submitted by the daily Cardinal check once the conus_v4 allocation frees.

Approach:
  1. earthaccess search MOD17A3HGF v061, CONUS bbox, one granule set per year 2017-2023.
  2. For each FIA plot, sample the annual NPP value per year (point sample in sinusoidal CRS).
  3. Fit NPP ~ year per plot; write slope (kgC/m2/yr per yr) and mean.
Output: /fs/scratch/PUOM0008/crsfaaron/rs_validation/mod17_npp_slope_at_plots.csv
The R correlation step then joins this to ESI/BGI/Asym/composite (template in the memo).
"""
import os, sys, glob, traceback
import numpy as np, pandas as pd
WORK = "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
DL   = "/fs/scratch/PUOM0008/crsfaaron/mod17/annual"
ELOG = os.path.join(WORK, "mod17_error_log.txt")
os.makedirs(DL, exist_ok=True)
def log(m):
    print(m, flush=True)
    open(ELOG, "a").write(m + "\n")

YEARS = list(range(2017, 2024))
BBOX  = (-125.0, 24.0, -66.0, 50.0)  # CONUS

try:
    import earthaccess, rasterio
    from rasterio.warp import transform as rio_transform
    auth = earthaccess.login(strategy="netrc")
    plots = pd.read_csv(os.path.join("/fs/scratch/PUOM0008/crsfaaron/cspi_v7",
                                     "cspi_4c_plot_values.csv"),
                        usecols=["ID", "LAT", "LON"]).drop_duplicates("ID")
    log(f"plots: {len(plots)}")

    per_year = {}
    for y in YEARS:
        gran = earthaccess.search_data(short_name="MOD17A3HGF", version="061",
                                       temporal=(f"{y}-01-01", f"{y}-12-31"),
                                       bounding_box=BBOX)
        ydir = os.path.join(DL, str(y)); os.makedirs(ydir, exist_ok=True)
        have = glob.glob(os.path.join(ydir, "*"))
        if len(have) < len(gran):
            earthaccess.download(gran, local_path=ydir)  # resumable; skips existing
        files = sorted(glob.glob(os.path.join(ydir, "*.hdf")) + glob.glob(os.path.join(ydir, "*.tif")))
        per_year[y] = files
        log(f"{y}: {len(files)} granules")

    # sample each plot from each year's mosaic (read Npp subdataset, scale 0.0001)
    def sample_year(files, lon, lat):
        vals = []
        for f in files:
            try:
                sds = f"HDF4_EOS:EOS_GRID:{f}:MOD_Grid_MOD17A3HGF:Npp_500m" if f.endswith(".hdf") else f
                with rasterio.open(sds) as src:
                    xs, ys = rio_transform("EPSG:4326", src.crs, [lon], [lat])
                    r, c = src.index(xs[0], ys[0])
                    if 0 <= r < src.height and 0 <= c < src.width:
                        v = src.read(1)[r, c]
                        if v not in (src.nodata, 32767, 32766, 65535):
                            vals.append(v * 0.0001)
            except Exception:
                continue
        return np.nanmean(vals) if vals else np.nan

    out = []
    yr = np.array(YEARS, float)
    for i, row in plots.iterrows():
        series = np.array([sample_year(per_year[y], row.LON, row.LAT) for y in YEARS], float)
        ok = np.isfinite(series)
        if ok.sum() >= 4:
            slope = np.polyfit(yr[ok], series[ok], 1)[0]
            out.append((row.ID, np.nanmean(series), slope, int(ok.sum())))
        if i % 5000 == 0:
            log(f"...{i} plots")
    res = pd.DataFrame(out, columns=["ID", "npp_obs_mean", "npp_slope", "n_years"])
    res.to_csv(os.path.join(WORK, "mod17_npp_slope_at_plots.csv"), index=False)
    log(f"DONE: wrote {len(res)} plot slopes")
    open(os.path.join(WORK, "_mod17_status.txt"), "w").write("DONE\n")
except Exception as e:
    log("FATAL: " + str(e) + "\n" + traceback.format_exc())
    sys.exit(1)
