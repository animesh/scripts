#!/usr/local/bin/perl -w
use strict;
use TIGR::AsmLib;
use TIGR::Foundation;

my $version = '$Revision: 1.2 $ ';

my $helptext = qq~
    listSurrogates.pl [-i] fname
    ~;

my $base = new TIGR::Foundation;

if (! defined $base){
    print STDERR "Nasty error, hide!\n";
    exit(1);
}

$base->setHelpInfo($helptext);
$version =~ s/\$//g;
$base->setVersionInfo($version);

my $infile;

my $err = $base->TIGR_GetOptions("i=s"     => \$infile);

if ($err == 0){
    $base->bail("Command line parsing failed.  See -h option");
}

if (! defined $infile){
    if ($#ARGV < 0){
	$base->bail("Must specify an input file name.  See -h option");
    } else {
	$infile = $ARGV[0];
    }
}

$base->logLocal("Opening input file $infile", 1);
open(IN, $infile) ||
    $base->bail("Cannot open $infile: $!");


my $record;
my %status;

my $utgseqs = 0;

while ($record = getCARecord(\*IN))
{
  my ($type, $fields, $recs) = parseCARecord($record);

  if ($type eq "CCO")
  {
    my $thiscontig = getCAId($$fields{"acc"});
    for (my $i = 0; $i <= $#$recs; $i++)
    {
      my ($ltype, $lfields, $lrecs) = parseCARecord($$recs[$i]);
      if ($ltype eq "UPS")
      {
        my $thisunitig = getCAId($$lfields{"lid"});

        if ($status{$thisunitig} eq "U" ||
            $status{$thisunitig} eq "N"){
            next;
        }

		my $pos = $$lfields{"pos"};
        my ($l, $r) = split(',', $pos);

        print "$thiscontig U $l $r SURROGATE $thisunitig $status{$thisunitig}\n"; 
      }
    }
  }
  elsif ($type eq "UTG")
  {
    my $thisunitig = getCAId($$fields{"acc"});
    $status{$thisunitig} = $$fields{"sta"};
    if ($$fields{"sta"} ne "U" &&
        $$fields{"sta"} ne "N"){
        $utgseqs += $$fields{"nfr"};
    }
  }
}
close(IN);
