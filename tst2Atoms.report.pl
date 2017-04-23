# !/usr/bin/perl

# tst2Atoms.report.pl

use strict;
require '../../../../exp/dev/report/FileUtil.pl';

my $f_sScript = "tst2Atoms.report";
my $f_sDescrip = "Creates an html report for the output of the tst2Atoms unit test";

#-------------------------------------------------------------------------------------------------
# createPlotImage
#-------------------------------------------------------------------------------------------------
sub createPlotImage
	{
	my $sInFile = shift;
	my $sOutFile = shift;

	my $fEqDist = 3.64;

	# create plot commands
	my $fXScale = 2;
	my $fYScale = 2;
	my $sSettings = 
			"set term png color;\n"
		.	"set size $fXScale,$fYScale;\n"
		. 	"set output '$sOutFile';\n"
		.	"xAxis = 0;\n";

	my $sXLimits = "[0:10]";
	my $sYLimits = "[-5:5]";
	my $iLineType = 1;
	my $iPlotCol0 = 3; # distance
	my $iPlotCol1 = 4; # fx
	my $iPlotCol2 = 7; # energy
	my @plotLines;

	# plot force
	my $sPlotLine = "plot $sXLimits $sYLimits '$sInFile' u $iPlotCol0:$iPlotCol1 title \"force\" w l lt $iLineType,\\\n";
	push( @plotLines, $sPlotLine );
	++$iLineType;

	# plot energy
	$sPlotLine = "'' u $iPlotCol0:$iPlotCol2 title \"energy\" w l lt $iLineType,\\\n";
	push( @plotLines, $sPlotLine );
	++$iLineType;

	# plot x Axis
	$sPlotLine = "xAxis w l lt $iLineType,\\\n";
	push( @plotLines, $sPlotLine );
	++$iLineType;

	# plot eqDist axis
	$sPlotLine = "sgn( x - $fEqDist ) * 4 w l lt $iLineType;\n";
	push( @plotLines, $sPlotLine );
	++$iLineType;

	# gnuplot (or OS file flush) bug: need unique cmd file to get output
	my $sFile = "$sOutFile.cmd";
	open( FOUT_PLOT, ">$sFile" ) or die Foffo( $sFile );
	print( FOUT_PLOT $sSettings );
	print( FOUT_PLOT @plotLines );
	close( FOUT_PLOT );

	# create plots
	my $sCmdFile = $sFile;
	my $sCmd = "gnuplot $sCmdFile";
	my $rc = system( $sCmd );
	if( $rc != 0 )
		{ die "Error: system() returned '$rc' on command '$sCmd'"; }

	}# createPlotImage

#-------------------------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------------------------
	
	if( @ARGV && $ARGV[0] == "--help" )
	{
		printf( "usage: $f_sScript\n" );
		printf( "\n" );
		printf( "$f_sDescrip\n" );
		exit( 0 );
	}

	# get input file
	my $sInfile = "tst2Atoms.stericData";

	# create plot
	createPlotImage( 
		$sInfile, 
		"$sInfile.png" );

	# open outfile
	my $sOutfile = "$sInfile.html";
	open( FOUT, ">$sOutfile" ) or die( Foffo( $sOutfile ));

	# do html report
	my $sTitle = "Report for $sInfile";

	my $sHtmlTop = 
<<HtmlTop;
<html>
<head>
<title>$sTitle</title>
<link rel=stylesheet type="text/css" href="style.css">
</head>
<body>
<center>
<h1>$sTitle</h1>
</center>
<ul>
<li><a href="#Plot">Force and Energy plot</a>
</ul>

<h2><a name="Plot">Force and Energy plot</a></h2>
<img src="$sInfile.png">

HtmlTop

	my $sHtmlBot =
<<HtmlBot;
</body>
</html>
HtmlBot

	print( FOUT $sHtmlTop );
	print( FOUT $sHtmlBot );
	close( FOUT );
