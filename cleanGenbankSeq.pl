# !/usr/bin/perl

# cleanGenBank.pl	:	cleans up a sequence from an embl genbank sequence of 23S rna 
use strict;

#-----------------------------------------------------------------------------------------
# isNuc
#-----------------------------------------------------------------------------------------
sub isNuc
	{
	my $ch = uc( shift );

	my $bNuc;
	$bNuc = ( 
			( $ch eq 'A' )
		or  ( $ch eq 'C' )
		or  ( $ch eq 'G' )
		or  ( $ch eq 'U' )
		or  ( $ch eq 'T' ));
	
	return $bNuc;
	}# isNuc

#-----------------------------------------------------------------------------------------
# main
#-----------------------------------------------------------------------------------------
	if( @ARGV < 1 )
		{
		printf( "usage: cleanGenbankSeq.pl <inFile>\n" );
		exit( 0 );
		}

	my $sInfile = shift;

	open( FIN, "<$sInfile" ) or die "Error: failed opening file '$sInfile' for input";

	my $bAtSequence = 0;
	my $iLine = 0;
	my $sLine;
	while( $sLine = <FIN> )
		{
		++$iLine;

		# skip all lines until 'SQ' line read
		if( !$bAtSequence )
			{
			if( $sLine =~ /^SQ/ )
				{ $bAtSequence = 1; }
			next; 
			}

		# strip crlf
		$sLine =~ s/\r//;
		$sLine =~ s/\n//;

		# print line
#		print( "$sLine\n" );
		my $ic;
		my $iLen = length( $sLine );
		for( $ic = 0; $ic < $iLen; ++$ic )
			{
			my $ch = substr( $sLine, $ic, 1 );
			if( isNuc( $ch ))
				{ print( $ch ); }
			}
		}

	close( FIN );
