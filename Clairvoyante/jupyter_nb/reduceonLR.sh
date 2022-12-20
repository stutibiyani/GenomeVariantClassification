#!/bin/sh
#SBATCH --job-name=clairvoyante-train1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=%x.out
#SBATCH --mem=48GB
#SBATCH --time=10:00:00
#SBATCH --mail-user=mu2047@nyu.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=rtx8000
#SBATCH --gres=gpu:1


cd /scratch/mu2047/Project/
singularity exec --nv --overlay /scratch/mu2047/Project/overlay-25GB-500K.ext3:rw   /scratch/work/public/singularity/cuda11.6.124-cudnn8.4.0.27-devel-ubuntu20.04.4.sif /bin/bash \
-c "source /ext3/env.sh && cd /scratch/mu2047/Project/Clairvoyante/Clairvoyante/jupyter_nb && python trainingScript.py --constant_lr False --reduce_after 10 --init_lr 0.003 --model_name ReduceAfter10_init_lr(0.003) && /bin/bash -norc"  