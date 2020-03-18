import sys

sam_file = open(sys.argv[1])
chrom_sizes_file = open(sys.argv[2],'r')
smooth_size = int(sys.argv[3])

chr_sizes = {}

for line in chrom_sizes_file:

    column = line.rstrip().split()
    chrom = column[0]
    chr_size = int(column[1])

    chr_sizes[chrom] = chr_size

for line in sam_file:

    column = line.rstrip().split()
        
    chrom = column[2]
    pos = int(column[3])
    tlen = int(column[8])

    l_pos = pos+4 		# offset forward strand pos by +4
    nlen = abs(tlen)-9	# length of new template
    r_pos=l_pos+nlen	# offset reverse strand pos by -5
    c_pos=l_pos+nlen/2	# new center of fragment
	
    l_start = max(0,l_pos-smooth_size/2)
    l_end = min(chr_sizes[chrom],l_pos+smooth_size/2)
    r_start = max(0,r_pos-smooth_size/2)
    r_end = min(chr_sizes[chrom],r_pos+smooth_size/2)

    print (chrom+"\t"+str(int(l_start))+"\t"+str(int(l_end+1))+"\t1")
    print (chrom+"\t"+str(int(r_start))+"\t"+str(int(r_end+1))+"\t1")

