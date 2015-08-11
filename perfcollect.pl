#!/usr/bin/perl

use 5.005;
use strict;

use vars qw($VERSION $DONE);

use File::Basename;
use lib dirname($0), dirname($0) . "/../perlib";

use Carp;

use IO::Handle;
use IO::Socket::INET;
use IO::Select;
use IO::File;
use Getopt::Long;
use POSIX qw(strftime setsid);
use Time::HiRes;
use Sys::Hostname;

use SyslogTIE;
use PerfMetric::MySQL;
use PerfMetric::LoadAverage;
use PerfMetric::NetCounters;
use PerfMetric::MemInfo;
use PerfMetric::CpuInfo;
use PerfMetric::DiskCounters;
use PerfMetric::PageCounters;
use PerfMetric::ProcCounters;

use constant FnamePOS  => 0;
use constant SamplePOS => 1;

$VERSION = sprintf("%d.%02d", q$Revision: 1.9 $ =~ /(\d+)\.(\d+)/);

umask 002;

$DONE = 0;

my $POPT  = {};
parseOptions( $POPT);

main() unless( $POPT->{daemon});

$SIG{CHLD} = \&REAPER;

my $pid = 0;
my $retries = 4;

dtchBLOCK: {
  $pid = fork;

  $pid == 0 && do {
    close STDOUT; close STDIN; close STDERR;

    tie *STDERR, "SyslogTIE", ident => basename($0);

    POSIX::setsid or croak "(lstn) process session: $!";

    @SIG{qw(INT HUP TERM)}     = ((\&GONER) x 3);
    @SIG{qw(__DIE__ __WARN__)} = ((\&TOSTDERR) x 2);

    my $pidFN = "/var/tmp/perfcollect.pid";

    open  PIDF, ">$pidFN" or croak "(dtch) `$pidFN': $!";
    print PIDF  "$$\n";
    close PIDF;

    main();
  };

  # in parent process
  $pid > 0 && exit( 0);

  # EGAIN sleep one second and retry fork
  $! =~ /o more process/ && $retries > 0 && do {
    $retries--;
    sleep 1.0;
    redo dtchBLOCK;
  };

  # either no retries left, or some other error
  croak "dettach fork: $!";
}

sub main {

  my $loadPM  =  PerfMetric::LoadAverage->new();
  my $netPM   =  PerfMetric::NetCounters->new();
  my $memPM   =  PerfMetric::MemInfo->new();
  my $cpuPM   =  PerfMetric::CpuInfo->new();
  my $diskPM  =  PerfMetric::DiskCounters->new();
  my $pagePM  =  PerfMetric::PageCounters->new();
  my $procPM  =  PerfMetric::ProcCounters->new();
  my $mysqlPM =  PerfMetric::MySQL->new(
    dbDb       => $POPT->{'database'},
    dbUser     => $POPT->{'user'},
    dbPassword => $POPT->{'password'}
  );

  my $perfMetrics = [
    $loadPM, $cpuPM, $netPM, $memPM, $pagePM, $procPM, $mysqlPM, $diskPM
  ];
  my $epochTM = 0;
  my ($beginPollTS, $endPollTS, $pollDuration, $stringDate) = ([],[],0, "");
  my ($archiverSH, $archiverSend) = (undef,undef);

  if ( $POPT->{archiver}) {

    if ( index( $POPT->{archiver}, ":") == -1) {
      $archiverSH = new IO::File( ">$POPT->{archiver}") 
	or croak "`$POPT->{archiver}': $!";
    }

    $archiverSH ||= new IO::Socket::INET(
      PeerAddr => $POPT->{archiver}, Proto => 'tcp'
    ) or croak "`$POPT->{archiver}': socket: $@ (code: $!)";

    $archiverSH->autoflush(1);
    $archiverSend =
      normalizedLoggerGenerator( $archiverSH, $perfMetrics, $POPT->{interval})
    ;
  }

  while (!$DONE ) {
    $epochTM    = Time::HiRes::time();
    $stringDate = formatTimestamp( $epochTM);

    Time::HiRes::sleep($POPT->{interval} - $pollDuration);

    @$beginPollTS = Time::HiRes::gettimeofday();

    $loadPM->sample();
    $netPM->sample();
    $diskPM->sample();
    $cpuPM->sample();
    $memPM->sample();
    $pagePM->sample();
    $procPM->sample();
    $mysqlPM->sample();

    @$endPollTS = Time::HiRes::gettimeofday();

    $pollDuration = Time::HiRes::tv_interval( $beginPollTS, $endPollTS);
    $pollDuration = $POPT->{interval} if( $pollDuration > $POPT->{interval});

    &$archiverSend( $epochTM, $stringDate) if( $archiverSH);
    last if ( $POPT->{once});
  }
  $archiverSH->close() if( $archiverSH);
  exit 0;
}

