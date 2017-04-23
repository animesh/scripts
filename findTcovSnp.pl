#!/usr/local/bin/perl -w

use strict;
use TIGR::Foundation;


my $USAGE = "Usage: findTcovSnp.pl prefix\n";

my $HELPTEXT = qq~
Generate a report on the slice level discrepanices present in a contig.

  $USAGE
  prefix is the prefix to the tcov file and idTbl (if -i)
  Note: getCoverage -t --gapped -R -a all <contigfile>

  Options
  -------
  -l      Prune low quality discrepancies from report (no qv > 30)

  -[no]q  Print Quality Values of each base   [ Default: -noq ]
  -[no]r  Print Read Ids of each base         [ Default: -r   ]
  -[no]i  Print count of each lib id          [ Default: -noi ]
  -[no]b  Print each base                     [ Default: -b   ]
  -[no]H  Print a header for the columns      [ Default: -h   ]
  -amb    Only print contig positions with an ambiguity code

  -minqv  Specify minimum cummulative qv of disagreeing reads
  -minsnp Specify minimum number of consistent disagreeing reads
  -qvs    Print Quality Values stats (max, avg) [ Default: -noqvs ]
~;

my $VERSION = "findTcovSnp Version 1.00 (Build " . (qw/$Revision: 1.2 $/ )[1] . ")";

my @DEPENDS = 
(
  "TIGR::Foundation",
);

my $tf = new TIGR::Foundation;

MAIN:
{
  $tf->addDependInfo(@DEPENDS);
  $tf->setHelpInfo($HELPTEXT);
  $tf->setVersionInfo($VERSION);

  ## Options
  my $prunelq = 0;
  my $doPrintQuals = 0;
  my $doPrintReads = 1;
  my $doPrintLibs = 0;
  my $doPrintBase = 1;
  my $doPrintHeader = 1;
  my $doAmbOnly = 0;
  my $minqv = 0;
  my $minsnp = 0;
  my $printqvstats = 0;

  my $LIBPREFIX = 4;
  my $HIGHQUALITY = 30;

  # now we handle the input options
  my $result = $tf->TIGR_GetOptions
               (
                 'l!'       => \$prunelq,
                 'q!'       => \$doPrintQuals,
                 'r!'       => \$doPrintReads,
                 'i!'       => \$doPrintLibs,
                 'b!'       => \$doPrintBase,
                 'H!'       => \$doPrintHeader,
                 'qvs!'     => \$printqvstats,
                 'amb!'     => \$doAmbOnly,
                 'minqv=s'  => \$minqv,
                 'minsnp=s' => \$minsnp,
               );

  $tf->bail("Command line parsing failed") if (!$result);

  my $prefix = shift @ARGV or die $USAGE;
  $prefix = $1 if ($prefix =~ /^([\w\.]+)\.\w+$/);

  my $snpcount = 0;
  my $lqsnpcount = 0;
  my %seqid;

  if ($doPrintLibs)
  {
    open IDTBL, "< $prefix.idTbl"
      or $tf->bail("Can't open $prefix.idTbl ($!)");

    while (<IDTBL>)
    {
      my ($id, $seqname, $rc) = split /\s+/, $_;

      $seqid{$id} = $seqname;
    }
    close IDTBL;
  }


  if ($doPrintHeader)
  {
    print "AsmblId\tGPos\tUPos\tConsensus\tdcov\tconflicts";

    print "\t(Base)"   if $doPrintBase;
    print "\t{Reads}"  if $doPrintReads;
    print "\t<Libs>"   if $doPrintLibs;
    print "\t[Quals]"  if $doPrintQuals;
    print "\tmax\tavg" if $printqvstats;

    print "\n";
  }

  open TCOV, "< $prefix.tcov"
    or $tf->bail("Can't open $prefix.tcov ($!)");

  OUTER:
  while (<TCOV>)
  {
    my ($asmbl_id, $g, $u, $c, $cqv, $bases, $quals, $reads) = split /\s+/, $_;
    next if !defined $reads; ## Skip 0 coverage regions

    my @bases = split //, uc($bases);

    my $foundsnp = grep { $_ ne $bases[0] } @bases;
    next OUTER if !$foundsnp;  ## Skip homogeneous slices
    next OUTER if ($doAmbOnly && ($c eq "A" || $c eq "C" || $c eq "G" || $c eq "T" || $c eq "-"));

    $snpcount++;
    
    my $dcov = length $bases;

    my @quals = split /:/, $quals;
    my @reads = split /:/, $reads;

    my %qvsum = ();
    my %count = ();
    my %quals = ();
    my %reads = ();
    my %libid = ();

    my $i = 0;
    foreach my $b (@bases)
    {
      $count{$b}++;
      $qvsum{$b} += $quals[$i];

      push @{$quals{$b}}, $quals[$i];
      push @{$reads{$b}}, $reads[$i];

      $libid{$b}->{substr($seqid{$reads[$i]}, 0, $LIBPREFIX)}++ 
        if $doPrintLibs;

      $i++;
    }

    my $num = scalar keys %count;
    my @order = sort {$count{$b} <=> $count{$a} ||
                      $qvsum{$b} <=> $qvsum{$a}} keys %count;

    my $cons = $order[0]; ## Grab the majority element

    if ($prunelq || $minqv || $minsnp)
    {
      ## Test for presense of hq snp
      my $foundhq  = 0;
      my $foundqv  = 0;
      my $foundsnp = 0;

      FINDHQ:
      foreach my $e (@order[1..$#order]) ## Skip the majority element
      {
        my @quals = @{$quals{$e}};

        if ($count{$e} >= $minsnp)
        {
          $foundsnp = 1;
        }

        my $cqv = 0;

        foreach my $q (@quals)
        {
          $cqv += $q;
          if ($q >= $HIGHQUALITY)
          {
            $foundhq = 1;
          }
        }

        if ($cqv >= $minqv)
        {
          $foundqv = 1;
        }
      }

      if (($prunelq && !$foundhq) ||
          ($minqv   && !$foundqv) ||
          ($minsnp  && !$foundsnp))
      {
        ## Skip strictly low quality snps
        $lqsnpcount++;
        next OUTER;
      }
    }

    my $conflicts = $dcov - $count{$order[0]};

    print "$asmbl_id\t$g\t$u\t$c\t$dcov\t$conflicts";


    foreach my $b (@order)
    {
      print "\t$b($count{$b})" 
        if $doPrintBase;

      print "\t{", join(":", @{$reads{$b}}), "}" 
        if $doPrintReads;

      print "\t<", join(",", map {"$_:".$libid{$b}->{$_} } sort keys %{$libid{$b}}), ">" 
        if $doPrintLibs;

      print "\t[", join(":", @{$quals{$b}}), "]" 
        if $doPrintQuals;

      if ($printqvstats)
      {
        my $s = 0;
        my $c = 0;
        my $m = 0;
        foreach my $q (@{$quals{$b}})
        {
          if ($q > $m) { $m = $q; }
          $s += $q;
          $c++;
        }
        my $avg = sprintf("%0.1f", $s/$c);
        print "\t$m\t$avg";
      }





    }
    print "\n";
  }

  if ($prunelq)
  {
    print STDERR "$lqsnpcount low quality snps pruned\n";
  }

  print STDERR "$snpcount total snps processed\n";
}
