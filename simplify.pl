#!/usr/bin/env perl
use FwgLib;
if ($#ARGV < 0) {
	print "usage: simplify.pl infile \n";
	print "  There must exist infile.bgraph infile.edge infile.intv\n";
	exit(0);
}

$infile = shift @ARGV;
$infile =~ /(.*)\.(.*)/;
$base = $1;
$mach    = FwgLib::CrucialGetEnv("MACHTYPE");
$mcsrc   = FwgLib::CrucialGetEnv("MCSRC");

if ($base eq "") {
	print "Error, input file must be of format file.ext\n";
	exit(1);
}
$outfile = $base . ".simple";
$cmd ="$mcsrc/assembly/$mach/simplifyGraph $infile $outfile -minComponentSize 500 -minEdgeLength 50 -removeLowCoverage 4 -removeSimpleBulges 80";
print "$cmd\n";
system($cmd);

