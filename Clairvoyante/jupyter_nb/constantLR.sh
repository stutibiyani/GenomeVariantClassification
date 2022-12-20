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

module purge 
module load anaconda3/2020.07

cd /scratch/mu2047/Project/Clairvoyante/Clairvoyante/jupyter_nb/

python trainingScript.py