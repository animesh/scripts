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
Program that converts nucmer overlaps to an overlap file (either AMOS or TAB format)

Usage: $PRG file [options]

  INPUT:
  	show-coords output file

  OUTPUT:
	ovl file (AMOS or TAB)

  options:

	-tab 		- Output format (Default: AMOS)
	-ignore <n>	- Maximum length of the end sequence unaligned (Default: 20 bp)

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
	my %h;

	$options{ignore}=20;

	# Configure TIGR Foundation
	$tigr_tf->setHelpInfo($HELPTEXT.$MOREHELP);
        $tigr_tf->setUsageInfo($HELPTEXT);
        $tigr_tf->setVersionInfo($REV);
        $tigr_tf->addDependInfo(@DEPENDS);
	
	# validate input parameters
        my $result = $tigr_tf->TIGR_GetOptions(
		"tab"		=>   \$options{tab},
		"ignore=s" 	=>   \$options{ignore}
	);
	$tigr_tf->printUsageInfoAndExit() if (!$result);

	# parse input
	while(<>)
	{ 
		#       0        1  2        3        4  5        6        7  8        9  10      11       12

		#  NORMAL
		#  ---------->
		#       --------->
                #3,4,N,6721-1,897-49: $f[17],$f[18],N,$f[0]-1,$f[12]-$f[4]
                #    6721     6769  |        1       49  |       49       49  |   100.00  |     6769      897  |     0.72     5.46  | 3  4       [END]

                #  CONTAINS
                #  ---------------------->
                #       --------->
                #15,17,N,13194-1,13528-15369:$f[17],$f[18],N,$f[0]-1,$f[1]-$f[11]
                #   13194    13528  |        1      335  |      335      335  |    99.40  |    15369      335  |     2.18   100.00  | 15 17      [CONTAINS]

		#  INNIE
                #  ---------->
                #       <---------
		#1,2,I,16303-1,169-1: $f[17],$f[18],I,$f[0]-1,$f[4]-1
		#   16303    16876  |      742      169  |      574      574  |   100.00  |    16876      742  |     3.40    77.36  | 1  2       [END]

		#  OUTIE
                #       --------->
		#   <-------
		#2,3,I,165-6769,165-742: $f[17],$f[18],I,$f[3]-$f[12],$f[1]-$f[11]
		#       1      165  |      165        1  |      165      165  |   100.00  |      742     6769  |    22.24     2.44  | 2  3       [BEGIN]

		#  CONTAINS
		#      -------------->
		#	 <------

		my @f=split;
		next unless(@f);
		next if(scalar(@f)<13);
		next if($f[0]!~/^\d+$/);

                my $n=scalar(@f);
                if($f[$n-1]=~/\[/)
                {
                        pop @f;
                        $n--;
                }

		my ($a_id,$a_start,$a_end,$a_len)=@f[$n-2,0,1,11];
		my ($b_id,$b_start,$b_end,$b_len)=@f[$n-1,3,4,12];
		my ($dir,$switched,$a_hang,$b_hang);
	
		next if($a_id eq $b_id);
		next if($h{$a_id}{$b_id} or $h{$b_id}{$a_id});

		# SAME DIR
		if($b_start<$b_end)
		{
			# switch if
			#    ----------->	
			# --------->
			if($a_start<$b_start)
			{
				  ($a_id,$a_start,$a_end,$a_len,$b_id,$b_start,$b_end,$b_len)=($b_id,$b_start,$b_end,$b_len,$a_id,$a_start,$a_end,$a_len);
				  $switched=1;
			}

			# CONTAINS
			if($b_start<$options{ignore} and ($b_len-$b_end)<$options{ignore})
	                {
        	                $a_hang=$a_start-1;
                	        $b_hang=$a_end-$a_len;
                        	$dir="N";
	                }
			# NORMAL
                        elsif(($a_len-$a_end)<$options{ignore} and $b_start<$options{ignore})
                        {
                                $a_hang=$a_start-1;
                                $b_hang=$b_len-$b_end;
                                $dir="N";
                        }
		}
		# OPPOSITE DIR
		else 
		{
			($b_start,$b_end)=($b_end,$b_start);
			if($a_start<$b_start)
                        {
                                ($a_id,$a_start,$a_end,$a_len,$b_id,$b_start,$b_end,$b_len)=($b_id,$b_start,$b_end,$b_len,$a_id,$a_start,$a_end,$a_len);
				$switched=1;
                        }

			# CONTAINS
                        if($b_start<$options{ignore} and ($b_len-$b_end)<$options{ignore})
                        {
                                $a_hang=$a_start-1;
                                $b_hang=$a_end-$a_len;
                                $dir="I";
                        }
			# OUTIE
                        elsif($a_start<$options{ignore} and $b_start<$options{ignore})
                        {
                                $a_hang=$b_end-$b_len;
                                $b_hang=$a_end-$a_len;
                                $dir="I";
                        }
			# INNIE
			elsif(($a_len-$a_end)<$options{ignore} and ($b_len-$b_end)<$options{ignore})	
			{
        	                $a_hang=$a_start-1;
                	        $b_hang=$b_start-1;
	                        $dir="I";
        	        }
                }

		if($dir)
		{
			$h{$a_id}{$b_id}=1;

			if($switched)
                        {
                                ($a_id,$b_id)=($b_id,$a_id);
                                
                                if($dir eq "N") { ($a_hang,$b_hang)=(-$a_hang,-$b_hang); }
                                else            { ($a_hang,$b_hang)=($b_hang,$a_hang); }
                        }      

			if($options{tab})
			{
				print join "\t",($a_id,$b_id,$dir,$a_hang,$b_hang,$f[6],$f[9]);
				print "\n";	
			}
			else
			{
			       print join "\n",("{OVL",
			                "adj:$dir",
			                "rds:$a_id,$b_id",
			                "scr:0",
			                "ahg:$a_hang",
			                "bhg:$b_hang",
			                "}");
			        print "\n";
			}
		}		
                else
                {
                        # warn "IGNORE: $_";
                }

	}

	
	exit 0;
}
