#!/bin/bash
#SBATCH --job-name=clair3_train_hg001
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --output=%x.out
#SBATCH --gres=gpu:4
#SBATCH --partition=rtx8000
#SBATCH --mem=32GB
#SBATCH --time=02:00:00
#SBATCH --mail-user=sb7580@nyu.edu
#SBATCH --mail-type=ALL

singularity exec --nv --overlay /scratch/sb7580/Project/clair3_hg001.ext3:rw \
 /scratch/work/public/singularity/cuda9.2.148-cudnn7.6.5.32-devel-ubuntu18.04.6.sif /bin/bash \
 -c "source /ext3/env.sh && /scratch/sb7580/HPMLProject/Clair3Proj/pileup_training_hg001.sh && /bin/bash -norc;"
