#!/usr/local/bin/perl

############################################################################
###															             ###
### Site-by-Site.pl											             ###
###		- Perl script used to produce a site-by-site table               ###
###		  in both plain text and html format				             ###
###															             ###
### Input :	output from checkHugo.pl: outOmimMiningHugo.txt	             ###
###			output from site_by_gene.pl: site_by_gene.txt	             ###
### Output: everything under "tables" directory				             ###
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

# Get the corresponding HUGO gene name described by each OMIM entry
open INHUGO, "outOmimMiningHugo.txt" or die "Can't open input file \n";

my %hash = ();

# Store the result from checkHugo.pl into a hash:
#	- key   = OMIM entry number
#	- value = HUGO gene name
while ($line = <INHUGO>) {
	chomp $line;
	my @array = split(/\t/, $line);

	$hash{$array[0]} = $array[2];
}

close INHUGO;

# Get the result from site_by_gene.pl
open INFILE, "<site_by_gene.txt" or die "the \"site_by_gene.txt\" file does not exist in the current directory\n";

my @bigArray = ();
my $size = 0;

# read site_by_gene table into a 2D array
while (my $line = <INFILE>) {
    chomp $line;

    my @lineArray = split (/\t/, $line);

    for (my $i = 0 ; $i <= $#lineArray; $i++) {
		$bigArray[$size]->[$i] = $lineArray[$i];
    }
    $size++;
}

close INFILE;

# make directory "tables" that store the results produced by this program
system("mkdir tables");
open OUTFILE,  ">tables/main_table.html" or die "unable to open main_table.html file\n";
open MAINTEXT, ">tables/main_table.txt"  or die "unable to open main_table.txt\n";

# print to file the headings
print OUTFILE "<HTML> \n";
print OUTFILE "<HEAD> \n";
print OUTFILE "<SCRIPT TYPE=\"text/javascript\"> \n";
print OUTFILE "<!-- \n";
print OUTFILE "function popup(mylink, windowname) { \n";
print OUTFILE "if (!window.focus) return true; \n";
print OUTFILE "var href; \n";
print OUTFILE "if (typeof(mylink) == \'string\')	href=mylink; \n";
print OUTFILE "else href=mylink.href; \n";
print OUTFILE "window.open(href, windowname, \'width=600,height=400,left=100,top=50,scrollbars=yes\'); \n";
print OUTFILE "return false; }\n";
print OUTFILE "//--> \n";
print OUTFILE "</SCRIPT> \n";
print OUTFILE "<TITLE> Site X Site Main Table </TITLE> \n";
print OUTFILE "<link rel=\"stylesheet\" type=\"text/css\" href=\"../styles.css\" /> \n";
print OUTFILE "</HEAD> \n";
print OUTFILE "<BODY ALINK=#4851A1 LINK=BLACK VLINK=#4851A1> \n";
print OUTFILE "<FONT SIZE=4 FACE=arial><B>The Site by Site Table</B></FONT> \n";
print OUTFILE "<BR> \n";
print OUTFILE "<BR> \n";
print OUTFILE "<TABLE WIDTH=600 BGCOLOR=#e8e8e8> \n";
print OUTFILE "\t<TR BGCOLOR=#FFFFFF> \n";
print OUTFILE "\t\t<TD class=header BGCOLOR=#FFFFFF> \n";
print OUTFILE "\t\t\t<FONT COLOR=#676767>&nbsp;Help</FONT> \n";
print OUTFILE "\t\t</TD> \n";
print OUTFILE "\t</TR> \n";
print OUTFILE "\t<TR> \n";
print OUTFILE "\t\t<TD> \n";
print OUTFILE "\t\t\t<UL> \n";
print OUTFILE "\t\t\t\t<LI>This table shows the number of times a pair of cancer sites both appear in an OMIM entry \n";
print OUTFILE "\t\t\t\t<LI>Click on the table cells for a list of OMIM entries that mentions the pair of cancer sites \n";
print OUTFILE "\t\t\t\t<LI>Breast includes both male and female Breast cancer; \n";
print OUTFILE "\t\t\t\t    Lymphoma includes both Hodgkin and non-Hodgkin disease; \n";
print OUTFILE "\t\t\t\t    Oral includes cancers of the lip, tongue, salivary gland, mouth, and pharynx; \n";
print OUTFILE "\t\t\t\t    Body Of Uterus deos not include cervix \n";
print OUTFILE "\t\t\t</UL> \n";
print OUTFILE "\t\t</TD> \n";
print OUTFILE "\t</TR> \n";
print OUTFILE "\t</TABLE> \n";
print OUTFILE "<BR> \n";

