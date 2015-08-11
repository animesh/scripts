#!/usr/bin/perl

# cleanSeq.pl

use strict;

my $f_sScript = "cleanSeq.pl";
my $f_sDescrip = "Except for FASTA lines (ie: '>SeqName ...' ), removes all characters except [ACGTUacgtu- \\t\\n\\r]";

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

	if( @ARGV < 1 )
	{
		print( "usage: $f_sScript <seqFile>\n" );
		print( "$f_sDescrip\n" );
		exit( 0 );
	}

	my $sSeqFile = shift;
	open( FIN, "<$sSeqFile" ) or die( "Error: failed opening file $sSeqFile for input" );
	my $sLine;
	while( $sLine = <FIN> )
	{
		if(	$sLine =~ /^>/ )
			{ 
			print( $sLine );
			next; 
			}
				
		$sLine =~ tr/ACGUTagcut\- \t\n\r/ /c;
		print( $sLine );
	}
	close( FIN );

