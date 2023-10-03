#!/bin/bash

#SBATCH --job-name=gpu_check
#SBATCH --open-mode=truncate
#SBATCH --output=gpu_check_out.log
#SBATCH --error=gpu_check_err.log
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --time=00:10:00

#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=16G
#SBATCH --gpus=1


export OMP_NUM_THREADS=2
python3 -u -c "import torch; print(torch.cuda.is_available())"
