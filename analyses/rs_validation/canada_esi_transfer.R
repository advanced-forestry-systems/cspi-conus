#!/usr/bin/env Rscript
# Cross-border ESI transfer test. Does the CONUS-trained ClimateNA site-index model
# generalize into Canada? Train on CONUS plots (lat <= 49), predict Canadian plots
# (lat > 49), compare to within-CONUS cross-validated baseline. On-disk only (ALL_SI_m.csv).
set.seed(20260625)
suppressWarnings(suppressMessages({ library(data.table); library(ranger) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
F <- "/users/PUOM0008/crsfaaron/SiteIndex/ALL_SI_m.csv"
say <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

d <- fread(F)
if ("V1" %in% names(d)) d[, V1 := NULL]
setnames(d, names(d), trimws(names(d)))
d <- d[is.finite(SI) & is.finite(LAT) & is.finite(LON)]
# predictors: numeric climate covariates + ELEV; exclude identifiers and response
drop <- c("SOURCE","ID","SPCD","LAT","LON","SI","")
preds <- setdiff(names(d)[sapply(d, is.numeric)], drop)
d <- d[complete.cases(d[, ..preds])]
d[, region := ifelse(LAT > 49, "CAN", "CONUS")]
say("n total = ", nrow(d), " | CONUS = ", sum(d$region=="CONUS"), " | CAN = ", sum(d$region=="CAN"))
say("predictors (", length(preds), "): ", paste(head(preds,12), collapse=", "), " ...")

# SOURCE composition of the Canadian plots (which datasets already contribute)
if ("SOURCE" %in% names(d)) {
  src <- d[region=="CAN", .N, by=SOURCE][order(-N)]
  fwrite(src, file.path(WORK,"CANADA_esi_sources.csv")); say("Canadian-plot SOURCE counts:"); print(src)
}

r2 <- function(obs,pred) 1 - sum((obs-pred)^2)/sum((obs-mean(obs))^2)
rmse <- function(obs,pred) sqrt(mean((obs-pred)^2))
form <- as.formula(paste("SI ~", paste(preds, collapse=" + ")))

# 1) transfer: train CONUS, predict CAN
mC <- ranger(form, data=d[region=="CONUS"], num.trees=500, num.threads=4, seed=1)
pc <- predict(mC, d[region=="CAN"])$predictions
oc <- d[region=="CAN"]$SI
# 2) within-CONUS 5-fold CV baseline
set.seed(1); fold <- sample(rep(1:5, length.out=sum(d$region=="CONUS")))
dc <- d[region=="CONUS"]; prc <- rep(NA_real_, nrow(dc))
for (f in 1:5){ m <- ranger(form, data=dc[fold!=f], num.trees=400, num.threads=4, seed=1); prc[fold==f] <- predict(m, dc[fold==f])$predictions }
# 3) Canada internal 5-fold CV (ceiling if Canadian data used in training)
dn <- d[region=="CAN"]; set.seed(2); fn <- sample(rep(1:5, length.out=nrow(dn))); prn <- rep(NA_real_, nrow(dn))
for (f in 1:5){ m <- ranger(form, data=dn[fn!=f], num.trees=400, num.threads=4, seed=1); prn[fn==f] <- predict(m, dn[fn==f])$predictions }

res <- data.table(
  test = c("within-CONUS 5-fold CV (baseline)","CONUS-trained -> Canada (transfer)","within-Canada 5-fold CV (ceiling)"),
  n    = c(nrow(dc), nrow(dn), nrow(dn)),
  R2   = c(r2(dc$SI,prc), r2(oc,pc), r2(dn$SI,prn)),
  RMSE_m = c(rmse(dc$SI,prc), rmse(oc,pc), rmse(dn$SI,prn)),
  mean_SI = c(mean(dc$SI), mean(oc), mean(dn$SI)))
fwrite(res, file.path(WORK,"CANADA_esi_transfer.csv"))
say("Transfer results:"); print(res)

# transfer skill by Canadian latitude band
dn2 <- copy(d[region=="CAN"]); dn2[, pred := pc]
dn2[, band := cut(LAT, c(49,52,55,60,90), labels=c("49-52","52-55","55-60","60+"))]
byb <- dn2[, .(n=.N, R2=if(.N>50) r2(SI,pred) else NA_real_, RMSE=if(.N>50) rmse(SI,pred) else NA_real_, mean_SI=mean(SI)), by=band][order(band)]
fwrite(byb, file.path(WORK,"CANADA_esi_transfer_byband.csv")); say("Transfer by latitude band:"); print(byb)
say("Canada ESI transfer test complete."); cat("DONE\n", file=file.path(WORK,"_canada_status.txt"))
