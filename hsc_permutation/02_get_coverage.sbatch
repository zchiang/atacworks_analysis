#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH -n 1
#SBATCH -t 0-00:10          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --mem=500           # Memory pool for all cores (see also --mem-per-cpu)

# initialize environment

module load Anaconda
source activate AtacWorks

# loop through permuted samples

for j in $(seq $bot $top); do

	i=$(printf "%03d" $j)
	echo $i
	bin/bigWigToBedGraph perm_tracks/run1_rand$i"_"050_run1_rand$i"_"050_1M_pretrained.track.bw tmp/rand$i.bed
	cut tmp/rand$i.bed -f4 | paste -sd+ | bc >> norm_perm_tracks/run1_rand$i"_"050_run1_rand$i"_"050_1M_pretrained.coverage.txt
	rm tmp/rand$i.bed

done
