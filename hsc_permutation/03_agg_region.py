import sys
import numpy as np
import pyBigWig

# read in input arguments

region = sys.argv[1]
num_rand = int(sys.argv[2])
norm_cov = 2500000000

# read columns of line

column = region.rstrip().split(":")
chrom = column[0]
start = int(column[1])
end = int(column[2]) 
region_size = end-start
print(chrom, start, end, region_size)

# initalize matrix for region

mat = np.zeros((region_size, num_rand))

# loop through all permuted samples

for i in range(num_rand):

    # load in bigWig

    filename = "combined_tracks/run1_rand%03d_050_run1_rand%03d_050_1M_pretrained.track.bw" % (i, i)
    #print(filename)
    bw = pyBigWig.open(filename)

    # get region coverage, total coverage, and normalize

    cov_file = "norm_perm_tracks/run1_rand%03d_050_run1_rand%03d_050_1M_pretrained.coverage.txt" % (i, i)
    coverage = int(open(cov_file,'r').readline().rstrip())

    mat[:,i] = bw.values(chrom, start, end)
    mat[:,i] = mat[:,i] / coverage * norm_cov
    #bw.close() # not necessary, doubles the run time
   
mat[np.isnan(mat)] = 0
#print mat

# print mean and std for each base

for j in range(region_size):

    mean = np.mean(mat[j,:])
    std = np.std(mat[j,:])

    print(chrom,start+j,mean,std)


