#!/usr/bin/env python3
"""F18 high-resolution hex-binned residual map of v9-stack NPP predictions across CONUS.
Three panels: (A) hex-binned mean residual; (B) hex-binned residual standard deviation;
(C) hex-binned plot count, to show where residuals are well-sampled."""

import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

INDIR = "/sessions/quirky-peaceful-babbage/mnt/outputs"

lon, lat, resid = [], [], []
with open(f"{INDIR}/PIX22_npp_predictions.csv") as f:
    rd = csv.DictReader(f)
    for r in rd:
        try:
            lon.append(float(r["LON"])); lat.append(float(r["LAT"]))
            resid.append(float(r["npp_resid"]))
        except (ValueError, KeyError):
            continue

lon = np.array(lon); lat = np.array(lat); resid = np.array(resid)
print(f"n = {len(resid)}")
print(f"residual: mean={np.mean(resid):.1f}, sd={np.std(resid):.1f}, min={np.min(resid):.0f}, max={np.max(resid):.0f}")

# Three-panel figure
fig, axes = plt.subplots(1, 3, figsize=(17, 5.6))

# Panel A: mean residual
clim = np.percentile(np.abs(resid), 95)
ax = axes[0]
hb = ax.hexbin(lon, lat, C=resid, gridsize=70, cmap="RdBu_r",
               vmin=-clim, vmax=clim, reduce_C_function=np.mean,
               mincnt=3, edgecolors="none")
cb = fig.colorbar(hb, ax=ax, shrink=0.7)
cb.set_label("Mean residual (obs - pred)", fontsize=9)
ax.set_xlim(-125, -65); ax.set_ylim(24, 50); ax.set_aspect("equal")
ax.set_xlabel("Longitude", fontsize=10); ax.set_ylabel("Latitude", fontsize=10)
ax.set_title("A. Mean residual per hex cell",
             fontsize=11, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

# Panel B: residual SD
ax = axes[1]
hb = ax.hexbin(lon, lat, C=resid, gridsize=70, cmap="viridis",
               reduce_C_function=np.std,
               mincnt=3, edgecolors="none")
cb = fig.colorbar(hb, ax=ax, shrink=0.7)
cb.set_label("Residual SD per hex", fontsize=9)
ax.set_xlim(-125, -65); ax.set_ylim(24, 50); ax.set_aspect("equal")
ax.set_xlabel("Longitude", fontsize=10); ax.set_ylabel("Latitude", fontsize=10)
ax.set_title("B. Residual SD per hex cell",
             fontsize=11, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

# Panel C: plot count
ax = axes[2]
hb = ax.hexbin(lon, lat, gridsize=70, cmap="magma",
               bins="log", mincnt=1, edgecolors="none")
cb = fig.colorbar(hb, ax=ax, shrink=0.7)
cb.set_label("log10 plot count per hex", fontsize=9)
ax.set_xlim(-125, -65); ax.set_ylim(24, 50); ax.set_aspect("equal")
ax.set_xlabel("Longitude", fontsize=10); ax.set_ylabel("Latitude", fontsize=10)
ax.set_title("C. Plot density per hex cell",
             fontsize=11, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

plt.tight_layout()
plt.savefig(f"{INDIR}/F18_npp_residual_hexbin.png", dpi=220, bbox_inches="tight", facecolor="white")
plt.savefig(f"{INDIR}/F18_npp_residual_hexbin.pdf", bbox_inches="tight", facecolor="white")
print(f"Wrote F18")
