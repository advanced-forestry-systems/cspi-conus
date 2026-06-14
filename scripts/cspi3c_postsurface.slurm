#!/bin/bash
#SBATCH --job-name=cspi3c_post
#SBATCH --time=04:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_post_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_post_%j.err
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0
echo "=== Step 1: forest mask 3c surface ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/mask_cspi3c.r
echo "=== Step 2: build F7 3c figure ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/fig_F7_3c.r
echo "Done."
