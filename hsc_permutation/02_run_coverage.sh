
# loop through all permuted samples by 10

for bot in {0..999..10}; do

	top=$(($bot+9))
	echo $bot $top

	# submit 10 samples per job
	
	sbatch --job-name=$bot.$top.coverage --output=$home_dir/cov_logs/$bot.$top.out --error=$home_dir/cov_logs/$bot.$top.err --export=ALL,bot=$bot,top=$top --open-mode=truncate 02_get_coverage.sbatch
done

