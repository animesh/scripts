#!/usr/local/bin/perl

############################################################################
###															             ###
### Cancer Sites Count program								             ###
###															             ###
### Input : output from checkHugo.pl: outOmimMiningHugo.txt	             ###
### Output: outCountSites.txt								             ###
###         countSites.html									             ###
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
# This program produces a 4-column table that lists:
#	1) OMIM entry number of the gene's entry in OMIM 
#	2) HUGO gene name that is described by this OMIM entry
#	3) The number of cancer types mentioned in this OMIM entry 
#	4) A list of the cancer types mentioned in this OMIM entry
#

open (INFILE, "<outOmimMiningHugo.txt") or die "Unable to open outOmimMiningHugo.txt\n";
open (DIST, ">outCountSites.txt") or die "Unable to write to outCountSites.txt for writing\n";

open  OUTHTML, ">countSites.html" or die "Unable to write to countSites.html for writing\n";
print OUTHTML "<HTML> \n";
print OUTHTML "<HEAD> \n";
print OUTHTML "<SCRIPT TYPE=\"text/javascript\"> \n";
print OUTHTML "<!--  \n";
print OUTHTML "function popup(mylink, windowname) {  \n";
print OUTHTML "if (!window.focus) return true;  \n";
print OUTHTML "var href;  \n";
print OUTHTML "if (typeof(mylink) == \'string\')	href=mylink;  \n";
print OUTHTML "else href=mylink.href;  \n";
print OUTHTML "window.open(href, windowname, \'width=750,height=120,left=50,top=50,scrollbars=no\');  \n";
print OUTHTML "return false;  \n";
print OUTHTML "}  \n";
print OUTHTML "//-->  \n";
print OUTHTML "</SCRIPT>  \n";
print OUTHTML "<TITLE> Count Cancer Sites </TITLE> \n";
print OUTHTML "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" />";
print OUTHTML "</HEAD> \n";
print OUTHTML "<BODY ALINK=#000000 LINK=#000000 VLINK=#000000>  \n";
print OUTHTML "<FONT SIZE=4 FACE=arial><B>Count Cancer Sites</B></FONT><BR><BR> \n";
print OUTHTML "<TABLE WIDTH=600 BGCOLOR=#e8e8e8> \n";
print OUTHTML "\t<TR BGCOLOR=#FFFFFF> \n";
print OUTHTML "\t\t<TD class=header BGCOLOR=#FFFFFF> \n";
print OUTHTML "\t\t\t<FONT COLOR=#676767>&nbsp;Column Definitions</FONT> \n";
print OUTHTML "\t\t</TD> \n";
print OUTHTML "\t</TR> \n";
print OUTHTML "\t<TR> \n";
print OUTHTML "\t\t<TD> \n";
print OUTHTML "\t\t\t<UL> \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>OMIM Entry</FONT> is the catalogue number of the gene's entry in  <A HREF=\"http://www.ncbi.nlm.nih.gov/omim/\" TARGET=_blank>Online Mendelian Inheritance In Men</A> \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>HUGO Gene Name</FONT> is the gene name assigned by the  <A HREF=\"http://www.gene.ucl.ac.uk/hugo/\" TARGET=_blank>Human Genome Organization</A> \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Count</FONT> is the number of cancer types mentioned in the OMIM entry \n";
print OUTHTML "\t\t\t\t<LI><FONT COLOR=#616161>Related Cancers</FONT> lists the cancer types mentioned in the OMIM entry \n";
print OUTHTML "\t\t\t</UL> \n";
print OUTHTML "\t\t</TD> \n";
print OUTHTML "\t</TR> \n";
print OUTHTML "\t</TABLE> \n";
print OUTHTML "<FORM METHOD=POST ACTION=\"http://192.168.84.245/cgi-bin/ss_countSites.cgi\"> \n";
print OUTHTML "<P class=sort>Sort by \n";
print OUTHTML "<SELECT NAME=sort> \n";
print OUTHTML "\t<OPTION VALUE=omim>OMIM Entry \n";
print OUTHTML "\t<OPTION VALUE=gene>HUGO Gene Name \n";
print OUTHTML "\t<OPTION VALUE=count>Count \n";
print OUTHTML "\t<OPTION VALUE=cancer>Related Cancers \n";
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
print OUTHTML "<TABLE BORDER=1 WIDTH=100%> \n";

# read the results from checkHugo.pl into 2D array
my @geneList = ();
my $geneIndex = 0;
while (my $line = <INFILE>) {
    chomp $line;

    my @lineArray = split (/\t/, $line);

    $geneList[$geneIndex]->[0] = $lineArray[0];
    $geneList[$geneIndex]->[1] = $lineArray[1];
    $geneList[$geneIndex]->[2] = $lineArray[2];

    $geneIndex++;
}

