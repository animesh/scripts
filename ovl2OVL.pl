#!/usr/bin/perl -w
use strict;
use warnings;

# TIGR Modules
use TIGR::Foundation;
                                                                                                                                                 
my $tigr_tf = new TIGR::Foundation;
my $PRG = $tigr_tf->getProgramInfo('name');
my $REV="1.0";
my @DEPENDS=("TIGR::Foundation");
# help info
my $HELPTEXT = qq~
Program that converts an overlap TAB delimited file to AMOS format

Usage: $PRG file [options]

  INPUT:
	overlap TAB delimited file

  OUTPUT:
	overlap AMOS file

  options:

	-h|help		- Print this help and exit;
	-V|version	- Print the version and exit;
	-depend		- Print the program and database dependency list;
	-debug <level>	- Set the debug <level> (0, non-debug by default); 
 
~;
my $MOREHELP = qq~
Return Codes:   0 - on success, 1 - on failure.
~;

###############################################################################
#
# Main program
#
############################################################################### 
MAIN:
{
	my %options;

	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
        my $result = $tigr_tf->TIGR_GetOptions();
	$tigr_tf->printUsageInfoAndExit() if (!$result);

	# parse input
	while(<>)
	{ 
		my @f=split;
		next unless(@f);

		die "ERROR: $_" if(scalar(@f)<5);
		my ($a_id,$b_id,$dir,$a_hang,$b_hang)=@f;
			      
		print join "\n",("{OVL",
			"adj:$dir",
			"rds:$a_id,$b_id",
			"scr:0",
			"ahg:$a_hang",
			"bhg:$b_hang",
			"}");

		print "\n";

	}

	
	exit 0;
}
