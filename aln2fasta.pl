#!/usr/bin/perl

# aln2fasta.pl

use strict;

my $f_sScript = "aln2fasta.pl";
my $f_sDescrip = "Converts an .aln file, as output from the seqaln globalS program, into two separated aligned sequences in FASTA format";

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

	if( @ARGV < 2 )
	{
		print( "usage: $f_sScript <alnFile> <outFile>\n" );
		print( "$f_sDescrip\n" );
		exit( 1 );
	}

	my $sAlnFile = shift;
	my $sOutFile = shift;

	my ( $sSeqName1, $sSeqName2 );
	my $sSeq1 = "";
	my $sSeq2 = "";
	open( FIN, "<$sAlnFile" ) or die( "Error: failed opening file $sAlnFile for input" );
	my $iLine = 0;
	my $sLine;
	while( $sLine = <FIN> )
	{
		++$iLine;				

		# skip first 2 lines (blank, score line)
		if(	$iLine < 3 )
		{ 
			# parse sequence names from score line
			if( $iLine == 2 )
			{
				my ( $sSeqN1, $sSeqN2 ) = ( $sLine =~ /\((.*)\).*\((.*)\)/g );
#				print( "seq1=$sSeq1 seq2=$sSeq2\n" );
				if( !defined( $sSeqN1 ) or !defined( $sSeqN2 ))
					{ die( "Error: failed parsing sequence names from line $iLine" ); }
				$sSeqName1 = $sSeqN1;	
				$sSeqName2 = $sSeqN2;	
			}
			next; 
		}
				
		$sLine =~ tr/ACGUTagcut\- \t\n\r/ /c;
#		print( $sLine );
		my $iSeqLine = $iLine - 3;
		my $sm3 = $iSeqLine % 3;
		if( ( $iSeqLine % 3 ) == 0 )
			{ $sSeq1 .= $sLine; }
		elsif( ( $iSeqLine % 3 ) == 2 )
			{ $sSeq2 .= $sLine; }
	}# end while doin lines
	close( FIN );

	# print seqs
#	my $sOutFile = $sAlnFile .. ".seq";
	open( FOUT, ">$sOutFile" ) or die( "Error: failed opening file $sOutFile for output" );
	print( FOUT ">$sSeqName1\n$sSeq1\n" );
	print( FOUT ">$sSeqName2\n$sSeq2\n" );
	close( FOUT );

