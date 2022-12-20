#!/bin/bash
#SBATCH --job-name=hpml_proj_Clair3_train_HG002
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=%x.out
#SBATCH --mem=16GB
#SBATCH --time=02:00:00
#SBATCH --mail-user=sc8781@nyu.edu
#SBATCH --mail-type=ALL
#SBATCH --gres=gpu:4

singularity exec --overlay /scratch/sc8781/Project/environment/overlay-50G-10M.ext3:rw \
 /scratch/work/public/singularity/cuda11.2.2-cudnn8-devel-ubuntu20.04.sif /bin/bash \
 -c "source /ext3/env.sh && /scratch/sc8781/Project/Clair3Proj/pileup_training_HG2.sh && /bin/bash -norc;"
