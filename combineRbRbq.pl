#!/usr/bin/perl

use strict;

#--------------------------------------------------------------------------------------------------------
# ReadFile
#--------------------------------------------------------------------------------------------------------
sub ReadFile
{
	my $sFile = shift;
	my $raEntries = shift;

	open( FIN, "<$sFile" ) or die;
	my $sEntry = undef;
	my $iLine = 0;
	my $sLine;
	while( $sLine = <FIN> )
	{
		$iLine = $iLine + 1;
		# start new entry if html header line found
		if( $sLine =~ /^</ )
		{
			if( $sEntry )
			{
				push( @$raEntries, $sEntry );
			}
#			$sEntry = "$sFile:$iLine " . $sLine;
			$sEntry = $sLine;
		}
		# else, append line to current entry
		else
		{
			if( !$sEntry )
			{
				print( "sEntry is undef, $sFile:$iLine = '$sLine'\n" );
				die;
			}
			$sEntry = $sEntry . $sLine;
		}
	}
	close( FIN );
}# ReadFile

#--------------------------------------------------------------------------------------------------------
# HeaderSort
#--------------------------------------------------------------------------------------------------------
sub HeaderSort
{
	my ($ya, $ma, $da) = ($a =~ /(\d+)\-(\d+)\-(\d+)/);
	if( !$ya )
	{ 
		print( "failed extracting date, a='$a' b='$b'\n" );
		die; 
	}
	my ($yb, $mb, $db) = ($b =~ /(\d+)\-(\d+)\-(\d+)/);
	if( !$yb )
	{ 
		print( "failed extracting date, a='$a' b='$b'\n" );
		die; 
	}

	if( $ya < $yb )
		{ return -1; }
	elsif( $yb < $ya )
		{ return 1; }
	if( $ma < $mb )
		{ return -1; }
	elsif( $mb < $ma )
		{ return 1; }
	if( $da < $db )
		{ return -1; }
	elsif( $db < $da )
		{ return 1; }
	return 0;
}# HeaderSort

#--------------------------------------------------------------------------------------------------------
# main
#--------------------------------------------------------------------------------------------------------
	my $sRbFile = "rblog.html";
	my $sRbqFile = "rbqHist.html";


	my @rbEntries;
	ReadFile( $sRbFile, \@rbEntries );
	my $iTotalRbEnts = @rbEntries;
#	print( "$iTotalRbEnts entries read from $sRbFile\n" );

	my @rbqEntries;
	ReadFile( $sRbqFile, \@rbqEntries );
	my $iTotalRbqEnts = @rbqEntries;
#	print( "$iTotalRbqEnts entries read from $sRbqFile\n" );

	my @entries;
	push( @entries, @rbEntries );
	push( @entries, @rbqEntries );
	
	my @sortedEntries = sort HeaderSort @entries;
	my $iLine;
	for( $iLine = 0; $iLine < @sortedEntries; ++$iLine )
	{
		print( $sortedEntries[$iLine] );
	}
