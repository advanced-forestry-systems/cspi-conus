#!/usr/bin/env Rscript
# 30 m tiled prediction of the wall-to-wall consensus, reusing the augmented 1 km
# models. Args: xmin xmax ymin ymax tag. Builds the 43-predictor brick at 30 m for
# the window (aligned 30 m terrain/soil/canopy + ClimateNA resampled to 30 m),
# predicts each target, z-standardises with global params, and writes a 30 m
# consensus tile. The full CONUS run wraps this over a tile grid (SLURM array).
suppressPackageStartupMessages({ library(terra); library(data.table); library(ranger) })
terraOptions(memfrac=0.7)
a <- commandArgs(trailingOnly=TRUE)
xmin<-as.numeric(a[1]); xmax<-as.numeric(a[2]); ymin<-as.numeric(a[3]); ymax<-as.numeric(a[4]); tag<-a[5]
RST <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
MOD <- file.path(RST,"wtw1km_aug"); AL30 <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v3/aligned_30m"
CLIM<- "/users/PUOM0008/crsfaaron/SiteIndex/rasters/ClimateNA/Normal_1991_2020_bioclim"
AL1 <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v3/aligned_1km"
OUT <- file.path(RST,"wtw30m"); dir.create(file.path(OUT,"thumbs"), recursive=TRUE, showWarnings=FALSE)
win <- ext(xmin,xmax,ymin,ymax)
pnames <- readRDS(file.path(MOD,"predictor_names.rds"))
targets <- c("npp","agbd","cms16","chg")
models <- setNames(lapply(targets, function(t) readRDS(file.path(MOD,paste0("m_",t,"_aug.rds")))), targets)

# global z-params (mean/sd of predictions) computed once from a 1km sample, cached
zf <- file.path(MOD,"zparams.rds")
if (file.exists(zf)) { zp <- readRDS(zf) } else {
  set.seed(7); g1 <- rast(file.path(AL1,"elev.tif"))
  cl1 <- project(rast(list.files(CLIM,"\\.tif$",full.names=TRUE)), g1, method="bilinear"); names(cl1)<-gsub("Normal_1991_2020_|\\.tif","",basename(list.files(CLIM,"\\.tif$",full.names=TRUE)))
  al1 <- rast(list.files(AL1,"\\.tif$",full.names=TRUE)); names(al1)<-gsub("\\.tif","",basename(list.files(AL1,"\\.tif$",full.names=TRUE)))
  S <- as.data.table(spatSample(c(cl1,al1), 100000, "regular", as.df=TRUE, na.rm=TRUE))
  zp <- lapply(targets, function(t){ p<-predict(models[[t]], data=S[, ..pnames])$predictions; c(m=mean(p),s=sd(p)) })
  names(zp)<-targets; saveRDS(zp, zf)
}

cat("=== build 30 m predictor brick for tile", tag, "===\n")
al <- crop(rast(list.files(AL30,"\\.tif$",full.names=TRUE)), win); names(al)<-gsub("\\.tif","",basename(list.files(AL30,"\\.tif$",full.names=TRUE)))
cl <- project(rast(list.files(CLIM,"\\.tif$",full.names=TRUE)), al, method="bilinear"); names(cl)<-gsub("Normal_1991_2020_|\\.tif","",basename(list.files(CLIM,"\\.tif$",full.names=TRUE)))
brick <- c(cl, al)[[pnames]]
tmpl <- al[["h_tc2000"]]                      # lightweight output template
forest_ok <- values(tmpl)[,1] >= 10
dt <- as.data.table(values(brick))
ok <- complete.cases(dt) & (forest_ok %in% TRUE)
ncell_t <- nrow(dt)
cat("tile cells:", ncell_t, " forest+complete:", sum(ok,na.rm=TRUE), "\n")
rm(brick, cl, al, forest_ok); gc()

# chunked prediction to bound memory; accumulate consensus z online
Zsum <- numeric(ncell_t); Zn <- integer(ncell_t)
idx <- which(ok)
chunks <- split(idx, ceiling(seq_along(idx)/2e6))
for (t in targets) {
  for (ch in chunks) {
    pr <- predict(models[[t]], data=dt[ch, ..pnames])$predictions
    z <- (pr - zp[[t]]["m"]) / zp[[t]]["s"]
    Zsum[ch] <- Zsum[ch] + z; Zn[ch] <- Zn[ch] + 1L
  }
  gc()
}
cons <- ifelse(Zn>0, Zsum/Zn, NA_real_)
r <- tmpl; values(r) <- NA_real_; v<-values(r); v[]<-cons; values(r)<-v; names(r)<-"consensus_z"
writeRaster(r, file.path(OUT, paste0("WTW_consensus_z_30m_",tag,".tif")), overwrite=TRUE, gdal=c("COMPRESS=DEFLATE"))
png(file.path(OUT,"thumbs",paste0("tile_",tag,"_thumb.png")), width=700,height=600,res=80)
plot(r, main=paste("30 m consensus (z) tile",tag), col=hcl.colors(100,"Viridis")); dev.off()
cat("=== DONE tile", tag, "===\n")
