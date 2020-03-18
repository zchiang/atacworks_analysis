#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH -n 4
#SBATCH -t 0-01:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --mem=8000           # Memory pool for all cores (see also --mem-per-cpu)

# load environment

module load Anaconda
source activate AtacWorks

# make output directory

mkdir -p sig_tracks/$prefix

# run script and move output when complete

python 04_calc_sig.py $prefix combined_gene_regions.txt $chrom > tmp/$prefix.$chrom.txt
mv tmp/$prefix.$chrom.txt sig_tracks/$prefix/$chrom.txt

