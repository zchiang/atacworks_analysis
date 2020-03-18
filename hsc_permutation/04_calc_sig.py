import sys
import numpy as np
import pyBigWig
import scipy.stats

# read in input arguments

prefix = sys.argv[1]
bw = pyBigWig.open("cell_tracks_combined/"+prefix+"_"+prefix+"_1M_pretrained.track.bw")
region_file = open(sys.argv[2])
sel_chrom = sys.argv[3]
norm_cov = 2500000000

# load coverage file

cov_file = "cell_coverage_combined/"+prefix+"_"+prefix+"_1M_pretrained.coverage.txt"
coverage = int(open(cov_file,'r').readline().rstrip())
#print(coverage)

# loop through regions

for line in region_file:

	column = line.rstrip().split()

	# only read regions for selected chromosome

	chrom = column[0]
	if sel_chrom != chrom:
		continue

	start = int(column[1])
	end = int(column[2])
	region_size = end-start
	#print(chrom,start,end,region_size)

	# get region coverage and normalize
	
	cov = np.zeros((region_size,2))
	cov[:,1] = bw.values(chrom, start, end)
	cov[:,1] = cov[:,1] / coverage * norm_cov
	cov[np.isnan(cov)] = 0
	cov = cov[:,1]
   
	# load mean and std	
 
	mean_and_std = "agg_regions/%s_%d_%d.txt" % (chrom, start, end)
	mean = np.loadtxt(mean_and_std,delimiter=" ", usecols=2, max_rows=200000)
	std = np.loadtxt(mean_and_std,delimiter=" ", usecols=3, max_rows=200000)
	#print(mean,std)

	# calculate z-score and p-value

	z_scores = np.divide((cov-mean),std)
	log10_pvals = -np.log10(scipy.stats.norm.sf(abs(z_scores))*2)

	# print all significance bases

	for i in range(region_size):
		
		if log10_pvals[i] > 2:
			output = "%s\t%d\t%.03f\t%.03f\t%.03f\t%.03f\t%.03f" % (chrom, start+i, cov[i], mean[i], std[i], z_scores[i], log10_pvals[i])
			print(output)

