#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH -n 4
#SBATCH -t 0-00:15          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --mem=4000           # Memory pool for all cores (see also --mem-per-cpu)

# load environment

module load Anaconda
source activate AtacWorks

# run region

echo $line $num_rand
region=`echo $line | cut -f1-3 -d ":" | sed 's/:/_/g' | sed 's/\n//g'`
time python 03_agg_region.py $line $num_rand > agg_regions/$region.txt