sub parseOptions ($) {
  my $optsctl = shift(@_);
  my $usage = basename($0) . <<'EOU';
: [options]
  --interval performace metrics polling interval
  --once     run through the sampling loop once
  --daemon   run as a daemon
  --archiver [host-name:port] destination where normalized logs are sent to
  --database MySQL database to connect to
  --user     user for MySQL connection
  --password prompt for the MySQL user password
  --help     this usage message
EOU
  %$optsctl = (
       "interval" => 60,
       "help"     => 0,
       "once"     => 0,
       "daemon"   => 0,
       "archiver" => '',
       "user"     => '',
       "password" => 0,
       "database" => '',
  );

  GetOptions(
    $optsctl,
    "interval=i","archiver=s","help","once","daemon","password:s",
    "user=s", "database=s"
  ) or croak $usage;

  for ( keys %$optsctl) {
  optCASE: {
      m/help/ && do {
	print $usage if ($optsctl->{$_});
	last optCASE;
      };
      m/interval/ && do {
	$optsctl->{$_} > 0 or croak "$_ $optsctl->{$_} must be positive";
	last optCASE;
      };
    }
  }
  exit(0) if( $optsctl->{'help'});
  $optsctl->{'password'} = promptPassword() unless ($optsctl->{'password'});

  my @missing =
    map { ! $optsctl->{$_} ? "--" . $_ : ()} qw(archiver user database);

  croak "options: ", join( ", ",@missing), " must be specified" if( @missing);

  return 1;
}

sub GONER {
  $DONE = 1;
  $SIG{ $_[0]} = \&GONER;
}

sub TOSTDERR {
  print STDERR @_;
}

sub REAPER {
  my $child;

  while (($child = waitpid(-1, &POSIX::WNOHANG)) != -1) {}
  $SIG{CHLD} = \&REAPER;
}

sub formatTimestamp {
  my $tm = $_[0];
  $tm = $tm->[0] . q(.) . $tm->[1] if( ref($tm) eq 'ARRAY');

  my $pIdx     = index( $tm, ".");
  my $fraction = ( $pIdx != -1 ? substr( substr( $tm, $pIdx), 0, 4) : "");

  return strftime("%Y/%m/%d %T$fraction", localtime( int( $tm)));

}

sub normalizedLoggerGenerator ($$$) {
  my ($archiverSH, $metrics,$sampleInterval) = splice(@_,0,3);

  my $selector  = new IO::Select( $archiverSH);
  my $hostname  = hostname;
  my $record    = " " x 1024;

  return sub ($$) {
    my ($timestampTM, $timestampTMS) = splice( @_,0,2);

    $record = "$timestampTMS|$timestampTM|$hostname|$sampleInterval";
    foreach my $mtr (@$metrics) {
      $record .= "|" . $mtr->toString();
    }
    $record .= "\n";

    carp "write timeout to archiver" unless( $selector->can_write(2));

    print $archiverSH $record;
  }
}

sub promptPassword {
  use Term::ReadKey;

  print "Enter Password: ";

  ReadMode 'noecho';
  my $password = ReadLine 0;
  chomp $password;
  ReadMode 'normal';

  print "\n";
  return $password;
}
