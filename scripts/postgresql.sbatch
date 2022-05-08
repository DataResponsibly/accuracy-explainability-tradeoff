#!/bin/bash

#SBATCH --job-name=postgres
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --nodes=1
#SBATCH --mem=8GB
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --dependency=singleton

srun echo $SLURM_NODELIST > postgres_node.txt
export DB_DIR='/scratch/isk273/db'

module purge
module load postgresql/intel/13.2

postgres -i -D $DB_DIR