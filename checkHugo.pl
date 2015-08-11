#!/usr/local/bin/perl

############################################################################
###															             ###
### Text Mining Program for OMIM part 2						             ###
###															             ###
### Input : output from omimMining.pl: outOmimMining.txt	             ###
###         HUGO flat file: nomeids.txt						             ###
### Output: outOmimMiningHugo.txt    						             ###
###															             ###
### Original Author: Dr. Shawn Rusaw						             ###
### Partially Modified by: Byron Kuo,						             ###
###                        Steve Sung						             ###
###															             ###
### BC CANCER AGENCY										             ###
### BC GENOME SCIENCES CENTRE								             ###
###															             ###
### Copyright 2004 Chris Bajdik, Shawn Rusaw, Byron Kuo, Steve Sung      ###
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
# This script takes in the results produced by omimMining.pl,
# outOmimMining.txt, and checks whether the OMIM entries exist in the HUGO 
# flat file. The assumption is that if an entry is found in the HUGO database,
# this entry is a human gene.
# 
# The default HUGO flat file is called "nomeids.txt"
# This file can be downloaded at http://www.gene.ucl.ac.uk/public-files/nomen/nomeids.txt
# If you have modified the name of the file, be sure to modify in the filehand line below
#
# Please keep in mind the file must be tab-delimited and in the original format
# since the script only looks for specific columns
#
# The output of this program is called outOmimMiningHugo.txt. This is the file 
# Perl CGI checks to display the results in HTML format as well as allow user
# to analyze and manipulate the data. 
#
# The output file contains 3 columsn:
#   column 1: MIM number'
#   column 2: Cancer site
#   column 3: the name of the gene

# Input: results producted by omimMining.pl
open (RESULT, "<outOmimMining.txt") or die "Unable to open input file outOmimMining.txt\n";

# this file can be modified if the HUGO flat file has a different name
# please keep in mind the format of the HUGO flat file should not be altered
open (HUGO, "<nomeids.txt") or die "Unable to open nomeids.txt\n";

# Output file. 
open (OUTFILE, ">outOmimMiningHugo.txt") or die "Unable to open output file outOmimMiningHugo.txt\n";

# Read the HUGO cross-link table for every entry having a MIM number
# store the MIM number in a hash
my %hugoHash = ();

my $hugo = <HUGO>;
# continue to read until no OMIM number can be found
while ($hugo = <HUGO>) {
	my @hugoArray = split (/\t/, $hugo);
	if($hugoArray[4] =~ m/\d\d\d\d\d\d/) {
		# store gene name as the value to the hash
		$hugoHash{$hugoArray[4]} = $hugoArray[1];
	}
}

# Read the search result and print out the ones that have hugo matches
while (my $result = <RESULT>) {
	chomp $result;
	@resultArray = split (/\t/, $result);

	if (exists $hugoHash{$resultArray[0]}) {
		print OUTFILE "$resultArray[0]\t$resultArray[1]\t$hugoHash{$resultArray[0]}\n";
	}
}

close (RESULT);
close (HUGO);
close (OUTFILE);

open IN, "outOmimMiningHugo.txt" or die "Can't open input file";
my $index = 0;
my @miningOutput = ();
while (my $line = <IN>) {
	chomp $line;

	my @lineArray = split(/\t/, $line);

	$miningOutput[$index]->[0] = $lineArray[0];
	$miningOutput[$index]->[1] = $lineArray[1];
	$miningOutput[$index]->[2] = $lineArray[2];
	$index++;
}
close IN;

# The following are only useful if you setup CGMIM on the web
# and use the Perl CGI functions.
# You can delete the following 4 lines if you are not planning 
# to use the Perl CGI functions to analyze the results
system("chmod 755 omimMining.html");
system("chmod 755 outOmimMiningHugo.txt");
system("cp outOmimMiningHugo.txt /net/magpie5/SWS/var/http/demo/cgi-bin");
system("chmod 755 /net/magpie5/SWS/var/http/demo/cgi-bin/outOmimMiningHugo.txt");