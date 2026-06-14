#!/bin/bash
#SBATCH --job-name=compilation_gada
#SBATCH --time=04:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/compilation_gada_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/compilation_gada_%j.err
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0
echo "=== Step 1: unified compilation SI join ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/compilation_si.r
echo "=== Step 2: GADA refit from NA_SITREE ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/gada_refit.r
echo "Done."
