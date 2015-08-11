#!/usr/bin/perl
 
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
Program that computes alignment coverage from a Mummer delta file

Usage: $PRG < delta_file [options]
	
  INPUT:
	delta_file	

	#>Streptococcus_suis 2_14_26_F3 2007491 46
	#1282180 1282217 39 2 0 0 0
	#0
	#>Streptococcus_suis 2_14_233_F3 2007491 46
	#1082721 1082752 33 2 0 0 0
	#0


  options:
	-m <n>		- Min coverage to display
	-M <n>		- Max coverage to display
	-merge		- Merge coverage intervals 

	-h|help		- Print this help and exit;
	-V|version	- Print the version and exit;
	-depend		- Print the program and database dependency list;
	-debug <level>	- Set the debug <level> (0, non-debug by default); 

  OUTPUT:
	Example:
		J28690Ab07.q1k	1	9	0
		J28690Ab07.q1k 	9	112	1
		J28690Ab07.q1k  112	951	2
		....	
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
	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
	my %options;
	my %count;
	my $ref;

	my $result = $tigr_tf->TIGR_GetOptions(
		"m=s" => \$options{m},
		"M=s" => \$options{M},
		"merge"	=> \$options{merge}
		);
	$tigr_tf->printUsageInfoAndExit() if (!$result);

	############################################################
	# parse input file
	while(<>)
	{
	        #>Streptococcus_suis 2_14_26_F3 2007491 46
	        #1282180 1282217 39 2 0 0 0
	        #0
        	#>Streptococcus_suis 2_14_233_F3 2007491 46
	        #1082721 1082752 33 2 0 0 0
        	#0

		my @f=split;

		if(/^\// or /^NUCMER/) {}
		elsif(/^>/)
		{
			$f[0]=~s/>//;

			$ref=$f[0];

			$count{$ref}{1}+=0;
                	$count{$ref}{$f[2]}+=0;
		}
		elsif(scalar(@f)==7)
		{
			$count{$ref}{$f[0]}++;
			$count{$ref}{$f[1]}--;
		}
	}

	#####################################################################

	foreach my $ref (keys %count)
	{	
        	my @keys=sort {$a <=> $b} keys %{$count{$ref}};
       		my $n=scalar(@keys);

        	foreach my $i (1..$n-1) 
        	{         
                	$count{$ref}{$keys[$i]}+=$count{$ref}{$keys[$i-1]};

                	next if(defined($options{m}) and $count{$ref}{$keys[$i-1]}<$options{m});
                	next if(defined($options{M}) and $count{$ref}{$keys[$i-1]}>$options{M});

                	print join "\t",($ref,$keys[$i-1],$keys[$i],$keys[$i]-$keys[$i-1],$count{$ref}{$keys[$i-1]});
               		print "\n";
		}
        }

	exit 0;
}
