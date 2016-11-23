#!/usr/bin/env python

'''
gen_fofn.py

generate pacbio fofn file from list of cells
cells format (tab delimited),
160923_440  C01 # should coorespond to the path to fasta, e.g.  basepath/160923_440/C01_1/Analysis_Results/fatafile.subreads.fasta
160927_442  A02,H01

leading '#' character, implies to skip that line, for comment or to remove a run from analysis
leading '!' on a cell, implies to skip that cell, remove a cell from analysis

fofn format output, one line per fasta file
/share/dnat/rs2/161028_448/D02_1/Analysis_Results/m161031_221844_42145_c101058752550000001823247401061784_s1_p0.2.subreads.fasta
/share/dnat/rs2/161028_448/D02_1/Analysis_Results/m161031_221844_42145_c101058752550000001823247401061784_s1_p0.3.subreads.fasta
'''
import sys
import os
import glob
from optparse import OptionParser  # http://docs.python.org/library/optparse.html


def remove_comment(str1):
    loc = str1.find("#")  # identify if and where a # occurs
    if loc == -1:
        return str1  # if # not found return str1 as is
    str1 = str1[0:loc]  # trim of comment
    return str1.rstrip()  # remove any trailing whitespace and return result


usage = "usage: %prog [options] -o output_filename cells_file"
epilog = "Comments are allowed with '#' (can be used to remove a run). \
A '!' preceeding a cell will not include that cell in the fofn output. \
The cells_file can be provided as stdin. \
Specifying -o stdout can be used to put the output to stdout."

parser = OptionParser(usage=usage, version="%prog 1.0", epilog=epilog)
parser.add_option('-o', '--output', help="output filename, stdout is acceptable ",
                  action="store", type="str", dest="output", default="input.fofn")
parser.add_option('-b', '--basepath', help="pac bio cell base filepath",
                  action="store", type="str", dest="base", default="/share/dnat/rs2/")
parser.add_option('-f', '--filetype', help="file type",
                  action="store", type="str", dest="filetype", default="fasta")

(options, args) = parser.parse_args()

if len(args) == 1:
    infile = args[0]
    # Start opening input/output files:
    if not os.path.exists(infile):
        print "Error, can't find input file %s" % infile
        sys.exit()

    incell = open(infile, 'r')
else:
    # reading from stdin
    incell = sys.stdin

output = options.output
base = options.base
ftype = options.filetype

if output is 'stdout':
    out = sys.stdout
else:
    out = open(output, 'w')

run_count = 0
cell_count = 0

for line in incell:
    line = remove_comment(line)
    line = line.strip().split('\t')
    if len(line) != 2:
        next()
    run = line[0]
    cells = line[1].split(",")
    for cell in cells:
        cell = cell.strip()
        if cell[0] == '!':  # allow for cell removal if cell ID is preceeded by '!'
            next()
        skey = base + run + '/' + cell + "_1/Analysis_Results/*." + ftype
        files = sorted(glob.glob(skey))
        for f in files:
            out.write(f + '\n')
        cell_count += 1
    run_count += 1

print "Number of Runs: %s, Number of Cells: %s" % (run_count, cell_count)

incell.close()
out.close()
