#!/bin/bash
#SBATCH -p gpu_requeue
#SBATCH -n 4
#SBATCH -t 0-06:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --gres=gpu:1
#SBATCH --gpu-freq=high
#SBATCH --mem=24000           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o myoutput_%j.out  # File to which STDOUT will be written, %j inserts jobid
#SBATCH -e myerrors_%j.err  # File to which STDERR will be written, %j inserts jobid

# adjust memory based on GPU

(nvidia-smi)>&2
is_v100=`nvidia-smi | grep "V100" | wc -l`
if [ $is_v100 = 1 ]; then
	#bs=512
	bs=256
else
	bs=128
fi
>&2 echo $bs

# load modules and python environment

module load Anaconda
module load gcc
module load cuda/9.0-fasrc02
module load samtools
module load centos6/0.0.1-fasrc01
module load bedtools

source activate AtacWorks

# Input arguments:

# 1. run: run1
# 2. prefix: run1_rand001_050
# 3. intervals: infer_ints_no_chrY.bed
# 4. model: model_best.pth.tar

start_time="$(date -u +%s)"

set -e

>&2 echo ""
>&2 echo "Step 0: Initialize environment..."
>&2 echo ""
#home_dir=$(readlink -f $(dirname "$0"))

data_dir="$home_dir/data"
ref_dir="$home_dir/reference"
out_dir="$home_dir/result"

mkdir -p $out_dir/$prefix

root_dir=$(readlink -f "$home_dir/..")
saved_model_dir="$root_dir/data/pretrained_models"

# convert bam to bigWig

bash bin/atac_bam2bw.sh $data_dir/bams/$prefix.rmdup.bam $ref_dir/mm10.chrom.sizes 200 $data_dir

# divide data into intervals

python $root_dir/bw2h5.py \
	--noisybw $data_dir/bws/$prefix.cutsites.smoothed_200.coverage.bw \
	--intervals $intervals \
	--prefix $out_dir/$prefix/$prefix \
	--pad 5000 \
	--batch_size 2000 \
	--nolabel

# run inference

(python $root_dir/main.py --infer \
	--infer_files $out_dir/$prefix/$prefix.h5 \
	--intervals_file $intervals \
	--sizes_file $ref_dir/mm10.chrom.sizes \
	--weights_path $saved_model_dir/$model \
	--out_home $out_dir/$prefix \
	--result_fname 1M_pretrained \
	--model resnet \
	--nblocks 5 \
	--nfilt 15 \
	--width 51 \
	--dil 8 \
	--nblocks_cla 2 \
	--nfilt_cla 15 \
	--width_cla 51 \
	--dil_cla 8 \
	--task both \
	--num_workers 4 \
	--gen_bigwig \
	--pad 5000 \
	--bs $bs)>&2

# call peaks using MACS2

macs2 bdgpeakcall -i $out_dir/$prefix/AtacWorks_latest/"$prefix"_1M_pretrained.peaks.bedGraph -o $out_dir/$prefix/AtacWorks_latest/"$prefix"_1M_pretrained.peaks.narrowPeak -c 0.5

rm $out_dir/$prefix/*h5
rm $out_dir/$prefix/*/*bedGraph

end_time="$(date -u +%s)"

elapsed="$(($end_time-$start_time))"
>&2 echo "Total of $elapsed seconds elapsed for $prefix"

exit
