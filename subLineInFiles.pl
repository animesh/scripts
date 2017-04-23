# subLineInFiles.pl	:	script to substitute a line with a specified string in param filespec and output new versions to param dir

use strict;

my $sString = "load\( \"ChemUtil\.lua\" \);";
my $sCheckString = "ChemUtil.lua";
my $sSubString = "\tload( \"ForceFieldUtil.lua\" );\n\tload( \"ForceObjectUtil.lua\" );\n";
my $sPathSep = "\\";

	if( @ARGV != 2 )
	{
		print( "usage: substringInFiles <filespec> <outdir>\n" );
		exit( 0 );
	}
	
#	my $sString = shift;
#	my $sSubString = shift;
	my $sFilespec = shift;
	my $sOutDir = shift;

	print( "Substituting '$sString' with '$sSubString' for files '$sFilespec'...\n" );

	my $iTotalLinesFound = 0;
	my @files = glob( $sFilespec );
	my $file;
	foreach $file (@files)
	{
		print( "$file:\n" );
		my @parts = split( /\\/, $file );
		my $sFname = $parts[@parts - 1];
		my $sOutfile = $sOutDir . $sPathSep . $sFname;
		if( -e $sOutfile )
		{
			die "Error: output file '$sOutfile' already exists";
		}
		open( FIN, "<$file" ) or die( "Error: failed opening file $file for input" );
		open( FOUT, ">$sOutfile" ) or die( "Error: failed opening file $sOutfile for output" );
		my $sLine;
		while( $sLine = <FIN> )
		{
#			if( $sLine =~ /$sString/ )
			if( $sLine =~ /load\( \"ChemUtil\.lua\" \);/ )
			{
				$iTotalLinesFound = $iTotalLinesFound + 1;
				print( FOUT $sSubString );
			}
			else
			{
				print( FOUT $sLine );
				if( $sLine =~ /$sCheckString/ )
				{
					print( $sLine );
					die;
				}
			}
		}
		close( FOUT );
		close( FIN );
#		unlink( $file ) or warn( "Warning: failed deleting file '$file'\n" );
#		rename( $sOutfile, $file ) or warn( "Warning: failed renaming file '$sOutfile' to '$file'\n" );
	}
	print( "Done.\n" );	
	print( "$iTotalLinesFound total line(s) substituted.\n" );

