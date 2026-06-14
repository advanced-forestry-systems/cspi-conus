#!/bin/bash
#SBATCH --job-name=cspi3c_fm
#SBATCH --time=03:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_fm_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_fm_%j.err
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0

# Forest-mask the 3-component composite using the same Hansen tree cover mask used for 4-component
# Input: CSPI_v21_3component_30m.tif (42.5 GB)
# Mask: same forest mask layer that produced CSPI_v2_4component_30m_forest.tif (Hansen >= 30% tree cover at 30m, EPSG:5070)
# Output: CSPI_v21_3component_30m_forest.tif

SRC=/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif
OUT=/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m_forest.tif

# Reuse the same forest-mask file already used for 4c. Should live alongside.
# Find candidate masks first.
echo "Searching for forest mask raster..."
FM=$(ls /fs/scratch/PUOM0008/crsfaaron/cspi_v7/forest_mask*.tif 2>/dev/null | head -1)
if [ -z "$FM" ]; then
  FM=$(ls /fs/scratch/PUOM0008/crsfaaron/forest_mask*.tif 2>/dev/null | head -1)
fi
if [ -z "$FM" ]; then
  echo "ERROR: no forest_mask*.tif found; cannot proceed"
  exit 1
fi
echo "Using forest mask: $FM"

# Use gdal_calc to mask. tree-cover >= 30 → keep; else → NA
Rscript --vanilla -e "
library(terra)
src <- rast('$SRC')
fm <- rast('$FM')
cat('SRC:', dim(src), 'res:', res(src), 'crs:', crs(src, describe=TRUE)[[1]], '\n')
cat('FM :', dim(fm),  'res:', res(fm),  'crs:', crs(fm, describe=TRUE)[[1]], '\n')

# Reproject mask if needed
if (!compareGeom(src, fm, stopOnError=FALSE)) {
  cat('Resampling forest mask to src grid...\n')
  fm <- project(fm, src, method='near', threads=TRUE)
}

# Mask: where fm==0 or NA -> NA
out <- mask(src, fm, maskvalues=c(0, NA), updatevalue=NA,
            filename='$OUT',
            wopt=list(gdal=c('COMPRESS=ZSTD','TILED=YES','BIGTIFF=YES'),
                      datatype='FLT4S'))
cat('Wrote: $OUT\n')
print(global(out, c('min','max','mean'), na.rm=TRUE))
"
echo "Done."
