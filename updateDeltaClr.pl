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
Program that updates a delta file with new query clear ranges

Usage: $PRG  delta_file clr_file [options]

	INPUT:   
        options:

		-h|help		- Print this help and exit;
		-V|version	- Print the version and exit;
		-depend		- Print the program and database dependency list;
		-debug <level>	- Set the debug <level> (0, non-debug by default); 
 
	OUTPUT:  
		Delta at the console
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
	my (%five,%three,$id);

	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
	my $result = $tigr_tf->TIGR_GetOptions();
	
	$tigr_tf->printUsageInfoAndExit() unless($result);

	########################################################################

	open(IN,$ARGV[1]) or die $!;
	while(<IN>)
	{
		my @f=split;
		next unless(@f);

		$five{$f[0]}=$f[1];
		$three{$f[0]}=$f[2];
	}
	close(IN);

	########################################################################

	open(IN,$ARGV[0]) or die $!;		
	while(<IN>)
	{	
		#>NC_008463.1_1_9608 10005 9608 33
		#4749 4778 4 33 1 1 0
		#0

		#10005 3 33

		#>NC_008463.1_1_9608 10005 9608 30
		#4749 4778 1 30 1 1 0
		#0

		my @f=split;

    		if(/^>/)
    		{
			$id=$f[1];

			if($three{$id})
			{
				$f[3]=$three{$id}-$five{$id};

				die "ERROR: $_" if($f[3]<0);
			}
    		}
		elsif(scalar(@f)==7)
		{
			if($five{$id})
                        {
                                $f[2]-=$five{$id};
				$f[3]-=$five{$id};

				die "ERROR: $_" if($f[2]<0);
				die "ERROR: $_" if($f[3]<0);
			}
		}
		
		print join " ",@f;
		print "\n";
	}
	close(IN);

	########################################################################
	
	exit 0;
}
