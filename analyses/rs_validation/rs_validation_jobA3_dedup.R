#!/usr/bin/env Rscript
# Job A3: deduplicate the join to one row per FIA plot ID (rs_mod17_extract had duplicate
# IDs causing a one-to-many expansion to 61,655 rows over 40,933 unique plots), then
# recompute correlations, CH predictability, and figures on the clean per-plot set.
set.seed(20260621)
suppressWarnings(suppressMessages({ library(data.table) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
say  <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

dt <- fread(file.path(WORK, "plots_validation_joined.csv"))
say("raw joined rows = ", nrow(dt), "; unique IDs = ", uniqueN(dt$ID))
# average any duplicated-ID rows for the RS columns; core measures are constant within ID
num <- c("SI","bgi","asym","npp_miami","cspi_4c_0100","npp_obs","npp_obs_cv","gpp_obs","ch_m")
num <- num[num %in% names(dt)]
dtu <- dt[, lapply(.SD, function(z) if (all(is.na(z))) NA_real_ else mean(z, na.rm=TRUE)),
          by = ID, .SDcols = num]
say("deduplicated rows = ", nrow(dtu))
fwrite(dtu, file.path(WORK, "plots_validation_dedup.csv"))

measures <- c(ESI="SI", BGI="bgi", Asym="asym", NPP_miami="npp_miami", Composite="cspi_4c_0100")
observed <- c(NPP_obs="npp_obs", NPP_obs_CV="npp_obs_cv", GPP_obs="gpp_obs", CanopyHt_LF2023="ch_m")
measures <- measures[measures %in% names(dtu)]; observed <- observed[observed %in% names(dtu)]
rows <- list()
for (mn in names(measures)) for (on in names(observed)) {
  x <- dtu[[measures[mn]]]; y <- dtu[[observed[on]]]; ok <- is.finite(x)&is.finite(y); n <- sum(ok)
  rp <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="pearson")) else NA_real_
  rs <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="spearman")) else NA_real_
  rows[[paste(mn,on)]] <- data.table(measure=mn,observed=on,n=n,pearson=rp,spearman=rs)
}
cortab <- rbindlist(rows)
fwrite(cortab, file.path(WORK,"RS_validation_correlations_dedup.csv"))
say("DEDUP correlations:"); print(cortab[order(measure,observed)])

sub <- dtu[is.finite(ch_m)&is.finite(SI)&is.finite(bgi)&is.finite(asym)]
fit <- rbindlist(c(
  lapply(names(measures), function(mn){ f<-lm(ch_m~get(measures[mn]),data=sub)
    data.table(model=mn, adj_r2=summary(f)$adj.r.squared)}),
  list(data.table(model="ESI+BGI+Asym", adj_r2=summary(lm(ch_m~SI+bgi+asym,data=sub))$adj.r.squared))))
fwrite(fit, file.path(WORK,"CH_predictability_dedup.csv"))
say("DEDUP CH predictability (n=",nrow(sub),"):"); print(fit)

w <- dcast(cortab, measure~observed, value.var="spearman"); m <- as.matrix(w[,-1]); rownames(m)<-w$measure
png(file.path(WORK,"F_rs_validation_heatmap.png"), width=2000, height=1300, res=300)
par(mar=c(8,7,3,2))
image(t(m[nrow(m):1,,drop=FALSE]),axes=FALSE,col=hcl.colors(21,"Blue-Red 3"),zlim=c(-1,1))
axis(1,at=seq(0,1,length.out=ncol(m)),labels=colnames(m),las=2,cex.axis=0.7)
axis(2,at=seq(0,1,length.out=nrow(m)),labels=rev(rownames(m)),las=1,cex.axis=0.8)
title(sprintf("Spearman: productivity vs observed RS (n=%d unique plots)", nrow(dtu)),cex.main=0.9)
for(i in 1:nrow(m))for(j in 1:ncol(m)) text((j-1)/(ncol(m)-1),(nrow(m)-i)/(nrow(m)-1),sprintf("%.2f",m[i,j]),cex=0.75)
dev.off()
say("Job A3 done"); cat("DONE\n", file=file.path(WORK,"_jobA3_status.txt"))
