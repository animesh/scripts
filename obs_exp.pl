#!/usr/bin/perl

############################################################################
###															             ###
### obs_exp.pl												             ###
###		- Calculates the observed / expected (number of		             ###
###		  genes) ratio for each cancer site pair			             ###
###															             ###
### Input :	site-by-site table								             ###
###			site-by-gene table								             ###
### Output: outOE.txt										             ###
###			obs_exp.html									             ###
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
# The expected frequency is calculated based on the diagonal values of
# each cancer site divided by the total number of unique genes.
# The expected number of genes for each group is the product of 
# expected frequencies for the two sites multiplied by total number
# of unique genes.
#
# A ratio is calculated by dividing the observed Number by the 
# expected Number

open (IN, "<tables/main_table.txt") or die "unable to open main_table.txt\n";
open (TAB, "<site_by_gene.txt") or die "unable to open site_by_gene.txt\n";
open (OUT, ">outOE.txt") or die "unable to open outOE.txt\n";
open  OUTHTML, ">obs_exp.html" or die "Cannot open HTML file for writing.\n";

print OUTHTML "<HTML> \n";
print OUTHTML "<HEAD> \n";
print OUTHTML "<SCRIPT TYPE=\"text/javascript\"> \n";
print OUTHTML "<!-- \n";
print OUTHTML "function popup(mylink, windowname) { \n";
print OUTHTML "	if (!window.focus) return true; \n";
print OUTHTML "	var href; \n";
print OUTHTML "	if (typeof(mylink) == 'string')	href=mylink; \n";
print OUTHTML "	else href=mylink.href; \n";
print OUTHTML "	window.open(href, windowname, \'width=550,height=400,left=100,top=50,scrollbars=yes\'); \n";
print OUTHTML "return false; \n";
print OUTHTML "} \n";
print OUTHTML "//--> \n";
print OUTHTML "</SCRIPT> \n";	
print OUTHTML "<TITLE>Observed Expected Ratio</TITLE> \n";
print OUTHTML "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />\n";
print OUTHTML "</HEAD> \n";
print OUTHTML "<BODY ALINK=#000000 LINK=#000000 VLINK=#000000> \n";
print OUTHTML "<FONT SIZE=4 FACE=arial><B>Observed / Expected Ratio</B></FONT><BR><BR>  \n";
print OUTHTML "<TABLE WIDTH=450 BGCOLOR=#e8e8e8> \n";
print OUTHTML "\t<TR BGCOLOR=#FFFFFF> \n";
print OUTHTML "\t\t<TD class=header BGCOLOR=#FFFFFF> \n";
print OUTHTML "\t\t\t<FONT COLOR=#676767>&nbsp;Column Definitions</FONT> \n";
print OUTHTML "\t\t</TD> \n";
print OUTHTML "\t</TR> \n";
print OUTHTML "\t<TR> \n";
print OUTHTML "\t\t<TD> \n";
print OUTHTML "\t\t\t<UL> \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Pair</FONT> is cancer site combination \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Observed</FONT> is the observed number of occurences \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Expected</FONT> is the expected number of occurences \n";
print OUTHTML "\t\t\t\t<BR>(based on the observed number of occurence for the individual sites) \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Ratio</FONT> is observed / expected \n";
print OUTHTML "\t\t\t</UL> \n";
print OUTHTML "\t\t</TD> \n";
print OUTHTML "\t</TR> \n";
print OUTHTML "\t</TABLE> \n";
print OUTHTML "<FORM METHOD=POST ACTION=\"http://192.168.84.245/cgi-bin/ss_obs_exp.cgi\"> \n";
print OUTHTML "<P class=sort>Sort by \n";
print OUTHTML "<SELECT NAME=sort> \n";
print OUTHTML "\t<OPTION VALUE=group>Pair \n";
print OUTHTML "\t<OPTION VALUE=observed>Observed \n";
print OUTHTML "\t<OPTION VALUE=expected>Expected  \n";
print OUTHTML "\t<OPTION VALUE=ratio>Ratio \n";
print OUTHTML "</SELECT> \n";
print OUTHTML "in \n";
print OUTHTML "<SELECT NAME=order> \n";
print OUTHTML "\t<OPTION VALUE=ascend>ascending \n";
print OUTHTML "\t<OPTION VALUE=descend>descending \n";
print OUTHTML "</SELECT> \n";
print OUTHTML "order &nbsp;\n";
print OUTHTML "<INPUT TYPE=submit VALUE=\" sort \"> \n";
print OUTHTML "</P> \n";
print OUTHTML "</FORM> \n";
print OUTHTML "<TABLE BORDER=1 WIDTH=450> \n";

# count the number of genes
my $uniqueGenes = 0;
<TAB>;
while (<TAB>) {
    $uniqueGenes++; 
}

