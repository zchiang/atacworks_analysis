
# loop through lineage-primed HSC subsamples

for bw_file in cell_tracks_combined/run1_cell*id[738]*; do

	#echo $bw_file
	prefix=`echo $bw_file | grep -o -P "run1_cell[0-9]+_id[0-9]+_050" | head -1`
	chrs=`cat combined_gene_regions.txt | cut -f1 | cut -f1 -d " " | sort | uniq | sort -V`

	# submit one job per chromosome

	for chrom in $chrs; do

		echo $prefix $chrom
		sbatch --job-name=$chron.$prefix --output=$home_dir/sig_logs/$prefix.$chrom.out --error=$home_dir/sig_logs/$prefix.$chrom.err --export=ALL,prefix=$prefix,chrom=$chrom --open-mode=truncate 04_calc_sig.sbatch
	done
done

