#!/usr/bin/env python3
"""F16 (NPP scatter + residual map) and F17 (variable importance side-by-side)."""
import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

OUTDIR = "/sessions/quirky-peaceful-babbage/mnt/outputs"

# ===== F16: scatter + residual choropleth proxy (color-coded points) =====
print("Loading PIX22 predictions...")
lon, lat, obs, pred, resid, pm = [], [], [], [], [], []
with open(f"{OUTDIR}/PIX22_npp_predictions.csv") as f:
    rd = csv.DictReader(f)
    for r in rd:
        try:
            lon.append(float(r["LON"])); lat.append(float(r["LAT"]))
            obs.append(float(r["npp_obs"])); pred.append(float(r["npp_pred"]))
            resid.append(float(r["npp_resid"])); pm.append(r["pm_name"])
        except (ValueError, KeyError):
            continue

lon = np.array(lon); lat = np.array(lat)
obs = np.array(obs); pred = np.array(pred); resid = np.array(resid)
print(f"  n = {len(obs)}")

# Compute R² from observed vs predicted
ss_res = np.sum((obs - pred)**2)
ss_tot = np.sum((obs - np.mean(obs))**2)
r2 = 1 - ss_res / ss_tot
rmse = np.sqrt(np.mean((obs - pred)**2))
print(f"  R² = {r2:.4f}, RMSE = {rmse:.1f}")

fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

ax = axes[0]
ax.hexbin(obs, pred, gridsize=80, cmap="viridis", mincnt=1, bins="log")
xmin = min(obs.min(), pred.min()); xmax = max(obs.max(), pred.max())
ax.plot([xmin, xmax], [xmin, xmax], "r--", linewidth=1.0, alpha=0.7, label="1:1")
ax.set_xlabel("Observed NPP (MOD17A3HGF, scaled units)", fontsize=11)
ax.set_ylabel("v9-stack predicted NPP (OOB)", fontsize=11)
ax.set_title(f"A. Predicted vs observed NPP\nOOB R² = {r2:.3f}, RMSE = {rmse:.0f}",
             fontsize=12, fontweight="bold", loc="left")
ax.legend(loc="upper left", fontsize=9, frameon=False)
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

ax = axes[1]
clim = max(abs(np.percentile(resid, 2)), abs(np.percentile(resid, 98)))
sc = ax.scatter(lon, lat, c=resid, s=1.2, cmap="RdBu_r",
                vmin=-clim, vmax=clim, alpha=0.7, rasterized=True)
cb = fig.colorbar(sc, ax=ax, shrink=0.65)
cb.set_label("Residual (obs - pred)", fontsize=10)
ax.set_xlim(-125, -65); ax.set_ylim(24, 50)
ax.set_xlabel("Longitude", fontsize=11)
ax.set_ylabel("Latitude", fontsize=11)
ax.set_title("B. Residual spatial pattern",
             fontsize=12, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)
ax.set_aspect("equal")

plt.tight_layout()
plt.savefig(f"{OUTDIR}/F16_npp_pred_vs_obs.png", dpi=240, bbox_inches="tight", facecolor="white")
plt.savefig(f"{OUTDIR}/F16_npp_pred_vs_obs.pdf", bbox_inches="tight", facecolor="white")
print(f"Wrote F16")

# ===== F17: variable importance side-by-side =====
print("\nLoading variable importance tables...")
def read_imp(path, var_col, imp_col):
    rows = []
    with open(path) as f:
        rd = csv.DictReader(f)
        for r in rd:
            rows.append((r[var_col], float(r[imp_col])))
    return sorted(rows, key=lambda x: -x[1])

npp_imp = read_imp(f"{OUTDIR}/PIX11_npp_obs_varimp.csv", "variable", "importance")
asym_imp = read_imp(f"{OUTDIR}/PM23_asym_v9_var_importance.csv", "variable", "importance")

# Normalize importance to fraction of total for comparability
npp_total = sum(v for _, v in npp_imp)
asym_total = sum(v for _, v in asym_imp)
npp_imp = [(name, v / npp_total) for name, v in npp_imp]
asym_imp = [(name, v / asym_total) for name, v in asym_imp]

fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

ax = axes[0]
names = [n for n, _ in npp_imp]
vals = [v for _, v in npp_imp]
y = np.arange(len(names))[::-1]
ax.barh(y, vals, color="#1A3D28", alpha=0.85)
ax.set_yticks(y); ax.set_yticklabels(names, fontsize=9)
ax.set_xlabel("Relative importance (fraction)", fontsize=10)
ax.set_title("A. RS-target: MOD17 NPP\n(satellite observed)",
             fontsize=12, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

ax = axes[1]
names = [n for n, _ in asym_imp]
vals = [v for _, v in asym_imp]
y = np.arange(len(names))[::-1]
ax.barh(y, vals, color="#D55E00", alpha=0.85)
ax.set_yticks(y); ax.set_yticklabels(names, fontsize=9)
ax.set_xlabel("Relative importance (fraction)", fontsize=10)
ax.set_title("B. FIA-target: Asym v9\n(biomass carrying capacity)",
             fontsize=12, fontweight="bold", loc="left")
ax.spines["top"].set_visible(False); ax.spines["right"].set_visible(False)

fig.text(0.5, 0.02,
         "Each model uses its own predictor stack: NPP uses water-balance + radiation + N deposition + parent material; "
         "Asym uses SoilGrids + SRTM terrain + Hansen tree cover + parent material. "
         "Both find parent material at intermediate rank.",
         ha="center", fontsize=8, color="gray", style="italic", wrap=True)

plt.tight_layout(rect=[0, 0.06, 1, 1])
plt.savefig(f"{OUTDIR}/F17_importance_npp_vs_asym.png", dpi=240, bbox_inches="tight", facecolor="white")
plt.savefig(f"{OUTDIR}/F17_importance_npp_vs_asym.pdf", bbox_inches="tight", facecolor="white")
print("Wrote F17")
