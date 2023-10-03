#!/bin/bash

#SBATCH --job-name=gnn
#SBATCH --open-mode=truncate
#SBATCH --output=output_file
#SBATCH --error=error_file
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=2G
#SBATCH --time=01:00:00


export OMP_NUM_THREADS=32
python3 train.py
