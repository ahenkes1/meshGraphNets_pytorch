#!/bin/bash

#SBATCH --job-name=gnn_batch_50
#SBATCH --open-mode=truncate
#SBATCH --output=out_batch_50.log
#SBATCH --error=err_batch_50.log
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --time=48:00:00

#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=16G

#SBATCH --gpus=a100-pcie-40gb:1

##SBATCH --gpus=a100_80gb:1
##SBATCH --gpus=quadro_rtx_6000:1
##SBATCH --gpus=gtx_1080_ti:1


export OMP_NUM_THREADS=6
python3 -u train.py
