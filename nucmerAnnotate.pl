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
Program that parses a coords file and re-annotates sequence alignments 

Usage: $PRG coords_file [options]

  INPUT:
  	show-coords coords  file

  OUTPUT:
        show-coords coords  file

  options:
	-ignore <n>	- Maximum length of the end sequence unaligned (Default: 20 bp)
        -all		- Display all alignments (Default: only the annotated ones)
        -loose		- Looser annotation
        -noid		- Filter out identity alignments (sequences with the same id)     

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
	my $ignore=20;
	my $all;
	my $loose;
	my $noid;

	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
        my $result = $tigr_tf->TIGR_GetOptions(
		"ignore=s" =>   \$ignore,
		"all"	   =>   \$all,
		"loose"	   =>   \$loose,
		"noid"	   =>	\$noid
	);
	$tigr_tf->printUsageInfoAndExit() if (!$result);

	# parse input
	while(<>)
	{ 
		#       0        1  2        3        4  5        6        7  8        9  10      11       12  13    14       15    16  17 18      19
                #    6721     6769  |        1       49  |       49       49  |   100.00  |     6769      897  |     0.72     5.46  |   3  4       [END]

		my @f=split;
		next if(scalar(@f)<13);
		next if($f[0]!~/^\d+$/);
		
		my $n=scalar(@f);
		if($f[$n-1]=~/\[/) 
		{
			pop @f;
			$n--;
		}
		$f[$n]="";
			
		next if($noid and $f[$n-2] eq $f[$n-1] and $f[11]==$f[12]);

		my $rev;
		($f[3],$f[4],$rev)=($f[4],$f[3],1) if($f[3]>$f[4]);

		if($f[0]<=$ignore and $f[11]-$f[1]<=$ignore and $f[3]<=$ignore and $f[12]-$f[4]<=$ignore) { $f[$n]="[IDENTITY]" }		
		elsif($f[0]<=$ignore and $f[11]-$f[1]<=$ignore)                                           { $f[$n]="[CONTAINED]" }
		elsif($f[3]<=$ignore and $f[12]-$f[4]<=$ignore)                                           { $f[$n]="[CONTAINS]" }
		elsif(($f[3]<=$ignore or $f[12]-$f[4]<=$ignore) and $f[0]<=$ignore)                       { $f[$n]="[BEGIN]" }
		elsif(($f[3]<=$ignore or $f[12]-$f[4]<=$ignore) and $f[11]-$f[1]<=$ignore)                { $f[$n]="[END]" }
		elsif($f[3]<=$ignore and $loose)                                                          { $f[$n]="[BEGIN]" }
		elsif($f[12]-$f[4]<=$ignore and $loose)                                                   { $f[$n]="[END]" }

		($f[3],$f[4])=($f[4],$f[3]) if($rev);

		if($f[$n] or $all)
		{
			print join "\t",@f;
			print "\n";
		}
	}
	
	exit 0;
}
