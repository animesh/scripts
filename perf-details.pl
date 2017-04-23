#!/usr/bin/perl

use strict;
use Carp;

use CGI qw( :cgi);
use DB_File;
use File::Basename;
use CGI::FastTemplate;

use PerfLogIterator;

sub dbCompare { $_[1] <=> $_[0] };

$DB_BTREE->{compare} = \&dbCompare;

my $q = new CGI; #({ file => "localhost.logdb",  tm => 942423055});
my @missing = map { ! $q->param($_) ? $_ : () } qw( file tm);

errHTML("missing required CGI parameters") if ( @missing > 0);

my (%log, $logDB);

$logDB = tie %log, "DB_File", $q->param('file'), O_RDONLY, 0644, $DB_BTREE or 
  errHTML("`". $q->param('file'). "': $!");

my $record = $log{ $q->param('tm') };
exit(0) unless( $record);

my %assignHash = ();
@assignHash{
  qw(CpuInfo NetCounters MemInfo PageCounters ProcCounters MySQL DiskCounters)
} = ({},{},{},{},{},{},{});

my $tplStat = new CGI::FastTemplate( dirname($0)."/archiver/tpl");
$tplStat->define(
  main           => 'main.tpl',
  cpu_info       => 'cpu_info.tpl',
  mem_info       => 'mem_info.tpl',
  net_counters   => 'net_counters.tpl',
  disk_counters  => 'disk_counters.tpl',
  page_counters  => 'page_counters.tpl',
  proc_counters  => 'proc_counters.tpl',
  mysql_counters => 'mysql_counters.tpl',
);

my $perfITR = new PerfLogIterator \$record;

$tplStat->assign(
   SAMPLE_DATE => 
     $perfITR->getLogInterval() .
     " Second performance sample as of " .
     $perfITR->getLogTMS()
);

my $metricHash;

while ($perfITR->nextMetric()) {
  if( $metricHash = $assignHash{ $perfITR->getMetricGroup()}) {
    $tplStat->assign( $perfITR->getUCaseMetrics( $metricHash));
  }
}

$tplStat->parse(MYSQLCOUNTERS   => "mysql_counters");
$tplStat->parse(PROC            => "proc_counters");
$tplStat->parse(MEMINFO         => "mem_info");
$tplStat->parse(NETWORKCOUNTERS => "net_counters");
$tplStat->parse(CPU_INFO        => "cpu_info");
$tplStat->parse(DISKCOUNTERS    => "disk_counters");
$tplStat->parse(PAGECOUNTERS    => "page_counters");
$tplStat->parse(SAMPLE_DATE     => "main");

$tplStat->print();

exit 0;

sub errHTML {
  my $errSTR = $_[0];
  my $prog   = basename($0);
  print <<"EOR";
Content-type: text/html

<HTML>
<HEADER>
  <TITLE>$prog error</TITLE>
</HEADER>
<BODY>
<H2>Unexpected Condition Ecountered</H2>
<P>$errSTR</P>
</BODY>
</HTML>
EOR

  exit(0);
}