# read through geneList
my $currPos = 1;							# current position
my $countGene = 1;							# current number of genes counted
my $countCurrent = 1;						# current count for the specific gene
my $geneCurrent = $geneList[0]->[0];		# current gene counting
my $geneCurrentName = $geneList[0]->[2];	# store gene name
my @cancerCurrent = ();						# array to store all cancer sites currently counting

push @cancerCurrent, $geneList[0]->[1];

my @countList = (); # stores a list of counts

while ($currPos < @geneList."") {

    # if current gene in the list is the same as the previous gene
    # then increment count for this gene
    if ($geneList[$currPos]->[0] == $geneList[$currPos - 1]->[0]) {
		$countCurrent++;
		push @cancerCurrent, $geneList[$currPos]->[1]; # store current cancer site
    }
    else {
		# if not, store the current gene and its count to the countList array
		# and increment countGeen
		$countList[$countGene-1]->[0] = $geneCurrent;
		$countList[$countGene-1]->[1] = $geneCurrentName;
		$countList[$countGene-1]->[2] = $countCurrent;

		# store all the cancers to the current row
		for (my $i = 3; $i < ($countCurrent + 3); $i++) {
			$countList[$countGene-1]->[$i] = $cancerCurrent[$i-3];
		}

		$countGene++;

		# reset current

		$geneCurrent = $geneList[$currPos]->[0];
		$geneCurrentName = $geneList[$currPos]->[2];
		$countCurrent = 1;
		@cancerCurrent = ();
		push @cancerCurrent, $geneList[$currPos]->[1];
    }
    $currPos++;
}

my $sumGroups = 0;

@countList = sort {$a->[2] <=> $b->[2]} @countList;

print DIST "MIM No.\tGene Name\tCount\t Related Cancers\n";
print OUTHTML "<TR> \n";
print OUTHTML "\t<TD class=header2 WIDTH=50><FONT COLOR=#616161>OMIM Entry</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=50><FONT COLOR=#616161>HUGO Gene Name</FONT></TD> \n";
print OUTHTML "\t<TD class=header2 WIDTH=40><FONT COLOR=#616161>Count</FONT></TD> \n";
print OUTHTML "\t<TD class=header2><FONT COLOR=#616161>Related Cancers</FONT></TD> \n";
print OUTHTML "</TR> \n";

for (my $i = $#countList; $i >= 0; $i--) {
    print DIST "$countList[$i]->[0]\t$countList[$i]->[1]\t$countList[$i]->[2]\t";
	print OUTHTML "<TR> \n";
	print OUTHTML "\t<TD ALIGN=MIDDLE>$countList[$i]->[0]</TD> \n";
	print OUTHTML "\t<TD ALIGN=MIDDLE>$countList[$i]->[1]</TD> \n";
	print OUTHTML "\t<TD ALIGN=MIDDLE>$countList[$i]->[2]</TD> \n";
	print OUTHTML "\t<TD ALIGN=LEFT><FONT SIZE=1 FACE=arial>";
    for (my $j = 3; $j < ($countList[$i]->[2]+3); $j++) {
		print DIST "$countList[$i]->[$j], ";
		print OUTHTML "$countList[$i]->[$j], ";
    }
    print DIST "\n";
	print OUTHTML "</FONT></TD></TR> \n";
    $sumGroups = $sumGroups + $countList[$i]->[2];
}

my $meanNumGroups = $sumGroups / $countGene;
my $median = $countList[$countGene/2]->[2];

print DIST "Number of Unique Genes: $countGene \n";
print DIST "Average Number of groups: $meanNumGroups\n";
print DIST "Median Number of groups: $median\n";
print OUTHTML "\t<TR><TD ALIGN=LEFT COLSPAN=4><FONT FACE=arial>Number of Unique Genes: $countGene</FONT></TD></TR> \n";
print OUTHTML "\t<TR><TD ALIGN=LEFT COLSPAN=4><FONT FACE=arial>Average Number of groups: $meanNumGroups</FONT></TD></TR> \n";
print OUTHTML "\t<TR><TD ALIGN=LEFT COLSPAN=4><FONT FACE=arial>Median Number of groups: $median</FONT></TD></TR> \n";
print OUTHTML "</TABLE> \n";
print OUTHTML "</BODY></HTML> \n";

close OUTHTML;
close (INFILE);
close (DIST);

# The following are only useful if you setup CGMIM on the web
# and use the Perl CGI functions.
# You can delete the following 3 lines if you are not planning 
# to use the Perl CGI functions to analyze the results
system("chmod 755 countSites.html");
system("cp outCountSites.txt /net/magpie5/SWS/var/http/demo/cgi-bin");
system("chmod 755 /net/magpie5/SWS/var/http/demo/cgi-bin/outCountSites.txt");