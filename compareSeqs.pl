# !/usr/bin/perl

# compareSeqs.pl	:	compares 2 sequences for differences

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
# readSeq
#-----------------------------------------------------------------------------------------
sub readSeq
	{
	my $sFile = shift;

	open( FIN, "<$sFile" ) or die "Error: failed opening file '$sFile' for input";

	my @seqRet;

	my $iLine = 0;
	my $sLine;
	while( $sLine = <FIN> )
		{
		++$iLine;

		# strip crlf
		$sLine =~ s/\r//;
		$sLine =~ s/\n//;

		# read each char in line as a sequence char
		my $ic;
		my $iLen = length( $sLine );
		for( $ic = 0; $ic < $iLen; ++$ic )
			{
			my $ch = substr( $sLine, $ic, 1 );
			if( not isNuc( $ch ))
				{ die( "Error: invalid sequence symbol '$ch' found on line $iLine" ); }

			# save in ret array
			push( @seqRet, $ch );
			}
		}

	close( FIN );

	return @seqRet;
	}# readSeq

#-----------------------------------------------------------------------------------------
# main
#-----------------------------------------------------------------------------------------
	if( @ARGV < 2 )
		{
		printf( "usage: compareSeqs <file1> <file2>\n" );
		exit( 0 );
		}

	my $sFile1 = shift;
	my $sFile2 = shift;

	my @seq1 = readSeq( $sFile1 ); 
	my @seq2 = readSeq( $sFile2 ); 

	my $iTotal1 = @seq1;
	my $iTotal2 = @seq2;

	printf( "$iTotal1 nts read from '$sFile1'\n" );
	printf( "$iTotal2 nts read from '$sFile2'\n" );
	
	# quit if not same size
	if( $iTotal1 != $iTotal2 )
		{
		printf( "Sequences are different size.\n" );
		exit( 0 );
		}

	my $iTotalDiffs = 0;
	my $iNt;
	for( $iNt = 0; $iNt < $iTotal1; ++$iNt )
		{
		my $ch1 = $seq1[$iNt];
		my $ch2 = $seq2[$iNt];
		if( $ch1 ne $ch2 )
			{
			printf( "pos $iNt: seq1 = $ch1, seq2 = $ch2\n" );
			++$iTotalDiffs;
			}
		}

	printf( "$iTotalDiffs total differences found\n" );
	