# read the header of the site-by-site table
# remove end line and split into a temporary array by tab
my $line = <IN>;
chomp $line;

my @tempArray = split (/\t/, $line);

# store the tissues into an array of tissues
# ignore the first tab
my @tissues = ();

for (my $i = 1; $i < @tempArray.""; $i++) {
    push @tissues, $tempArray[$i];
}

# store everything else into a big array of counts
# ignore the header and the first column
# keep a hash of the counts of all tissues
my @allCounts = ();
my $countRowIndex = 0;
my %tissueHash = ();

while ($line = <IN>) {
    chomp $line;

    my @lineArray = split (/\t/, $line);

    for (my $i = 1; $i < @lineArray.""; $i++) {
		$allCounts[$countRowIndex]->[$i-1] = $lineArray[$i];
    }	
	%tissueHash = (%tissueHash, $tissues[$countRowIndex]=>$lineArray[$countRowIndex+1]);
    $countRowIndex++;
}

# read through @allCounts to determine the expected number of genes
# and the ratio between observed and expected number of genes
#
# store the result into another 2D array

my @result = ();
my $resultIndex = 0;
my $start = 1;

for (my $row = 0; $row < @tissues.""; $row++) {
    for (my $column = $start; $column < @tissues.""; $column++) {
		my $group = $tissues[$row] . "-" . $tissues[$column];
		my $groupLink = $tissues[$row] . "_" . $tissues[$column]."\.html";	# For linking to the siteA_siteB.html web page

		############################
		# calculate expected value #
		############################
		#
		# expected value of a group =
		#     (observed value of row site)/(total unique genes)
		#    *(observed value of column site)/(total unique genes)
		#    *(total unique genes)

		my $rowRatio = $tissueHash{$tissues[$row]} / $uniqueGenes;
		my $columnRatio = $tissueHash{$tissues[$column]} / $uniqueGenes;
		my $expectedNumber = $rowRatio * $columnRatio * $uniqueGenes;

		# observed value
		my $observedNumber = $allCounts[$row]->[$column];

		# observed_expected ratio
		my $obs_exp_ratio = $observedNumber / $expectedNumber;

		# store these into the @result array
		$result[$resultIndex]->[0] = $group;
		$result[$resultIndex]->[1] = $expectedNumber;
		$result[$resultIndex]->[2] = $observedNumber;
		$result[$resultIndex]->[3] = $obs_exp_ratio;
		$result[$resultIndex]->[4] = $groupLink;		
		$resultIndex++;	
    }
    $start++;
}

# sort the @result array by the observed/expected ratio
@result = sort {$a->[3] <=> $b->[3]} @result;

# print to the output file
print OUT "Pair\tExpected\tObserved\tRatio\tConfidence Interval(+-)\tHtmlFile\n";
print OUTHTML "<TR> \n";
print OUTHTML "\t<TD class=header2><FONT COLOR=#616161>Pair</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=60><FONT COLOR=#616161>Observed</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=60><FONT COLOR=#616161>Expected</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=60><FONT COLOR=#616161>Ratio</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=90><FONT COLOR=#616161>Confidence Interval (+ or -)</FONT></TD> \n";
print OUTHTML "</TR> \n";

for (my $i = ($resultIndex-1); $i >= 0; $i--) {
    print  OUT "$result[$i]->[0]\t$result[$i]->[1]\t$result[$i]->[2]\t$result[$i]->[3]\t\t$result[$i]->[4]\n";
	print  OUTHTML "<TR> \n";
	print  OUTHTML "\t<TD ALIGN=LEFT><A HREF=\"tables/$result[$i]->[4]\" onClick=\"return popup(this, 'OMIM')\">$result[$i]->[0]</A></TD> \n";
	print  OUTHTML "\t<TD ALIGN=MIDDLE>$result[$i]->[2]</TD> \n";
	printf OUTHTML "\t<TD ALIGN=MIDDLE>%0.2f</TD> \n", $result[$i]->[1];
	printf OUTHTML "\t<TD ALIGN=MIDDLE>%0.2f</TD> \n", $result[$i]->[3];

	my $ci = 1.96/sqrt($result[$i]->[1]);

	printf OUTHTML "\t<TD ALIGN=MIDDLE>%0.2f</TD> \n", $ci;
	print  OUTHTML "</TR> \n";
}

print OUTHTML "</TABLE> \n";
print OUTHTML "</BODY></HTML> \n";
close OUTHTML;
close (IN);
close (OUT);

# The following are only useful if you setup CGMIM on the web
# and use the Perl CGI functions.
# You can delete the following 4 lines if you are not planning 
# to use the Perl CGI functions to analyze the results
system("chmod 755 obs_exp.html");
system("cp outOE.txt /net/magpie5/SWS/var/http/demo/cgi-bin");
system("chmod 755 /net/magpie5/SWS/var/http/demo/cgi-bin/outOE.txt");