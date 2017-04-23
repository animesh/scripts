#!/usr/bin/perl -w
use strict;
use TIGR::Foundation;

my $USAGE = "Usage: filter_contig contigfile id\n";

my $HELPTEXT = qq~
Extract a specified contig id from a contig or layout file

  $USAGE
~;

my $VERSION = " Version 1.00 (Build " . (qw/$Revision: 1.1 $/ )[1] . ")";

my @DEPENDS = 
(
  "TIGR::Foundation",
);

my $tf = new TIGR::Foundation;
$tf->addDependInfo(@DEPENDS);
$tf->setHelpInfo($HELPTEXT);
$tf->setVersionInfo($VERSION);
my $result = $tf->TIGR_GetOptions();

$tf->bail("Command line parsing failed") if (!$result);

my $contigname = shift @ARGV;
my $contig_id = shift @ARGV;

die $USAGE if (!defined $contigname || !defined $contig_id);

my $doprint = 0;

open CONTIG, "< $contigname" 
  or $tf->bail("Could't open $contigname ($!)");

while (<CONTIG>)
{
  if (/\#\#(\S+)/)
  {
    last if ($doprint); # already extracted the requested id 

    $doprint = ($1 eq $contig_id);
  }

  print $_ if $doprint;
}

close CONTIG;

$tf->bail("Id $contig_id not found") if !$doprint;