#print to file the first row of table
print OUTFILE " <TABLE border=\"1\">
				<TR>\n<TD></TD>\n
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >B<BR>L<BR>A<BR>D<BR>D<BR>E<BR>R</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >B<BR>R<BR>A<BR>I<BR>N</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >B<BR>R<BR>E<BR>A<BR>S<BR>T</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >C<BR>E<BR>R<BR>V<BR>I<BR>X</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >C<BR>O<BR>L<BR>O<BR>R<BR>E<BR>C<BR>T<BR>A<BR>L</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >E<BR>S<BR>O<BR>P<BR>H<BR>A<BR>G<BR>U<BR>S</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >L<BR>Y<BR>M<BR>P<BR>H<BR>O<BR>M<BR>A</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >K<BR>I<BR>D<BR>N<BR>E<BR>Y</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >L<BR>A<BR>R<BR>Y<BR>N<BR>X</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >L<BR>E<BR>U<BR>K<BR>E<BR>M<BR>I<BR>A</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >L<BR>U<BR>N<BR>G</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >O<BR>R<BR>A<BR>L</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >M<BR>Y<BR>E<BR>L<BR>O<BR>M<BR>A</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >O<BR>V<BR>A<BR>R<BR>Y</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >P<BR>A<BR>N<BR>C<BR>R<BR>E<BR>A<BR>S</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >P<BR>R<BR>O<BR>S<BR>T<BR>A<BR>T<BR>E</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >M<BR>E<BR>L<BR>A<BR>N<BR>O<BR>M<BR>A</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >S<BR>T<BR>O<BR>M<BR>A<BR>C<BR>H</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >T<BR>E<BR>S<BR>T<BR>I<BR>S</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >T<BR>H<BR>Y<BR>R<BR>O<BR>I<BR>D</FONT></TD>
				<TD class=header2 valign=\"top\"><FONT COLOR=\#616161 >B<BR>O<BR>D<BR>Y<BR><BR>O<BR>F<BR><BR>U<BR>T<BR>E<BR>R<BR>U<BR>S</FONT></TD>
				</TR>\n\n";

my @tissueArray = ("BLADDER","BRAIN","BREAST","CERVIX","COLORECTAL",
		   "ESOPHAGUS","LYMPHOMA","KIDNEY","LARYNX","LEUKEMIA", 
		   "LUNG","ORAL","MYELOMA","OVARY","PANCREAS",
		   "PROSTATE", "MELANOMA", "STOMACH", "TESTIS", "THYROID",
		   "BODY_OF_UTERUS");

my $numTissue = scalar @tissueArray; 

# write header to text file
for (my $i = 0; $i < $numTissue; $i++) {
    print MAINTEXT "\t$tissueArray[$i]";
}
print MAINTEXT "\n";

# Array to store the count for each box
my @countArray = ();

# initialize an array to store the list of intersected genes
my @listArray = ();

