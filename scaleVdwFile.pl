# !/usr/bin/perl

use strict;
require 'exp\\dev\\report\\FileUtil.pl';

my $f_sScript = "scaleVdwFile.pl";
my $f_sDescrip = "Produces a new vdw parameter file with values from an input file multiplied by a param factor";

	if( @ARGV < 2 )
	{
		print( "usage: $f_sScript <sInFile> <fScaleFactor>\n" );
		print( "$f_sDescrip\n" );
		exit( 0 );
	}

	my $sInfile = shift;
	my $fScaleFactor = shift;

	# read input file
	my %atomTypeVdwRadius = CreateHashFromFile( $sInfile );

	# open outfile
	my $sOutfile = "$sInfile.scale$fScaleFactor";
	open( FOUT, ">$sOutfile" ) or die Foffo( $sOutfile );

	# output new radii to outfile
	my $iTotalVals = 0;
	my $at;
	foreach $at ( keys %atomTypeVdwRadius )
	{
		my $fOldRadius = $atomTypeVdwRadius{$at};
		my $fNewRadius = $fOldRadius * $fScaleFactor;
		my $sAt = sprintf( "%-20s", $at );
		print( FOUT "$sAt\t$fNewRadius\n" );
		++$iTotalVals;
	}

	close( FOUT );

	# report
	print( "$iTotalVals scaled radii written to $sOutfile\n" );
