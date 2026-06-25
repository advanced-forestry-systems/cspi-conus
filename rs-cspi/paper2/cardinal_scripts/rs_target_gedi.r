#!/usr/bin/env Rscript
# GEDI L4B v2.1 AGB density target. Extracts the 1 km mean AGBD (_MU) at the
# FIA plot locations, then fits the v3 environmental stack against it, exactly
# as the NPP / GPP / canopy-height fits. AGBD is a structural-carbon dimension
# distinct from the flux dimensions (NPP, GPP).

suppressPackageStartupMessages({
  library(data.table); library(terra); library(ranger)
})

WORK    <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
BGI_DIR <- "/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/rasters_bgi"
PLOTS   <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation/plots_validation_joined.csv"
PM_RASTER <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/parent_material_30m_CONUS_4326.tif"
GEDI_MU <- file.path(WORK, "gedi_l4b/GEDI04_B_MW019MW223_02_002_02_R01000M_MU.tif")
set.seed(1337)

plots <- fread(PLOTS)

cat("=== extract GEDI mean AGBD at plots (project pts to raster CRS 6933) ===\n")
r_agbd <- rast(GEDI_MU)
pts <- vect(as.data.frame(plots[, .(LON, LAT)]), geom = c("LON","LAT"), crs = "EPSG:4326")
pts_p <- project(pts, crs(r_agbd))
agbd <- terra::extract(r_agbd, pts_p)[[2]]
agbd[agbd <= 0] <- NA      # NoData -9999 and non-forest zeros
plots[, agbd_obs := agbd]
cat("plots with valid GEDI AGBD:", sum(is.finite(plots$agbd_obs)), "of", nrow(plots), "\n")
print(summary(plots$agbd_obs))

covariates <- list(
  WATER_AET=file.path(BGI_DIR,"WATER_AET_conus.tif"), WATER_DEF=file.path(BGI_DIR,"WATER_DEF_conus.tif"),
  WATER_PET=file.path(BGI_DIR,"WATER_PET_conus.tif"), WATER_AI=file.path(BGI_DIR,"WATER_AI_conus.tif"),
  WATER_RATIO=file.path(BGI_DIR,"WATER_RATIO_conus.tif"), WATER_WD=file.path(BGI_DIR,"WATER_WD_conus.tif"),
  SRAD=file.path(BGI_DIR,"SRAD_conus.tif"), VPD_TC=file.path(BGI_DIR,"VPD_TC_conus.tif"),
  WIND=file.path(BGI_DIR,"WIND_conus.tif"), NDEP=file.path(BGI_DIR,"NDEP_conus.tif"),
  DIST_COAST=file.path(BGI_DIR,"DIST_COAST_KM_conus.tif"))
keep <- names(covariates)[sapply(covariates, file.exists)]
stk  <- rast(unlist(covariates[keep])); names(stk) <- keep
xy   <- as.matrix(plots[, .(LON, LAT)])
plots <- cbind(plots, terra::extract(stk, xy))
plots[, pm_int := terra::extract(rast(PM_RASTER), xy)[[1]]]

predictors <- c(keep, "pm_int")
clim_only  <- intersect(c("WATER_AET","WATER_DEF","WATER_PET","SRAD","VPD_TC","WATER_AI"), keep)
target <- "agbd_obs"
ok <- complete.cases(plots[, c(target, predictors), with=FALSE]) & is.finite(plots[[target]]) & plots[[target]] > 0
train <- plots[ok, c(target, predictors), with=FALSE]; setnames(train, target, "y")
train[, pm_int := as.factor(pm_int)]
cat("Training n =", nrow(train), "\n")

m_full <- ranger(y ~ ., data=train, num.trees=500, mtry=max(2,floor(length(predictors)/3)),
                 importance="impurity", num.threads=parallel::detectCores())
cat("v3 stack OOB R2:", round(m_full$r.squared,4), " RMSE:", round(sqrt(m_full$prediction.error),2), "Mg/ha\n")
saveRDS(m_full, file.path(WORK, "m_agbd_obs_v2.rds"))
imp <- data.table(variable=names(m_full$variable.importance), importance=as.numeric(m_full$variable.importance))
setorder(imp,-importance); imp[,rank:=.I]; fwrite(imp, file.path(WORK,"PIX11_agbd_obs_varimp.csv")); print(imp)

m_clim <- ranger(y ~ ., data=train[,c("y",clim_only),with=FALSE], num.trees=500,
                 mtry=max(2,floor(length(clim_only)/3)), num.threads=parallel::detectCores())
out <- data.table(target=target, units="Mg/ha", n_train=nrow(train),
  model=c("Climate-only baseline","v3 env stack (+ parent material)"),
  n_predictors=c(length(clim_only),length(predictors)),
  oob_r2=c(m_clim$r.squared,m_full$r.squared),
  oob_rmse=c(sqrt(m_clim$prediction.error),sqrt(m_full$prediction.error)),
  delta_r2=c(0,m_full$r.squared-m_clim$r.squared))
fwrite(out, file.path(WORK,"PIX12_agbd_obs_climate_vs_full.csv")); print(out)

pred_dt <- data.table(ID=plots$ID[ok], LAT=plots$LAT[ok], LON=plots$LON[ok],
                      obs=train$y, pred=m_full$predictions, pm_int=plots$pm_int[ok])
fwrite(pred_dt, file.path(WORK,"PIX22_agbd_predictions.csv"))
cat("\n=== DONE GEDI AGBD ===\n")
