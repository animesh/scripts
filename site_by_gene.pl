#! /usr/local/bin/perl

############################################################################
###															             ###
### Site-by-Gene.pl											             ###
###															             ###
### Input : output from checkHugo.pl: outOmimMiningHugo.txt	             ###
### Output: site_by_gene.txt								             ###
###															             ###
### Original Author: Byron Kuo								             ###
### Partially Modified by: Steve Sung						             ###
###															             ###
### BC CANCER AGENCY										             ###
### BC GENOME SCIENCES CENTRE								             ###
###															             ###
### Copyright 2004 Chris Bajdik, Byron Kuo, Steve Sung                   ###
###                                                                      ###
### This file is part of CGMIM.                                          ###
###                                                                      ###
### CGMIM is a free software; you can redistribute it and/or modify      ###
### it under the terms of the GNU General Public License as published    ###
### by the Free Software Foundation; either version 2 of the License, or ###
### (at your option) any later version.                                  ###
###                                                                      ###
### CGMIM is distributed in the hope that it will be useful,             ###
### but WITHOUT ANY WARRANTY; without even the implied warranty of       ###
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ###
### GNU General Public License for more details.                         ###
###                                                                      ###
### You should have received a copy of the GNU General Public License    ###
### along with CGMIM; if not, write to the Free Software                 ###
### Foundation, Inc., 59 Temple Place, Suite 330, Boston,                ###
### MA  02111-1307  USA                                                  ###
############################################################################
#
# Perl script used to produce site_by_gene table for manual search
# Input: the OMIM search result returned by omimSearch.pl
#        example: su.BRAIN.txt
#        require all 21 tissues for the script to work
# Output: a site by gene table text file (site_by_gene.txt)
#         tab-delimited
#
# The site-by-gene table produced by this script will be a tab-delimited text file
# The presence of a gene in a specific cancer site is denoted by 1, otherwise 0.
#
# The table produced by this script is to be used to produce the site_by_site table.
# However, the user may want to view this table in a more organized environment using a
# spreadsheet software.

use strict;

open INFILE,  "<outOmimMiningHugo.txt" or die "unable to open outOmimMiningHugo.txt";
open OUTFILE, ">site_by_gene.txt"      or die "Unable to write to site_by_gene.txt";

# array to store the cancer sites
my @tissueArray = ("BLADDER","BRAIN","BREAST","CERVIX", "COLORECTAL",
		   "ESOPHAGUS","LYMPHOMA","KIDNEY","LARYNX","LEUKEMIA",
		   "LUNG","ORAL","MYELOMA","OVARY","PANCREAS","PROSTATE",
		   "MELANOMA","STOMACH","TESTIS", "THYROID", "BODY_OF_UTERUS");

my $numTissue = scalar @tissueArray;

# print header to output file
print OUTFILE "OMIM\t";

for (my $i = 0; $i < $numTissue; $i++) {
    print OUTFILE "$tissueArray[$i]\t";
}
print OUTFILE "\n";

# hash to store the site positions
my %tissueHash;

for (my $i = 0; $i < $numTissue; $i++) {
	$tissueHash{$tissueArray[$i]} = $i;
}

my $fullArrayIndex = 0;
my @fullArray = ();	# 2D array that contains entire output from omimMining.pl
					# index 0 contains OMIM file numbers
					# index 1 contains cancer site the OMIM file is descriping

# store result from checkHugp.pl into 2D array
while (my $line = <INFILE>) {
    chomp $line;

    my @lineArray = split (/\t/, $line);

	$fullArray[$fullArrayIndex]->[0] = $lineArray[0];
    $fullArray[$fullArrayIndex]->[1] = $lineArray[1];
    $fullArrayIndex++;
}

close (INFILE);

@fullArray = sort {$a->[0] <=> $b->[0]} @fullArray;

# temporary array for storing sites associations
my @rowArray = ();

my $currentNumber = 0;

# reset the array
for (my $j = 0; $j < $numTissue; $j++) {
    $rowArray[$j] = 0;
}

# store first entry
$rowArray[$tissueHash{$fullArray[$currentNumber]->[1]}] = 1;

# if no duplicate, print the current rowArray
# otherwise, set the appropriate box to 1

while ($currentNumber < $fullArrayIndex) {

	# In TextMining output,
	# if current listing and next listing are of different OMIM entry number
    if ($fullArray[$currentNumber]->[0] != $fullArray[$currentNumber+1]->[0]) {
		# print the result to output file
		print OUTFILE "$fullArray[$currentNumber]->[0]\t";

		for (my $i = 0; $i < $numTissue; $i++) {
			print OUTFILE "$rowArray[$i]\t";
		}

		#prints each row on site_by_gene.txt
		print OUTFILE "\n";			

		# reset the array
		for (my $j = 0; $j < $numTissue; $j++) {
			$rowArray[$j] = 0;
		}
    }
    $currentNumber++;
    $rowArray[$tissueHash{$fullArray[$currentNumber]->[1]}] = 1;
}

close OUTFILE;