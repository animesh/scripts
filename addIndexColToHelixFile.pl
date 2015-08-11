# !/usr/bin/perl

# addIndexColToHelixFile.pl	:	script to add an 0-based index field to helix data files

use strict;

#-------------
# isCommentLine
#-------------
sub isCommentLine
	{
	my $l = shift;
	return ( $l =~ m/^#/ );
	}

#-------------
# isWhitespaceLine
#-------------
sub isWhitespaceLine
	{
	my $l = shift;
	return ( $l =~ m/\w/ ) == 0;
	}

#-------------
# main
#-------------
	mkdir( "tmp" );
	my @files = glob( "*.hlx" );
	my $f;
	my $iTotalP = 0;
	foreach $f (@files)
		{
#		print( "$f\n" );
		
		my $fout = "tmp\\" . $f;
		open( FIN, "<$f" ) or die( "Error: failed opening file '$f' for input" );
		open( FOUT, ">$fout" ) or die( "Error: failed opening file '$fout' for output" );

		my $sLine;
		my $iHelixIdx = 0;
		while( $sLine = <FIN> )
			{
			my $sLineOut = $sLine;
			if( (not isWhitespaceLine( $sLine )) && (not isCommentLine( $sLine )))
				{ 
				$sLineOut = "$iHelixIdx\t" . $sLineOut;
				++$iHelixIdx;
				}
			print( FOUT $sLineOut );
			}
		close( FOUT );
		close( FIN );
		++$iTotalP;
		}

	printf( "$iTotalP file(s) output to 'tmp' dir\n" );
