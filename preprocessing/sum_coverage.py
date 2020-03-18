import sys

coverage = 0

for line in sys.stdin:

    column = line.rstrip().split()
    coverage += float(column[3]) * (int(column[2])-int(column[1]))

print(coverage)
