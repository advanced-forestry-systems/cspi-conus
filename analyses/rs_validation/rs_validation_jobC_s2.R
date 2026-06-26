#!/usr/bin/env Rscript
# Job C: add Sentinel-2 spectral metrics to the validation, following Hember and
# Weiskittel (2020), Remote Sensing 12(12):2056, which identified the Sentinel-2
# red-edge position (S2REP) as the most important RS metric for site productivity and
# used Sentinel-2 to improve BGI (iBGI). Here we test, at CONUS scale:
#   (a) how each productivity measure (ESI, BGI, Asym, composite) relates to S2 metrics
#   (b) whether S2REP improves prediction of observed MODIS GPP beyond BGI (iBGI logic)
# On-disk only (rs_s2_extract.csv). Seed set. Errors -> error_log_C.txt.
set.seed(20260621)
suppressWarnings(suppressMessages({ library(data.table); library(ggplot2) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
V7   <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
say  <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

base <- fread(file.path(WORK, "plots_validation_dedup.csv"))   # measures + flux + ch by ID
s2   <- fread(file.path(V7, "rs_s2_extract.csv"))
s2   <- s2[, lapply(.SD, function(z) if (all(is.na(z))) NA_real_ else mean(z, na.rm=TRUE)),
           by = ID, .SDcols = c("ndvi","evi","ndre","s2rep","cire")]
dt <- merge(base, s2, by = "ID", all.x = TRUE)
say("joined; plots with S2REP = ", sum(is.finite(dt$s2rep)))

measures <- c(ESI="SI", BGI="bgi", Asym="asym", NPP_miami="npp_miami", Composite="cspi_4c_0100")
observed <- c(GPP_obs="gpp_obs", NPP_obs="npp_obs", NPP_obs_CV="npp_obs_cv", CanopyHt="ch_m",
              NDVI="ndvi", EVI="evi", NDRE="ndre", S2REP="s2rep", CIRE="cire")
measures <- measures[measures %in% names(dt)]; observed <- observed[observed %in% names(dt)]
rows <- list()
for (mn in names(measures)) for (on in names(observed)) {
  x <- dt[[measures[mn]]]; y <- dt[[observed[on]]]; ok <- is.finite(x)&is.finite(y); n <- sum(ok)
  rp <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="pearson")) else NA_real_
  rs <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="spearman")) else NA_real_
  rows[[paste(mn,on)]] <- data.table(measure=mn,observed=on,n=n,pearson=rp,spearman=rs)
}
cortab <- rbindlist(rows)
fwrite(cortab, file.path(WORK,"RS_validation_with_S2.csv"))
say("Correlations incl S2 written"); print(dcast(cortab, measure~observed, value.var="pearson"))

# iBGI logic: does S2REP add to BGI in predicting observed GPP? and observed NPP?
sub <- dt[is.finite(gpp_obs)&is.finite(bgi)&is.finite(s2rep)&is.finite(npp_obs)]
ib <- data.table(
  target = c("GPP_obs","GPP_obs","GPP_obs","NPP_obs","NPP_obs","NPP_obs"),
  model  = c("BGI","S2REP","BGI+S2REP","BGI","S2REP","BGI+S2REP"),
  adj_r2 = c(
    summary(lm(gpp_obs~bgi,sub))$adj.r.squared,
    summary(lm(gpp_obs~s2rep,sub))$adj.r.squared,
    summary(lm(gpp_obs~bgi+s2rep,sub))$adj.r.squared,
    summary(lm(npp_obs~bgi,sub))$adj.r.squared,
    summary(lm(npp_obs~s2rep,sub))$adj.r.squared,
    summary(lm(npp_obs~bgi+s2rep,sub))$adj.r.squared),
  n = nrow(sub))
fwrite(ib, file.path(WORK,"S2REP_iBGI_increment.csv"))
say("iBGI increment (n=",nrow(sub),"):"); print(ib)

# comprehensive journal figure
w <- dcast(cortab, measure~observed, value.var="pearson")
mlev <- c("BGI","Composite","Asym","NPP_miami","ESI")
olev <- c("GPP_obs","NPP_obs","NPP_obs_CV","CanopyHt","S2REP","NDRE","CIRE","EVI","NDVI")
olab <- c("Obs GPP","Obs NPP","NPP CV","Canopy ht","S2REP","NDRE","CIRE","EVI","NDVI")
ct <- melt(w, id.vars="measure", variable.name="observed", value.name="r")
ct[, measure := factor(measure, levels=mlev)]
ct[, observed := factor(observed, levels=olev, labels=olab)]
g <- ggplot(ct, aes(observed, measure, fill=r)) +
  geom_tile(color="white", linewidth=0.5) +
  geom_text(aes(label=sprintf("%.2f", r)), size=3.1) +
  scale_fill_gradient2(low="#2c7bb6", mid="grey95", high="#d7191c", midpoint=0, limits=c(-0.8,0.8), name="Pearson r") +
  labs(x=NULL, y=NULL,
       title="Productivity measures vs observed satellite metrics (CONUS FIA plots)",
       subtitle="MODIS flux, LANDFIRE canopy height, and Sentinel-2 indices incl. red-edge position (S2REP)") +
  theme_minimal(base_size=11) +
  theme(axis.text.x=element_text(angle=30,hjust=1), panel.grid=element_blank(),
        plot.title=element_text(face="bold",size=11.5))
ggsave(file.path(WORK,"F_rs_validation_full.png"), g, width=9.5, height=4.2, dpi=300)
say("Job C complete"); cat("DONE\n", file=file.path(WORK,"_jobC_status.txt"))
