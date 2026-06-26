#!/usr/bin/env Rscript
# Canonical reconciliation of the SITECLCD headline gap. The manuscript reports BGI alone
# OOB R^2 = 0.808 vs ESI alone 0.751 on the SITECLCD-complete set (n = 63,310). The earlier
# MAICF run used the narrower 4-component subset (n = 43,964) and found a near-tie. Resolve
# by running BOTH subsets with OOB, plot-blocked CV, and spatial latitude-fold CV, using one
# fixed ESI and BGI definition. Predicts SITECLCD (1:7) as the manuscript did.
set.seed(20260625)
suppressWarnings(suppressMessages({ library(data.table); library(ranger) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
F <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v2/plt_ext_4c_plus_FIA.csv"
say <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))
d0 <- fread(F)

cvR2 <- function(form, data, folds){
  pr <- rep(NA_real_, nrow(data))
  for (f in sort(unique(folds))){
    tr <- folds!=f
    m <- ranger(form, data=data[tr], num.trees=400, num.threads=4, seed=1)
    pr[folds==f] <- predict(m, data[folds==f])$predictions
  }
  y <- data[[all.vars(form)[1]]]; 1 - sum((y-pr)^2)/sum((y-mean(y))^2)
}
oob <- function(form,data){ ranger(form,data=data,num.trees=600,num.threads=4,seed=1)$r.squared }

run_subset <- function(d, label){
  d <- copy(d); set.seed(1)
  d[, pb := sample(rep(1:5, length.out=.N))]
  d[, latband := as.integer(cut(LAT, quantile(LAT,0:5/5), include.lowest=TRUE))]
  out <- rbindlist(lapply(c(BGI="bgi_v", ESI="esi"), function(v){
    f <- as.formula(paste("SITECLCD ~", v))
    data.table(predictor=v, oob_r2=oob(f,d), cv_plot=cvR2(f,d,d$pb), cv_spatial=cvR2(f,d,d$latband))
  }), idcol="measure")
  out[, subset := label][, n := nrow(d)]
  out
}

D_full <- d0[SITECLCD %in% 1:7 & is.finite(esi) & is.finite(bgi_v)]          # ~63,310 (manuscript)
D_4c   <- d0[SITECLCD %in% 1:7 & is.finite(esi) & is.finite(bgi_v) & is.finite(asym_v) & is.finite(npp_v) & SICOND>0]  # ~43,964
say("n full(SITECLCD+esi+bgi) = ", nrow(D_full), " ; n 4-component = ", nrow(D_4c))

res <- rbind(run_subset(D_full, "SITECLCD-complete (manuscript)"),
             run_subset(D_4c,   "4-component subset"))
setcolorder(res, c("subset","measure","predictor","n","oob_r2","cv_plot","cv_spatial"))
fwrite(res, file.path(WORK, "SITECLCD_reconcile.csv"))
say("Reconciliation:"); print(res)
# gap summary
for (s in unique(res$subset)){
  b <- res[subset==s & measure=="BGI"]; e <- res[subset==s & measure=="ESI"]
  say(sprintf("%s (n=%d): BGI-ESI gap  OOB %+.3f | plot-CV %+.3f | spatial %+.3f",
      s, b$n, b$oob_r2-e$oob_r2, b$cv_plot-e$cv_plot, b$cv_spatial-e$cv_spatial))
}
cat("DONE\n", file=file.path(WORK,"_reconcile_status.txt"))
