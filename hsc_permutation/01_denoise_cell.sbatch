#!/bin/bash
#SBATCH -p gpu_requeue
#SBATCH -n 4
#SBATCH -t 0-00:30          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH --gres=gpu:1
#SBATCH --gpu-freq=high
#SBATCH --mem=16000           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o myoutput_%j.out  # File to which STDOUT will be written, %j inserts jobid
#SBATCH -e myerrors_%j.err  # File to which STDERR will be written, %j inserts jobid

# check which GPU was assigned

(nvidia-smi)>&2
is_v100=`nvidia-smi | grep "V100" | wc -l`
if [ $is_v100 = 1 ]; then
	bs=512
else
	bs=128
fi
>&2 echo $bs

# initialize environment

module load Anaconda
module load gcc
module load cuda/9.0-fasrc02
source activate AtacWorks

# Input arguments: examples

# 1. run: run1
# 2. prefix: run1_rand001_050
# 3. intervals: infer_ints_no_chrY.bed
# 4. model: model_best.pth.tar

start_time="$(date -u +%s)"

set -e

>&2 echo ""
>&2 echo "Step 0: Initialize environment..."
>&2 echo ""

data_dir="$home_dir/data"
ref_dir="$home_dir/reference"
out_dir="$home_dir/result"

mkdir -p $out_dir/$prefix

root_dir=$(readlink -f "$home_dir/..")
saved_model_dir="$root_dir/data/pretrained_models"

# divide data into intervals

python $root_dir/bw2h5.py \
	--noisybw $data_dir/$run/$prefix\_barcodes.cutsites.smoothed_200.coverage.bw \
	--intervals $intervals \
	--prefix $out_dir/$prefix/$prefix \
	--pad 5000 \
	--batch_size 2000 \
	--nolabel

# run inference

(python $root_dir/main.py --infer \
	--infer_files $out_dir/$prefix/$prefix.h5 \
	--intervals_file $intervals \
	--sizes_file $ref_dir/hg19.chrom.sizes \
	--weights_path $saved_model_dir/$model \
	--out_home $out_dir/$prefix \
	--label $prefix\_1M_pretrained \
	--result_fname $prefix\_1M_pretrained \
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
	--bs $bs \
	--deletebg)>&2

rm $out_dir/$prefix/*h5

end_time="$(date -u +%s)"

elapsed="$(($end_time-$start_time))"
>&2 echo "Total of $elapsed seconds elapsed for $prefix"

