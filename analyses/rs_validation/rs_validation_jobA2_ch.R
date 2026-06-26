#!/usr/bin/env Rscript
# Job A2: fix LANDFIRE 2023 canopy-height extraction at FIA plots (classified product),
# join to existing validation table, recompute correlations incl. canopy height, and
# regenerate the full heatmap. Flat script, no locked-binding reassignment.

set.seed(20260621)
suppressWarnings(suppressMessages({ library(data.table); library(terra) }))

WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
LF   <- "/fs/scratch/PUOM0008/crsfaaron/sae-aux/landfire/LF2023_CH_CONUS.tif"
LFL  <- "/fs/scratch/PUOM0008/crsfaaron/sae-aux/landfire/LF2023_CH.csv"
elog <- file.path(WORK, "error_log_A2.txt")
say  <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(), "%H:%M:%S"), paste0(...)))

dt <- fread(file.path(WORK, "plots_validation_joined.csv"))
say("Loaded joined table n = ", nrow(dt))

# Build legend map VALUE -> midpoint meters from the METERS column
leg <- fread(LFL)
setnames(leg, names(leg), trimws(names(leg)))
vcol <- names(leg)[grepl("VALUE", toupper(names(leg)))][1]
mcol <- names(leg)[toupper(names(leg)) == "METERS"][1]
parse_mid <- function(s){
  if (grepl("Non-Forest|Fill|NoData", s, ignore.case = TRUE)) return(NA_real_)
  n <- as.numeric(regmatches(s, gregexpr("[0-9]+\\.?[0-9]*", s))[[1]])
  if (length(n) >= 2) mean(n[1:2]) else if (length(n) == 1) n[1] + 2 else NA_real_
}
legmap <- data.table(ch_class = as.integer(leg[[vcol]]),
                     ch_m = vapply(as.character(leg[[mcol]]), parse_mid, numeric(1)))
say("Legend midpoints built: ", paste(na.omit(legmap$ch_m), collapse = ", "))

# Extract LANDFIRE CH class at plot coords (reproject points to raster CRS)
r   <- rast(LF)
pts <- vect(data.frame(ID = dt$ID, x = dt$LON, y = dt$LAT),
            geom = c("x", "y"), crs = "EPSG:4326")
pts <- project(pts, crs(r))
ex  <- terra::extract(r, pts)
chv <- data.table(ID = dt$ID, ch_class = as.integer(ex[[2]]))
chv <- merge(chv, legmap, by = "ch_class", all.x = TRUE)
chv[ch_class <= 0 | is.na(ch_class), ch_m := NA_real_]
dt  <- merge(dt, chv[, .(ID, ch_class, ch_m)], by = "ID", all.x = TRUE)
say("CH extracted; forested non-NA = ", sum(is.finite(dt$ch_m)))
fwrite(dt, file.path(WORK, "plots_validation_joined.csv"))

# Correlations incl. canopy height
measures <- c(ESI="SI", BGI="bgi", Asym="asym", NPP_miami="npp_miami", Composite="cspi_4c_0100")
observed <- c(NPP_obs="npp_obs", NPP_obs_CV="npp_obs_cv", GPP_obs="gpp_obs", CanopyHt_LF2023="ch_m")
measures <- measures[measures %in% names(dt)]; observed <- observed[observed %in% names(dt)]
rows <- list()
for (mn in names(measures)) for (on in names(observed)) {
  x <- dt[[measures[mn]]]; y <- dt[[observed[on]]]; ok <- is.finite(x) & is.finite(y); n <- sum(ok)
  rp <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="pearson")) else NA_real_
  rs <- if (n>50) suppressWarnings(cor(x[ok],y[ok],method="spearman")) else NA_real_
  rows[[paste(mn,on)]] <- data.table(measure=mn, observed=on, n=n, pearson=rp, spearman=rs)
}
cortab <- rbindlist(rows)
fwrite(cortab, file.path(WORK, "RS_validation_correlations.csv"))
say("Wrote full correlation table"); print(dcast(cortab, measure ~ observed, value.var="spearman"))

# Which measure / combination best predicts observed canopy height?
sub <- dt[is.finite(ch_m) & is.finite(SI) & is.finite(bgi) & is.finite(asym)]
fit <- list()
for (mn in names(measures)) {
  f <- tryCatch(lm(ch_m ~ get(measures[mn]), data=sub), error=function(e) NULL)
  if (!is.null(f)) fit[[mn]] <- data.table(model=mn, adj_r2=summary(f)$adj.r.squared)
}
fj <- tryCatch(lm(ch_m ~ SI + bgi + asym, data=sub), error=function(e) NULL)
if (!is.null(fj)) fit[["ESI+BGI+Asym"]] <- data.table(model="ESI+BGI+Asym", adj_r2=summary(fj)$adj.r.squared)
fc <- tryCatch(lm(ch_m ~ cspi_4c_0100, data=sub), error=function(e) NULL)
chtab <- rbindlist(fit)
fwrite(chtab, file.path(WORK, "CH_predictability.csv"))
say("CH predictability (n=", nrow(sub), "):"); print(chtab)

# Full heatmap incl canopy height
w <- dcast(cortab, measure ~ observed, value.var="spearman")
m <- as.matrix(w[, -1]); rownames(m) <- w$measure
png(file.path(WORK, "F_rs_validation_heatmap.png"), width=2000, height=1300, res=300)
par(mar=c(8,7,3,2))
image(t(m[nrow(m):1,,drop=FALSE]), axes=FALSE, col=hcl.colors(21,"Blue-Red 3"), zlim=c(-1,1))
axis(1, at=seq(0,1,length.out=ncol(m)), labels=colnames(m), las=2, cex.axis=0.7)
axis(2, at=seq(0,1,length.out=nrow(m)), labels=rev(rownames(m)), las=1, cex.axis=0.8)
title("Spearman: productivity measures vs observed repeat/structural RS", cex.main=0.95)
for (i in 1:nrow(m)) for (j in 1:ncol(m))
  text((j-1)/(ncol(m)-1), (nrow(m)-i)/(nrow(m)-1), sprintf("%.2f", m[i,j]), cex=0.75)
dev.off()

png(file.path(WORK, "F_ch_vs_measures.png"), width=2000, height=900, res=300)
par(mfrow=c(1,3), mar=c(4,4,2,1))
for (mn in c("BGI","ESI","Composite")) {
  s <- dt[is.finite(ch_m) & is.finite(get(measures[mn]))]; if (nrow(s)>4000) s <- s[sample(.N,4000)]
  plot(s[[measures[mn]]], s$ch_m, pch=16, cex=0.3, col=rgb(0,0.3,0.5,0.25),
       xlab=mn, ylab="LANDFIRE 2023 canopy height (m)", main=paste(mn,"vs canopy ht"))
  abline(lm(s$ch_m ~ s[[measures[mn]]]), col="red", lwd=2)
}
dev.off()
gc(); say("Job A2 complete."); cat("DONE\n", file=file.path(WORK,"_jobA2_status.txt"))
