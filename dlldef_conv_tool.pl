# ================================================================================
# Copyright 2006 The MathWorks, Inc.
#
# File : dlldef_conv_tool.pl   $Revision: 1.1.6.2 $
#
# Abstract:
#     Script to convert the TLC generated .def file to the format specific
# to certain compilers. For WatcomC, a temp $(MODEL).deflnk file is created 
# according to the content of $(MODEL).def and being passed to wlink with
# @$(MODEL).deflnk option
# 
# Usage:
#     perl $(MODEL).def COMPILER_NAME
#     COMPILER_NAME is WATC
# =================================================================================

my $fileName = $ARGV[0];
my $tempName = $fileName.".temp";
my $linkName = $fileName."lnk";
my $compilerName = $ARGV[1];

if ($compilerName eq 'WATC') {
	
	open FILE, "<$fileName" or die "Can not open file $fileName: $!\n";
	open DEFLNK, ">$linkName" or die "Can not create temp file $tempName: $!\n";
	
	while (<FILE>) {
		next if /^EXPORTS/;
		if ($_ !~ /^\s*\n/) {
			if (/^(\s*)(.+)\n/) {
				$_ = $1."EXPORT ".$2."\n";
			}
		}
		print DEFLNK $_;
	}
	close DEFLNK;
	close FILE;
	
} else {
	print "No action.\n";
}

