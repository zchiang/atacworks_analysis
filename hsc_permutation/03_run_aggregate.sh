
# loop through all regions

while IFS= read -r line; do

	region=`echo $line | cut -f1-3 -d " " | sed 's/ /_/g' | sed 's/\n//g'`
	echo Running $region
	line=`echo $line | cut -f1-8 -d " " | sed 's/ /:/g' | sed 's/\n//g'`

	sbatch --job-name=$region --output=$home_dir/agg_logs/$region.out --error=$home_dir/agg_logs/$region.err --export=ALL,line=$line,num_rand=1000 --open-mode=truncate 03_agg_region.sbatch

done < "combined_gene_regions.txt"


