# !/usr/bin/perl

# stripSmapSeq.pl	:	strips a sequence from an smap file

use strict;

	if( @ARGV < 2 )
		{
		printf( "usage: stripSeq <smapFile> <iSeq>\n" );
		exit( 0 );
		}

	my $sMapfile = shift;
	my $iSeq = shift;

	if( $iSeq != 1 && $iSeq != 2 )
		{ die "Error: iSeq must be 1 or 2"; }
	my $iPrintFld = 1;
	if( $iSeq == 2 )
		{ $iPrintFld = 3; }

	open( FIN, "<$sMapfile" ) or die "Error: failed opening file '$sMapfile' for input";

	my $iLine = 0;
	my $sLine;
	while( $sLine = <FIN> )
		{
		++$iLine;
		if( $sLine =~ /^#/ )
			{ next; }
		# strip crlf
		$sLine =~ s/\r//;
		$sLine =~ s/\n//;

		# why the hell doesn't split( /\s+/, $sLine ) work?
#		my @flds = split( /\s+/, $sLine );
		my @flds = split( ' ', $sLine );
		if( @flds < 5 )
			{ die( "Error: failed parsing fields from line $iLine" ); }
		
		my $ch = $flds[$iPrintFld];
		if( $ch ne '.' )
			{ printf( $ch . "\n" );	}
		}

	close( FIN );
