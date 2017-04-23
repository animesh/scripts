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
Program that computes read clear ranges based on alignment coordinates

Usage: $PRG < delta_file [options]

	INPUT:   
		Mummer delta file
		
        options:

		-zero_cvg file	- File that contain zero coverage regions; 
                          reads ending in these	regions won't get trimmed

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
	my $is_zero_cvg=0;

	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
	my $result = $tigr_tf->TIGR_GetOptions(
		"zero_cvg=s"	=>	\$options{zero_cvg}
	);
	
	$tigr_tf->printUsageInfoAndExit() unless($result);

	########################################################################

	# read zero coverage coordinates		
	my %zero_cvg;		
	if(defined($options{zero_cvg}))
	{
		open(IN,$options{zero_cvg}) or die $!;
		while(<IN>)
		{
			my @f=split;
			next unless(@f);
			$zero_cvg{$f[0]}{$f[1]}=1;
			$zero_cvg{$f[0]}{$f[2]}=1; 
		}
		close(IN);
	}

	########################################################################
		
	my ($ref,$id,$read_len);
	my (%min,%max);	

	# read the alignmnet delta file
	while(<>)
	{	
		#>1 gnl|ti|185591439 3256683 909
		#3252989 3253871 16 909 19 19 0
		#-44
		#5
		#0
		#=> 3256683 16 909

		#>gi|116048575|ref|NC_008463.1| 52 6537648 33
		#287894 287914 21 1 0 0 0
		#0
		#1554749 1554781 1 33 1 1 0
		#0
		#4001147 4001167 1 21 0 0 0
		#0
		#4842167 4842192 6 31 0 0 0
		#0
		#=> 52  1 33

		my @f=split;

    		if(/^>/)
    		{
			$ref=$f[0]; $ref=~s/>//;
			$id=$f[1];
			$read_len=$f[3];
    		}
		elsif(scalar(@f)==7)
		{
			if($zero_cvg{$ref}{$f[0]})
			{
				if($f[2]<$f[3]) { $f[2]=1; }
				else            { $f[2]=$read_len; }
			}

                        if($zero_cvg{$ref}{$f[1]})
                        {
                                if($f[2]<$f[3]) { $f[3]=$read_len; }
                                else            { $f[3]=1; }
                        }  

			($f[2],$f[3])=($f[3],$f[2]) if($f[2]>$f[3]);
			$f[2]--;

			$min{$id}=$f[2] if(!defined($min{$id}) or $f[2]<$min{$id});
			$max{$id}=$f[3] if(!defined($max{$id}) or $f[3]>$max{$id});
		}
	}

	foreach $id (keys %min)
	{                                
		print join " ",($id,$min{$id},$max{$id});
		print "\n"
	}

	exit 0;
}
