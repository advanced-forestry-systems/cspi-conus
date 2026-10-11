#!/usr/bin/env python3
"""F14 wind decile two-panel figure for the supplement.
   Panel A: mean Asym v9 by wind decile (raw)
   Panel B: mean v9 residual by wind decile (null after conditioning)
"""
import os
import re
import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# Directories default to the repo layout; override with CSPI_ANALYSES / CSPI_FIGDIR.
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ANALYSES = os.environ.get("CSPI_ANALYSES", os.path.join(REPO, "analyses"))
FIGDIR = os.environ.get("CSPI_FIGDIR", os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(ANALYSES, "PM31_asym_resid_by_wind_decile.csv")
RMSE_PATH = os.path.join(ANALYSES, "multidim_v6_geol", "PM22_asym_v9_refit_v3stack.csv")
OUT_PNG = os.path.join(FIGDIR, "F14_wind_decile.png")
OUT_PDF = os.path.join(FIGDIR, "F14_wind_decile.pdf")

# v9 OOB RMSE read from its source table rather than hardcoded
with open(RMSE_PATH) as f:
    v9_rmse = next(float(r["OOB_RMSE"]) for r in csv.DictReader(f)
                   if r["model"].startswith("Asym v9"))

rows = []
with open(CSV_PATH) as f:
    rd = csv.DictReader(f)
    for r in rd:
        # wind_q is e.g. "(3.81,4.19]" or "[1.98,2.51]"
        m = re.match(r"[\[\(]([0-9.\-]+),([0-9.\-]+)\]", r["wind_q"])
        if not m:
            continue
        low = float(m.group(1)); high = float(m.group(2))
        rows.append({
            "wind_low": low,
            "wind_high": high,
            "wind_mid": (low + high) / 2,
            "asym_mean": float(r["asym_mean"]),
            "resid_mean": float(r["resid_mean"]),
            "n": int(r["n"]),
        })

rows.sort(key=lambda x: x["wind_mid"])
wind = [r["wind_mid"] for r in rows]
asym = [r["asym_mean"] for r in rows]
resid = [r["resid_mean"] for r in rows]

fig, axes = plt.subplots(1, 2, figsize=(11, 4.6))

ax = axes[0]
ax.plot(wind, asym, "-o", color="#1A3D28", markersize=8, linewidth=1.5, alpha=0.85)
ax.set_xlabel("TerraClimate annual mean wind speed (m s$^{-1}$)", fontsize=11)
ax.set_ylabel("Mean Asym v9 (Mg ha$^{-1}$)", fontsize=11)
ax.set_title("A. Raw bivariate pattern", fontsize=12, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
ax.grid(False)
ax.axhspan(min(asym)-0.5, max(asym)+0.5, alpha=0)

ax = axes[1]
ax.axhline(0, color="gray", linestyle="--", linewidth=0.8)
ax.plot(wind, resid, "-o", color="#D55E00", markersize=8, linewidth=1.5, alpha=0.85)
ax.set_xlabel("TerraClimate annual mean wind speed (m s$^{-1}$)", fontsize=11)
ax.set_ylabel("Mean v9 residual (Mg ha$^{-1}$)", fontsize=11)
ax.set_title("B. After v3 stack conditioning", fontsize=12, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
ax.set_ylim(-2.0, 2.0)
ax.grid(False)
fig.text(0.55, 0.01,
         f"v9 OOB RMSE = {v9_rmse:.2f} Mg ha$^{{-1}}$; residual amplitude is one to two orders of magnitude smaller",
         fontsize=8.5, color="gray", ha="left")

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.savefig(OUT_PNG, dpi=300, bbox_inches="tight", facecolor="white")
plt.savefig(OUT_PDF, bbox_inches="tight", facecolor="white")
print(f"Wrote {OUT_PNG} and {OUT_PDF}")
