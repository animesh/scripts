# !/usr/bin/perl

use strict;

my $f_sScript = "listFuncs.pl";
my $f_sDescrip = "Scans the cpp source file which holds the rbq - lua interface functions and lists them";

#-----------------------------------------------------------------------------------------------------------------
# main
#-----------------------------------------------------------------------------------------------------------------
	if( @ARGV < 2 )
	{
		printf( "usage: $f_sScript <cppFile> <outFile>\n" );
		printf( "\n" );
		printf( "$f_sDescrip.\n" );
		exit( 0 );
	}
	my $sCppFile = shift;
	my $sOutFile = shift;

	# open infile
	open( FIN, "<$sCppFile" ) or die( "Error: failed opening file $sCppFile for input" );
	open( FOUT, ">$sOutFile" ) or die( "Error: failed opening file $sOutFile for output" );

	my $bInCommentBlock = 0;
	
	my $iTotalFuncs = 0;
	my $sLine;
	my $iCurLine = 0;

	# process each line in file
	while( $sLine = <FIN> )
	{
		++$iCurLine;

		# trim leading ws
		$sLine =~ s/^\s+//;

		# format: function documentation block begins with '// rbq_'
		# followed by '// descrip', '// params', etc.

		my $bCommentLine = ( $sLine =~ /^\/\// );

		# check for start of comment block
		if( $sLine =~ /^\/\/ rbq_/ )
		{
			# make sure not already in a comment block
			if( $bInCommentBlock) 
				{ die( "Error: found start of comment block while already in a comment block at line $iCurLine" ); }

			++$iTotalFuncs;
			$bInCommentBlock = 1;

			my ($f1, $f2) = split( ' ', $sLine );
			if( not defined( $f2 ))
				{ die( "Error: failed parsing function name on line $iCurLine" ); }

			# print func name
			print( FOUT "$f2\n" );
		}
		# check for end of comment block
		elsif( $bInCommentBlock && !$bCommentLine )
		{
			$bInCommentBlock = 0;
		}
		
	}# end for all lines in file

	close( FOUT );
	close( FIN );
#	printf( "$iCurLine line(s) read, $iTotalFuncs function(s) processed.\n" );

