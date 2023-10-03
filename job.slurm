#!/bin/bash

#SBATCH --job-name=gnn
#SBATCH --open-mode=truncate
#SBATCH --output=out.log
#SBATCH --error=err.log
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --time=01:00:00

#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=16G
#SBATCH --gpus=gtx_1080_ti:1


export OMP_NUM_THREADS=2
python3 -u train.py
