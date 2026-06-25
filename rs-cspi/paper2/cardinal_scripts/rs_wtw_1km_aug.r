#!/usr/bin/env Rscript
# Augmented 1 km wall-to-wall consensus: ClimateNA (32) + aligned terrain/soil/canopy (11).
# Saves the fitted ranger models so the 30 m tiled step can reuse them.
suppressPackageStartupMessages({ library(terra); library(data.table); library(ranger) })
terraOptions(memfrac=0.7); set.seed(1337)
RST <- "/fs/scratch/PUOM0008/crsfaaron/rs_target"
OUT <- file.path(RST,"wtw1km_aug"); dir.create(file.path(OUT,"thumbs"), recursive=TRUE, showWarnings=FALSE)
CLIM <- "/users/PUOM0008/crsfaaron/SiteIndex/rasters/ClimateNA/Normal_1991_2020_bioclim"
AL1  <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v3/aligned_1km"
FOREST1KM <- "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_V3_CONUS_1km_forest.tif"

grid <- rast(FOREST1KM); forest <- !is.na(values(grid)[,1])
cat("forest cells:", sum(forest), "\n")

cat("=== ClimateNA -> grid ===\n")
cf <- list.files(CLIM, pattern="\\.tif$", full.names=TRUE)
cl <- project(rast(cf), grid, method="bilinear", threads=TRUE); names(cl) <- gsub("Normal_1991_2020_|\\.tif","",basename(cf))

cat("=== aligned terrain/soil/canopy (same 1km grid) ===\n")
af <- list.files(AL1, pattern="\\.tif$", full.names=TRUE)
al <- rast(af); names(al) <- gsub("\\.tif","",basename(af))
al <- resample(al, grid, method="bilinear")              # ensure identical grid
P <- as.data.table(values(cl)); Pa <- as.data.table(values(al))
P <- cbind(P, Pa); pnames <- c(names(cl), names(al))
cat("total predictors:", length(pnames), "\n")

cat("=== targets -> grid ===\n")
npp <- resample(rast(file.path(RST,"wtw/MODIS_NPP_conus_5km.tif")), grid, method="bilinear")
agbd<- project(rast(file.path(RST,"gedi_l4b/GEDI04_B_MW019MW223_02_002_02_R01000M_MU.tif")), grid, method="bilinear")
c16 <- project(rast(file.path(RST,"cms_conus/CONUS_agb_2016_v1.tif")), grid, method="bilinear")
c05 <- project(rast(file.path(RST,"cms_conus/CONUS_agb_2005_v1.tif")), grid, method="bilinear")
P[, npp:=values(npp)[,1]][, agbd:=values(agbd)[,1]][, cms16:=values(c16)[,1]][, chg:=values(c16)[,1]-values(c05)[,1]][, cell:=.I]
for (c in c("npp","agbd","cms16")) P[get(c)<=0,(c):=NA]
env_ok <- complete.cases(P[, ..pnames]); pred_cells <- which(forest & env_ok)
cat("prediction domain:", length(pred_cells), "\n")

targets <- c(npp="g C m-2 yr-1", agbd="Mg ha-1", cms16="biomass", chg="biomass change")
oob <- list(); preds <- data.table(cell=pred_cells)
for (tg in names(targets)) {
  rows <- pred_cells[ is.finite(P[[tg]][pred_cells]) ]; if (tg!="chg") rows <- rows[P[[tg]][rows]>0]
  if (length(rows)>250000) rows <- sample(rows,250000)
  tr <- P[rows, c(tg,pnames), with=FALSE]; setnames(tr,tg,"y")
  m <- ranger(y~., tr, num.trees=300, mtry=floor(length(pnames)/3), num.threads=parallel::detectCores())
  saveRDS(m, file.path(OUT, paste0("m_",tg,"_aug.rds")))
  preds[, (tg) := predict(m, data=P[pred_cells, ..pnames])$predictions]
  oob[[tg]] <- data.table(target=tg, n_train=nrow(tr), oob_r2=round(m$r.squared,4))
  cat(sprintf("%-7s n=%d OOB R2=%.4f\n", tg, nrow(tr), m$r.squared))
}
oob <- rbindlist(oob); fwrite(oob, file.path(OUT,"WTW1kmAUG_oob_summary.csv")); print(oob)
saveRDS(pnames, file.path(OUT,"predictor_names.rds"))

zc <- names(targets); Z <- preds[, lapply(.SD, function(x) as.numeric(scale(x))), .SDcols=zc]
preds[, consensus_z := rowMeans(as.matrix(Z), na.rm=TRUE)]
preds[, agreement_sd := apply(as.matrix(Z),1,sd,na.rm=TRUE)]
lo <- quantile(preds$consensus_z,0.01,na.rm=TRUE); hi <- quantile(preds$consensus_z,0.99,na.rm=TRUE)
preds[, consensus_idx := pmin(100,pmax(0,100*(consensus_z-lo)/(hi-lo)))]
wr <- function(col,f){ r<-grid; values(r)<-NA_real_; v<-values(r); v[preds$cell]<-preds[[col]]; values(r)<-v; names(r)<-col
  writeRaster(r, file.path(OUT,f), overwrite=TRUE, gdal=c("COMPRESS=DEFLATE")); r }
r_idx <- wr("consensus_idx","WTW_consensus_productivity_idx_1km_aug.tif"); wr("agreement_sd","WTW_consensus_agreement_sd_1km_aug.tif")
png(file.path(OUT,"WTW1kmAUG_F1_consensus_map.png"), width=1900,height=1200,res=150)
plot(r_idx, main="Wall-to-wall consensus productivity index, 1 km (climate + terrain + soil + canopy)", col=hcl.colors(100,"Viridis")); dev.off()
png(file.path(OUT,"thumbs/WTW1kmAUG_F1_thumb.png"), width=820,height=520,res=72)
plot(r_idx, main="Consensus 1 km augmented", col=hcl.colors(100,"Viridis")); dev.off()
cat("\n=== DONE 1km augmented ===\n")
