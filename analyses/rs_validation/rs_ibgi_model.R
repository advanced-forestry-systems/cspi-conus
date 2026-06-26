#!/usr/bin/env Rscript
# iBGI for CONUS: quantify how much Sentinel-2 improves a biomass-productivity model
# beyond BGI, following Lamb et al. (2020, Remote Sensing 12(12):2056). Calibrates to
# observed MODIS GPP (the strongest external flux signal) as the productivity reference.
# Two RF models, with plot-blocked 5-fold CV and spatial latitude-fold CV (project
# convention). Saves the BGI+S2 model for the CONUS iBGI surface prediction.
set.seed(20260621)
suppressWarnings(suppressMessages({ library(data.table); library(ranger) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
V7   <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
say  <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

core <- fread(file.path(V7,"cspi_4c_plot_values.csv"))[, .(ID,LAT,LON,bgi,asym,SI,cspi_4c_0100)]
s2   <- fread(file.path(V7,"rs_s2_extract.csv"))[, lapply(.SD,function(z) if(all(is.na(z))) NA_real_ else mean(z,na.rm=TRUE)),
              by=ID, .SDcols=c("ndvi","evi","ndre","s2rep","cire")]
mod  <- fread(file.path(V7,"rs_mod17_extract.csv"))[, lapply(.SD,function(z) if(all(is.na(z))) NA_real_ else mean(z,na.rm=TRUE)),
              by=ID, .SDcols=c("gpp_mean","npp_mean")]
setnames(mod, c("gpp_mean","npp_mean"), c("gpp_obs","npp_obs"))
dt <- Reduce(function(a,b) merge(a,b,by="ID",all.x=TRUE), list(core,s2,mod))
dt <- dt[is.finite(bgi)&is.finite(gpp_obs)&is.finite(s2rep)&is.finite(ndvi)&is.finite(LAT)]
say("complete-case plots = ", nrow(dt))

S2 <- c("ndvi","evi","ndre","s2rep","cire")
cvR2 <- function(form, data, folds){
  pr <- rep(NA_real_, nrow(data))
  for (f in sort(unique(folds))){
    tr <- folds!=f; te <- folds==f
    m <- ranger(form, data=data[tr], num.trees=400, num.threads=4, seed=1)
    pr[te] <- predict(m, data[te])$predictions
  }
  obs <- data[[all.vars(form)[1]]]
  1 - sum((obs-pr)^2)/sum((obs-mean(obs))^2)
}
set.seed(1); pb <- sample(rep(1:5, length.out=nrow(dt)))
dt[, latband := as.integer(cut(LAT, quantile(LAT, 0:5/5), include.lowest=TRUE))]

f_base <- as.formula("gpp_obs ~ bgi")
f_ibgi <- as.formula(paste("gpp_obs ~ bgi +", paste(S2, collapse=" + ")))

res <- data.table(
  model   = c("BGI (baseline)","BGI + Sentinel-2 (iBGI)"),
  cv_plot = c(cvR2(f_base, dt, pb),  cvR2(f_ibgi, dt, pb)),
  cv_spatial = c(cvR2(f_base, dt, dt$latband), cvR2(f_ibgi, dt, dt$latband)))
res[, delta_plot := cv_plot - cv_plot[1]]
fwrite(res, file.path(WORK,"iBGI_cv_results.csv"))
say("iBGI CV results:"); print(res)

# full-data iBGI model + importance, saved for surface prediction
m_ibgi <- ranger(f_ibgi, data=dt, num.trees=800, importance="permutation", num.threads=4, seed=7)
imp <- data.table(variable=names(m_ibgi$variable.importance),
                  importance=as.numeric(m_ibgi$variable.importance))[order(-importance)]
fwrite(imp, file.path(WORK,"iBGI_variable_importance.csv"))
say("iBGI importance:"); print(imp)
saveRDS(m_ibgi, file.path(WORK,"m_ibgi_gpp.rds"))
say("OOB R2 (iBGI) = ", round(m_ibgi$r.squared,3))

# iBGI plot index (fitted) for distribution check
dt[, ibgi := m_ibgi$predictions]
fwrite(dt[, .(ID,LAT,LON,bgi,ibgi,gpp_obs,s2rep)], file.path(WORK,"iBGI_plot_values.csv"))
say("Job iBGI complete"); cat("DONE\n", file=file.path(WORK,"_ibgi_status.txt"))
