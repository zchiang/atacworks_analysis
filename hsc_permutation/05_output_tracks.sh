# sort by genomic coordinate, remove duplicate bases and uncovered regions

cat sig_tracks/run1_cell001_id8828_050/* | grep -v "200000" | sort -k1,1 -k2,2n | uniq > run1_cell001_id8828_050.sig_track.txt
cat sig_tracks/run1_cell002_id3951_050/* | grep -v "200000" | sort -k1,1 -k2,2n | uniq > run1_cell002_id3951_050.sig_track.txt
cat sig_tracks/run1_cell003_id7096_050/* | grep -v "200000" | sort -k1,1 -k2,2n | uniq > run1_cell003_id7096_050.sig_track.txt

# create significant z-score track

cat run1_cell001_id8828_050.sig_track.txt | awk '{print $1,$2,$2+1,$6}' | sed 's/ /\t/g' > run1_cell001_id8828_050.sig_zscores.bed
cat run1_cell002_id3951_050.sig_track.txt | awk '{print $1,$2,$2+1,$6}' | sed 's/ /\t/g' > run1_cell002_id3951_050.sig_zscores.bed
cat run1_cell003_id7096_050.sig_track.txt | awk '{print $1,$2,$2+1,$6}' | sed 's/ /\t/g' > run1_cell003_id7096_050.sig_zscores.bed

# create binary significance track

cat run1_cell001_id8828_050.sig_track.txt | awk '{print $1,$2,$2+1,1}' | sed 's/ /\t/g' > run1_cell001_id8828_050.sig_binary.bed
cat run1_cell002_id3951_050.sig_track.txt | awk '{print $1,$2,$2+1,1}' | sed 's/ /\t/g' > run1_cell002_id3951_050.sig_binary.bed
cat run1_cell003_id7096_050.sig_track.txt | awk '{print $1,$2,$2+1,1}' | sed 's/ /\t/g' > run1_cell003_id7096_050.sig_binary.bed

# convert tracks to bigWig

bin/bedGraphToBigWig run1_cell001_id8828_050.sig_zscores.bed reference/hg19.auto.sizes run1_cell001_id8828_050.sig_zscores.bw
bin/bedGraphToBigWig run1_cell002_id3951_050.sig_zscores.bed reference/hg19.auto.sizes run1_cell002_id3951_050.sig_zscores.bw
bin/bedGraphToBigWig run1_cell003_id7096_050.sig_zscores.bed reference/hg19.auto.sizes run1_cell003_id7096_050.sig_zscores.bw 

bin/bedGraphToBigWig run1_cell001_id8828_050.sig_binary.bed reference/hg19.auto.sizes run1_cell001_id8828_050.sig_binary.bw 
bin/bedGraphToBigWig run1_cell002_id3951_050.sig_binary.bed reference/hg19.auto.sizes run1_cell002_id3951_050.sig_binary.bw 
bin/bedGraphToBigWig run1_cell003_id7096_050.sig_binary.bed reference/hg19.auto.sizes run1_cell003_id7096_050.sig_binary.bw 

