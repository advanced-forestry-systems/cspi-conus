#!/usr/bin/env python3
"""F14 wind decile two-panel figure for the supplement.
   Panel A: mean Asym v9 by wind decile (raw)
   Panel B: mean v9 residual by wind decile (null after conditioning)
"""
import re
import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

CSV_PATH = "/sessions/quirky-peaceful-babbage/mnt/outputs/PM31_asym_resid_by_wind_decile.csv"
OUT_PNG = "/sessions/quirky-peaceful-babbage/mnt/outputs/F14_wind_decile.png"
OUT_PDF = "/sessions/quirky-peaceful-babbage/mnt/outputs/F14_wind_decile.pdf"

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
         "v9 OOB RMSE = 8.21 Mg ha$^{-1}$; residual amplitude is one to two orders of magnitude smaller",
         fontsize=8.5, color="gray", ha="left")

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.savefig(OUT_PNG, dpi=300, bbox_inches="tight", facecolor="white")
plt.savefig(OUT_PDF, bbox_inches="tight", facecolor="white")
print(f"Wrote {OUT_PNG} and {OUT_PDF}")
