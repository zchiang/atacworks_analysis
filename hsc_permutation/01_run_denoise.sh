
# run lineage-primed HSC subsamples

prefix='run1_cell001_id8828_050'
sbatch --job-name=$prefix --output=$home_dir/logs/$prefix.out --error=$home_dir/logs/$prefix.err --export=ALL,run='run1',prefix=$prefix,intervals='combined_gene_intervals.bed',model='model_best.pth.tar' --open-mode=truncate 01_denoise_cell.sbatch

prefix='run1_cell002_id3951_050'
sbatch --job-name=$prefix --output=$home_dir/logs/$prefix.out --error=$home_dir/logs/$prefix.err --export=ALL,run='run1',prefix=$prefix,intervals='combined_gene_intervals.bed',model='model_best.pth.tar' --open-mode=truncate 01_denoise_cell.sbatch

prefix='run1_cell003_id7096_050'
sbatch --job-name=$prefix --output=$home_dir/logs/$prefix.out --error=$home_dir/logs/$prefix.err --export=ALL,run='run1',prefix=$prefix,intervals='combined_gene_intervals.bed',model='model_best.pth.tar' --open-mode=truncate 01_denoise_cell.sbatch

# run permutations (50 per job)

for bot in {0..999..50}; do

	top=$(($bot+49))
	echo $bot $top
	
	sbatch --job-name=$bot.$top --output=$home_dir/logs/$bot.$top.out --error=$home_dir/logs/$bot.$top.err --export=ALL,run='run1',bot=$bot,top=$top,intervals='combined_gene_intervals.bed',model='model_best.pth.tar' --open-mode=truncate 01_denoise_rand.sbatch

done


