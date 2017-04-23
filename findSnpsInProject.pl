#!/usr/bin/perl -w

###########################################################################
#                   SOFTWARE COPYRIGHT NOTICE AGREEMENT                   #
#       This software and its documentation are copyright (2007) by the   #
#   Broad Institute/Massachusetts Institute of Technology.  All rights    #
#   are reserved.  This software is supplied without any warranty or      #
#   guaranteed support whatsoever. Neither the Broad Institute nor MIT    #
#   can be responsible for its use, misuse, or functionality.             #
###########################################################################


#Find SNPs in a project extracted with makeSnpProject.pl

use strict;
use File::Basename;
use Getopt::Long;
#use Cwd 'abs_path';

my $VERSION="\$Revision\$ ";

my $mapOptions = "";	
my $callOptions = "";

GetOptions ('map:s' => \$mapOptions,
	    'call:s' => \$callOptions) ||
die "Could not process options correctly";

sub usage {
  print "\n Usage: findSnpsInProject.pl --map=\"mapping options\" --count=\"counting options\" project_directory reference.fasta\n\n",

  "example: findSnipsInProject.pl --map'\"MAX_INDELS=1\" --call=\"MIN_READS=2\" /wga/dev/WGAdata/projects/Simulation/S229   /wga/dev/WGAdata/projects/Dog/run/work/Final/mergedcontigs.fastb  \n\n",

  "output_directory must be a complete pathname and is where all the files will end up\n\n",

  "lookuptable must have been generated from the reference with MakeLookupTable\n\n",

  "genomesize must be an integer estimate of the size of the genome\n\n",

  "projectNameX is the name in the trace archive database for each project.\n\n",
  "";
}

if (@ARGV < 2) {
  usage();
  exit;
}
my $dir = $ARGV[0];
my $ref = $ARGV[1];


chdir($dir) || die "could not cd to $dir";
system("MapNQSCoverage $mapOptions FASTA=reads/reads.fastb QUAL=reads/reads.qualb QLTOUT=reads/reads.qltout REF=$ref O=reads/reads PRINT_INDELS=False PRINT_ZERO_COV=False Q=40 NQ=35");
system("CallPolymorphismsFromMap $callOptions IN=reads/reads.coverage_map NEED_RC=False MIN_READS=1 MIN_RATIO=0.1 SUMMARY=False > reads.calls");
