# substringInFiles.pl	:	script to substitute a param string in param filespec

use strict;

	if( @ARGV != 3 )
	{
		print( "usage: substringInFiles <string> <substring> <filespec>\n" );
		exit( 0 );
	}
	
	my $sString = shift;
	my $sSubString = shift;
	my $sFilespec = shift;

	print( "Substituting '$sString' with '$sSubString' for files '$sFilespec'...\n" );

	my @files = glob( $sFilespec );
	my $file;
	foreach $file (@files)
	{
		print( "$file:\n" );
		my $sOutfile = $file . ".tmp";
		open( FIN, "<$file" ) or die( "Error: failed opening file $file for input" );
		open( FOUT, ">$sOutfile" ) or die( "Error: failed opening file $sOutfile for output" );
		my $sLine;
		while( $sLine = <FIN> )
		{
			$sLine =~ s/$sString/$sSubString/g; 
			print( FOUT $sLine );
		}
		close( FOUT );
		close( FIN );
		unlink( $file ) or warn( "Warning: failed deleting file '$file'\n" );
		rename( $sOutfile, $file ) or warn( "Warning: failed renaming file '$sOutfile' to '$file'\n" );
	}
	print( "Done.\n" );	
