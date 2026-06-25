#!/usr/bin/env Rscript
# NASA-CMS CONUS biomass targets. Two targets:
#   cms_agb16  = aboveground biomass level, 2016 (Mg/ha)
#   cms_agbchg = biomass change 2005 -> 2016 (Mg/ha), a direct change-rate dimension
# Fit the v3 environmental stack against each, as for the other targets.

suppressPackageStartupMessages({ library(data.table); library(terra); library(ranger) })
WORK    <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
CMS     <- file.path(WORK, "cms_conus")
BGI_DIR <- "/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/rasters_bgi"
PLOTS   <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation/plots_validation_joined.csv"
PM_RASTER <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v6_geol/parent_material_30m_CONUS_4326.tif"
set.seed(1337)

plots <- fread(PLOTS)
r05 <- rast(file.path(CMS, "CONUS_agb_2005_v1.tif"))
r16 <- rast(file.path(CMS, "CONUS_agb_2016_v1.tif"))
cat("CMS CRS:", crs(r16, describe=TRUE)$code, " res:", res(r16)[1], "\n")
pts  <- vect(as.data.frame(plots[, .(LON,LAT)]), geom=c("LON","LAT"), crs="EPSG:4326")
ptsp <- project(pts, crs(r16))
a05 <- terra::extract(r05, ptsp)[[2]]
a16 <- terra::extract(r16, ptsp)[[2]]
a05[a05 < 0] <- NA; a16[a16 < 0] <- NA
plots[, cms_agb16  := a16]
plots[, cms_agbchg := a16 - a05]
cat("valid agb16:", sum(is.finite(plots$cms_agb16)),
    " valid change:", sum(is.finite(plots$cms_agbchg)), "\n")

covariates <- list(
  WATER_AET=file.path(BGI_DIR,"WATER_AET_conus.tif"), WATER_DEF=file.path(BGI_DIR,"WATER_DEF_conus.tif"),
  WATER_PET=file.path(BGI_DIR,"WATER_PET_conus.tif"), WATER_AI=file.path(BGI_DIR,"WATER_AI_conus.tif"),
  WATER_RATIO=file.path(BGI_DIR,"WATER_RATIO_conus.tif"), WATER_WD=file.path(BGI_DIR,"WATER_WD_conus.tif"),
  SRAD=file.path(BGI_DIR,"SRAD_conus.tif"), VPD_TC=file.path(BGI_DIR,"VPD_TC_conus.tif"),
  WIND=file.path(BGI_DIR,"WIND_conus.tif"), NDEP=file.path(BGI_DIR,"NDEP_conus.tif"),
  DIST_COAST=file.path(BGI_DIR,"DIST_COAST_KM_conus.tif"))
keep <- names(covariates)[sapply(covariates, file.exists)]
stk  <- rast(unlist(covariates[keep])); names(stk) <- keep
xy   <- as.matrix(plots[, .(LON,LAT)])
plots <- cbind(plots, terra::extract(stk, xy))
plots[, pm_int := terra::extract(rast(PM_RASTER), xy)[[1]]]
predictors <- c(keep, "pm_int")
clim_only  <- intersect(c("WATER_AET","WATER_DEF","WATER_PET","SRAD","VPD_TC","WATER_AI"), keep)

fit_one <- function(target, units, allow_neg=FALSE) {
  cat("\n==== TARGET", target, "====\n")
  good <- complete.cases(plots[, c(target, predictors), with=FALSE]) & is.finite(plots[[target]])
  if (!allow_neg) good <- good & plots[[target]] > 0
  tr <- plots[good, c(target, predictors), with=FALSE]; setnames(tr, target, "y")
  tr[, pm_int := as.factor(pm_int)]
  cat("n =", nrow(tr), "\n")
  mf <- ranger(y~., data=tr, num.trees=500, mtry=max(2,floor(length(predictors)/3)),
               importance="impurity", num.threads=parallel::detectCores())
  mc <- ranger(y~., data=tr[,c("y",clim_only),with=FALSE], num.trees=500,
               mtry=max(2,floor(length(clim_only)/3)), num.threads=parallel::detectCores())
  cat("v3 OOB R2:", round(mf$r.squared,4), " clim:", round(mc$r.squared,4), "\n")
  saveRDS(mf, file.path(WORK, paste0("m_",target,"_v2.rds")))
  imp <- data.table(variable=names(mf$variable.importance), importance=as.numeric(mf$variable.importance))
  setorder(imp,-importance); imp[,rank:=.I]; fwrite(imp, file.path(WORK,paste0("PIX11_",target,"_varimp.csv")))
  fwrite(data.table(ID=plots$ID[good], LAT=plots$LAT[good], LON=plots$LON[good],
                    obs=tr$y, pred=mf$predictions, pm_int=plots$pm_int[good]),
         file.path(WORK, paste0("PIX22_",target,"_predictions.csv")))
  data.table(target=target, units=units, n_train=nrow(tr),
             oob_r2_full=mf$r.squared, oob_r2_clim=mc$r.squared,
             delta_r2=mf$r.squared-mc$r.squared, rmse_full=sqrt(mf$prediction.error))
}
summ <- rbindlist(list(
  fit_one("cms_agb16",  "Mg/ha"),
  fit_one("cms_agbchg", "Mg/ha 2005-2016", allow_neg=TRUE)
))
fwrite(summ, file.path(WORK, "PIX15_cms_oob_summary.csv"))
cat("\n=== CMS SUMMARY ===\n"); print(summ); cat("\n=== DONE ===\n")
