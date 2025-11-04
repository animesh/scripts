#!/bin/bash -l
#SBATCH --job-name=gpuTestDnovo
#Project account
#SBATCH --account=nn9036k
#SBATCH --output=gpuTestDnovo.log
#SBATCH --error=error.log
#SBATCH --time=0:30:00
#SBATCH --partition=accel
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --gpus=1
nvidia-smi --query-gpu=timestamp,utilization.gpu,utilization.memory --format=csv -l 1 > gpu_usage.csv & 
GPU_MONITOR_PID=$!
/cluster/home/ash022/.local/bin/casanovo sequence 251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.4522wq.mgf 
kill $GPU_MONITOR_PID