for (my $tissueIndex = 0; $tissueIndex < $numTissue; $tissueIndex++) {
	my $tissue = $tissueArray[$tissueIndex];

	# reset countArray to 0 and the listArray to empty
	for (my $count = 0; $count < $numTissue; $count++) {
		$countArray[$count] = 0;
		@listArray = ();
	}

    # go through the all bigArray for counts
	for (my $entry = 0; $entry < $size; $entry++) {

		# count start from the current tissue to the last tissue
		# increment only if current tissue = 1 F
		$currentTissueIndex = $tissueIndex + 1;

		for (my $k = $currentTissueIndex; $k <= $numTissue; $k++) {
			
			if (($bigArray[$entry]->[$currentTissueIndex] == 1) 
				&& ($bigArray[$entry]->[$k] == 1)) {
				$countArray[$k-1]++;
				$listArray[$k-1]->[$countArray[$k-1]] = $bigArray[$entry]->[0];
			}
		}
	}

    ##############################
    # print the array to outfile #
    ##############################

	if ($tissueArray[$tissueIndex] eq "BODY_OF_UTERUS") {
		print OUTFILE "<TR><TD BGCOLOR=#E8E8E8><FONT COLOR=\#616161 >BODY OF UTERUS</FONT></TD>\n";
	} else {
		print OUTFILE "<TR><TD BGCOLOR=#E8E8E8><FONT COLOR=\#616161 >$tissueArray[$tissueIndex]</FONT></TD>\n";
	}
    
    print MAINTEXT "$tissueArray[$tissueIndex]\t";
    # print blanks
    for (my $l = 0; $l < $tissueIndex; $l++) {
		print OUTFILE "<TD></TD>\n";
		print MAINTEXT " \t";
    }
    
    # print the remaining numbers
    for (my $m = $tissueIndex; $m < $numTissue; $m++) {
		if ($countArray[$m] == 0) {
			print OUTFILE "<TD BGCOLOR=E6E6E6 ALIGN=MIDDLE width=20>$countArray[$m]</TD>\n";
		} else {
			print OUTFILE "<TD BGCOLOR=E6E6E6 ALIGN=MIDDLE width=20><A href=\"$tissueArray[$tissueIndex]_$tissueArray[$m].html\" onClick=\"return popup(this, '$tissueArray[$tissueIndex]_$tissueArray[$m]')\">$countArray[$m]</A></TD>\n";
		}
		print MAINTEXT "$countArray[$m]\t";

		open (SUBOUTFILE, ">tables/$tissueArray[$tissueIndex]_$tissueArray[$m].html") or die "unable to write to $tissueArray[$tissueIndex]_$tissueArray[$m].html";
        open (SUBOUTTEXT, ">tables/$tissueArray[$tissueIndex]_$tissueArray[$m].txt") or die "unable to write to $tissueArray[$tissueIndex]_$tissueArray[$m].txt";

		print SUBOUTFILE "<HTML><HEAD> \n";
		print SUBOUTFILE "<TITLE>Common Entries Between $tissueArray[$tissueIndex] and $tissueArray[$m]</TITLE> \n";
		print SUBOUTFILE "<link rel=\"stylesheet\" type=\"text/css\" href=\"../styles.css\" /> \n";
		print SUBOUTFILE "</HEAD> \n";
		print SUBOUTFILE "<BODY ALINK=#616161 LINK=#616161 VLINK=#616161> \n";
		print SUBOUTFILE "<FONT SIZE=4 FACE=arial><B>  \n";
		print SUBOUTFILE "Common Entries Between $tissueArray[$tissueIndex] and $tissueArray[$m]. \n";
		print SUBOUTFILE "</B></FONT>&nbsp;&nbsp;<A HREF=\"javascript:window.print()\"><FONT SIZE=2 FACE=arial>Print this page</FONT></A> \n";
		print SUBOUTFILE "<UL> \n";
		print SUBOUTFILE "\t<LI>The following lists common OMIM entries and between <FONT COLOR=#4851A1>$tissueArray[$tissueIndex]</FONT> and <FONT COLOR=#4851A1>$tissueArray[$m]</FONT>,\n";
		print SUBOUTFILE "\tand the HUGO gene name described by each OMIM entry (in the bracket). \n";
		print SUBOUTFILE "\t<BR>Click on the entry number to view the actual OMIM entry<BR><BR> \n";
		print SUBOUTFILE "\t\t<UL> \n";
		
		for (my $k = 1; $k <= $countArray[$m]; $k++) {

			# print output in html format
			print SUBOUTFILE "\t\t\t<LI><A href=\"http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$listArray[$m]->[$k]\" TARGET=_blank>$listArray[$m]->[$k]</A> ($hash{$listArray[$m]->[$k]})\n";

			# print output in text format
			print SUBOUTTEXT "$listArray[$m]->[$k] ($hash{$listArray[$m]->[$k]})\n";
	}
	print SUBOUTFILE "</UL></UL></BODY></HTML> \n";

	close (SUBOUTFILE);
	close (SUBOUTTEXT);
    }
    print MAINTEXT "\n";

}
print OUTFILE "</TABLE></BODY></HTML> \n";
close (OUTFILE);
close (MAINTEXT);