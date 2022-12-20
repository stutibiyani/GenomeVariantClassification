#!/bin/sh
#SBATCH --job-name=clairvoyante-dataPrep-lastStep
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=%x.out
#SBATCH --mem=48GB
#SBATCH --time=10:00:00
#SBATCH --mail-user=mu2047@nyu.edu
#SBATCH --mail-type=ALL

module purge
module load anaconda3/2020.07
module load samtools/intel/1.14

cd /scratch/mu2047/Project/Clairvoyante/Clairvoyante/dataPrepScripts
python ../dataPrepScripts/PairWithNonVariants.py --tensor_can_fn ../training/tensor_can_mul_sampled --tensor_var_fn ../training/tensor_var_mul_sampled --bed_fn ../training/bed --output_fn ../training/tensor_can_mix_sampled --amp 2
echo "Command 1 done"
python ../clairvoyante/tensor2Bin.py --tensor_fn ../training/tensor_can_mix_sampled --var_fn ../training/var_mul_sampled --bed_fn ../training/bed --bin_fn ../training/tensor.bin
echo "Command 2 done"
echo "Step 5 done: tensor.bin creation done"