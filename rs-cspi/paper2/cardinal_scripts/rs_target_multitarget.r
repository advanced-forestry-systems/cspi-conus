#!/usr/bin/env Rscript
# RS multi-target fit. Fits the v3 environmental stack against each satellite
# target that already has plot-level observations in plots_validation_joined.csv.
# Targets this run: gpp_obs (MOD17 GPP) and ch_m (canopy height, metres).
# Mirrors rs_target_npp_v2.r exactly so results are comparable to the NPP fit.
# NO FIA-derived metric enters any model; plot coords are sampling locations only.

suppressPackageStartupMessages({
  library(data.table)
  library(terra)
  library(ranger)
})

WORK    <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
BGI_DIR <- "/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/rasters_bgi"
PLOTS   <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation/plots_validation_joined.csv"
PM_RASTER <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/parent_material_30m_CONUS_4326.tif"
dir.create(WORK, recursive = TRUE, showWarnings = FALSE)
set.seed(1337)

plots <- fread(PLOTS)
cat("Plots:", nrow(plots), "\n")

covariates <- list(
  WATER_AET   = file.path(BGI_DIR, "WATER_AET_conus.tif"),
  WATER_DEF   = file.path(BGI_DIR, "WATER_DEF_conus.tif"),
  WATER_PET   = file.path(BGI_DIR, "WATER_PET_conus.tif"),
  WATER_AI    = file.path(BGI_DIR, "WATER_AI_conus.tif"),
  WATER_RATIO = file.path(BGI_DIR, "WATER_RATIO_conus.tif"),
  WATER_WD    = file.path(BGI_DIR, "WATER_WD_conus.tif"),
  SRAD        = file.path(BGI_DIR, "SRAD_conus.tif"),
  VPD_TC      = file.path(BGI_DIR, "VPD_TC_conus.tif"),
  WIND        = file.path(BGI_DIR, "WIND_conus.tif"),
  NDEP        = file.path(BGI_DIR, "NDEP_conus.tif"),
  DIST_COAST  = file.path(BGI_DIR, "DIST_COAST_KM_conus.tif")
)
keep <- names(covariates)[sapply(covariates, file.exists)]
stk  <- rast(unlist(covariates[keep])); names(stk) <- keep

xy  <- as.matrix(plots[, .(LON, LAT)])
env <- terra::extract(stk, xy)
plots <- cbind(plots, env)
plots[, pm_int := terra::extract(rast(PM_RASTER), xy)[[1]]]

predictors <- c(keep, "pm_int")
clim_only  <- intersect(c("WATER_AET","WATER_DEF","WATER_PET","SRAD","VPD_TC","WATER_AI"), keep)

fit_target <- function(target, tag, units) {
  cat("\n================ TARGET:", target, "(", units, ") ================\n")
  ok <- complete.cases(plots[, c(target, predictors), with = FALSE]) &
        is.finite(plots[[target]]) & plots[[target]] > 0
  cat("Plots with target + all predictors:", sum(ok), "of", nrow(plots), "\n")
  train <- plots[ok, c(target, predictors), with = FALSE]
  setnames(train, target, "y")
  train[, pm_int := as.factor(pm_int)]

  m_full <- ranger(y ~ ., data = train, num.trees = 500,
                   mtry = max(2, floor(length(predictors)/3)),
                   importance = "impurity",
                   num.threads = parallel::detectCores())
  cat("v3 stack OOB R2:", round(m_full$r.squared, 4),
      " RMSE:", round(sqrt(m_full$prediction.error), 3), units, "\n")
  saveRDS(m_full, file.path(WORK, paste0("m_", tag, "_v2.rds")))

  imp <- data.table(variable = names(m_full$variable.importance),
                    importance = as.numeric(m_full$variable.importance))
  setorder(imp, -importance); imp[, rank := .I]
  fwrite(imp, file.path(WORK, paste0("PIX11_", tag, "_varimp.csv")))
  print(imp)

  train_clim <- train[, c("y", clim_only), with = FALSE]
  m_clim <- ranger(y ~ ., data = train_clim, num.trees = 500,
                   mtry = max(2, floor(length(clim_only)/3)),
                   num.threads = parallel::detectCores())
  cat("Climate-only OOB R2:", round(m_clim$r.squared, 4),
      " RMSE:", round(sqrt(m_clim$prediction.error), 3), "\n")

  out <- data.table(
    target = target, units = units, n_train = nrow(train),
    model = c("Climate-only baseline", "v3 env stack (+ parent material)"),
    n_predictors = c(length(clim_only), length(predictors)),
    oob_r2 = c(m_clim$r.squared, m_full$r.squared),
    oob_rmse = c(sqrt(m_clim$prediction.error), sqrt(m_full$prediction.error)),
    delta_r2 = c(0, m_full$r.squared - m_clim$r.squared))
  fwrite(out, file.path(WORK, paste0("PIX12_", tag, "_climate_vs_full.csv")))
  print(out)

  # per-plot predictions (OOB) for later residual / ecoregion stratification
  pred_dt <- data.table(ID = plots$ID[ok], LAT = plots$LAT[ok], LON = plots$LON[ok],
                        obs = train$y, pred = m_full$predictions,
                        pm_int = plots$pm_int[ok])
  fwrite(pred_dt, file.path(WORK, paste0("PIX22_", tag, "_predictions.csv")))

  data.table(target = target, units = units, n_train = nrow(train),
             oob_r2_full = m_full$r.squared, oob_r2_clim = m_clim$r.squared,
             delta_r2 = m_full$r.squared - m_clim$r.squared,
             rmse_full = sqrt(m_full$prediction.error))
}

summ <- rbindlist(list(
  fit_target("gpp_obs", "gpp_obs", "g C m-2 yr-1"),
  fit_target("ch_m",    "ch_m",    "m")
))
fwrite(summ, file.path(WORK, "PIX14_multitarget_oob_summary.csv"))
cat("\n=== MULTI-TARGET SUMMARY ===\n"); print(summ)
cat("\n=== DONE ===\n")
