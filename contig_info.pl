#!/util/bin/perl -w
use strict;
use FileHandle;

use vars qw($dataDir
	    $runDir
	    $subDir
	    $augalignsDir
	    $chr
	    $contig
	    $bHelp
	    $outfile );

main();

sub PrintOptions
{
  print << "EOF";
Usage: contig_info.pl [options]
Options:
--help                     Display this information.
--data=<dir>               Specifiy an Arachne 'DATA' directory.
--run=<dir>                Specifiy an Arachne 'RUN' directory.
--subdir=<dir>             Specifiy an Arachne 'SUBDIR' directory.
--augaligns=<dir>          Directory with the chimp-reads-on-human files.
--chrm=<chromosome>        Specify a chromosome.
--contig=<integer>   Start contig 
--outfile=<str>      File to put the output in
EOF
}

sub main
{
  autoflush STDOUT 1;
  
  # set our environment variables so we can find our executables
  $ENV{PATH} = "/util/bin:/usr/bin";
  die( "ARACHNE_PRE was not defined in your environment.\n" )
    if ( ! exists( $ENV{'ARACHNE_PRE'} ) );
  
  use File::Path;
  use Getopt::Long;

  $dataDir = "";
  $runDir = "";
  $subDir = "";
  $augalignsDir = "";
  $chr = 0;
  $bHelp = 0;
  $contig = -1;
  $outfile = "";

  &GetOptions( "data=s"               => \$dataDir,
	       "run=s"                => \$runDir,
	       "subdir=s"             => \$subDir,
	       "augaligns=s"          => \$augalignsDir,
	       "chrm=i"               => \$chr,
	       "help"                 => \$bHelp,
	       "contig=i"             => \$contig,
	       "outfile=s"            => \$outfile );

  
  if ($bHelp) {
    PrintOptions();
    exit;
  }
  

  if ( $chr == 0 ) {
    print "You must assign a chromosome (use --chrm=<chromosome>)\n";
    exit;
  }

  if ( $contig == -1 ) {
    print "You must assign a contig (use --contig=<integer>)\n";
    exit;
  }

  if ( $outfile eq "" ) {
    print "You must assign an output file (use --outfile=<str>)\n";
    exit;
  }

  my $strDataRun = "DATA=$dataDir RUN=$runDir";
  my $strLAdir = "AUGMENTED=$augalignsDir";
  my $strChr = "FIRST_CHR=$chr LAST_CHR=$chr";
  my $commonCmd = "$strDataRun $strChr contig=$contig";
  my $commonCmdLA = "$commonCmd $strLAdir";
  
  my $cmmdContigInfo = "./PrintContigInfo NO_HEADER=True SUBDIR=$subDir $commonCmd coverage=False > $outfile";

  my $cmmdCheckHaps = "./CheckHaplotypes NO_HEADER=True SUBDIR=$subDir $commonCmdLA >> $outfile"; 

  my @cmmdsToRun;
push @cmmdsToRun, $cmmdContigInfo;
push @cmmdsToRun, $cmmdCheckHaps;

  my $result;
  foreach my $cmmd (@cmmdsToRun) {
    print "\nRunning:  $cmmd\n";
    $result = system("$cmmd");
    if ($result != 0) {
      system("echo $cmmd terminated with return code = $result" );
    }
  }
  
}
