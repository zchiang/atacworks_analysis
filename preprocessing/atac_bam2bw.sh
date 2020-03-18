#!/usr/bin/bash

# command line arguments

bam_file=$1
genome_file=$2
window_size=$3
output_dir=$4

# get prefix for naming output files

prefix=`basename -s .rmdup.bam $bam_file`

bed2bw="bedGraphToBigWig"
tmp_dir="/tmp/zchiang"
smooth_cutsites="get_smooth_cutsites.py"
sum_coverage="sum_coverage.py"

# index bam file

echo "Indexing $bam_file"
samtools index $bam_file

# loop through all chrs

chrs=`samtools view -H $bam_file | grep chr | cut -f2 | sed 's/SN://g' | grep -v chrM | awk '{if(length($0)<6)print}'`
sorted_chrs=`samtools view -H $bam_file | grep chr | cut -f2 | sed 's/SN://g' | grep -v chrM | awk '{if(length($0)<6)print}' | sort -k1,1`

echo "Finding cutsites, smoothing, and converting to coverage for each chromosome"

for chr in $chrs; do

	#echo $chr
	
	# create bed of smoothed cutsites
	python $smooth_cutsites <(samtools view $bam_file -F 16 -f 2 $chr) $genome_file $window_size > $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.bed

	# convert to coverage
	bedtools genomecov -i $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.bed -g $genome_file -bg > $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.coverage.bed

	# create control for peak calling

	coverage=`python $sum_coverage < $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.coverage.bed`
        chr_size=`cat $genome_file | grep -P "^$chr\t" | cut -f2`
        avg_coverage=`echo "scale = 5; $coverage/$chr_size" | bc`
        echo "Coverage: "$coverage", chr size: " $chr_size", per base coverage: "$avg_coverage
        echo -e "$chr\t0\t$chr_size\t$avg_coverage" > $tmp_dir/$prefix.$chr.control.bed

	# call peaks

	macs2 bdgcmp -t $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.coverage.bed -c $tmp_dir/$prefix.$chr.control.bed -m ppois -o $tmp_dir/$prefix.$chr.pvals.bed
        macs2 bdgpeakcall -i $tmp_dir/$prefix.$chr.pvals.bed -o $tmp_dir/$prefix.$chr.narrowPeak -c 3

done

#echo "Merging tracks and peaks for all chromosomes"

# cat in alphabetic order

> $tmp_dir/$prefix.cutsites.smoothed_$window_size.bed
> $tmp_dir/$prefix.narrowPeak
for chr in $sorted_chrs; do

	cat $tmp_dir/$prefix.$chr.cutsites.smoothed_$window_size.coverage.bed >> $tmp_dir/$prefix.cutsites.smoothed_$window_size.coverage.bed 
	cat $tmp_dir/$prefix.$chr.narrowPeak | grep -v "track"  >> $tmp_dir/$prefix.narrowPeak

done

# convert to bigWig

$bed2bw $tmp_dir/$prefix.cutsites.smoothed_$window_size.coverage.bed $genome_file $output_dir/bws/$prefix.cutsites.smoothed_$window_size.coverage.bw

# convert narrowPeak to 3 column .bed

cat $tmp_dir/$prefix.narrowPeak | cut -f1-3 > $output_dir/peaks/$prefix.peaks.bed

# count total peaks

num_peaks=`wc -l $output_dir/peaks/$prefix.peaks.bed`
echo "Identified $num_peaks total peaks"

# remove temporary files

rm $tmp_dir/$prefix*
echo "Removed temporary files"

exit


