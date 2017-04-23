#!/usr/bin/perl -w
use strict;

use AMOS::AmosFoundation;
use File::Basename;

my $TRIMWIGGLE = 10;
my $CIRCLEWIGGLE = 0;
my $MINLENGTH = 0;
my $FLAGDIST = undef;
my $FLAGSAME = undef;
my $DOAMOS = 0;
my $BREAKONLY = 0;
my $COLLAPSEONLY = 0;
my $CHECKFIX = 0;

my $HELPTEXT = qq~
Find alignment breaks in query sequences.

Note: You should probably run 'delta-filter -q out.delta > out.delta.q'
      and then check the out.delta.q file.

  find-query-breaks.pl [options] deltafile

  -b <val> Minimum length of alignment break to report (Default: 10)
  -w <val> Minimum distance to edge of reference sequence to report (Default: 0)
  -l <val> Minimum length of query sequence to report (Default: 0)
  -f <val> Flag broken alignments within this distance of reference
  -s       Flag adjacent broken alignments from same query
  -C       Only show collapses

  -B       Only show alignment breaks
  -c       Load fix regions from all.feat and mark if fixed in -B breakreport

  -a       Display breaks as AMOS features
~;


sub printAlignment
{
  my $align = shift;
  my $rc = ($align->{qrc}) ? "[rc]" : "[]";
  print "$align->{rid} {1 [$align->{rstart},$align->{rend}] $align->{rlen}} | $align->{qid} {1 [$align->{qstart},$align->{qend}] $align->{qlen}} $rc";
}

sub hasFix
{
  my $fixes = shift;
  my $qid = shift;
  my $pos = shift;

  my $FIXWINDOW = 5000;

  if (exists $fixes->{$qid})
  {
    foreach my $f (@{$fixes->{$qid}})
    {
      if (($f->{start} - $FIXWINDOW < $pos) &&
          ($f->{end}   + $FIXWINDOW > $pos))
      {
        return 1;
      }
    }
  }
  
  return 0;
}

my $base = new AMOS::AmosFoundation;
$base->setHelpText($HELPTEXT);
$base->setUsage("find-query-breaks.pl [options] deltafile");


my $err = $base->getOptions("b=i" => \$TRIMWIGGLE,
                            "w=i" => \$CIRCLEWIGGLE,
                            "l=i" => \$MINLENGTH,
                            "f=i" => \$FLAGDIST,
                            "s"   => \$FLAGSAME,
                            "C"   => \$COLLAPSEONLY,
                            "B"   => \$BREAKONLY,
                            "a"   => \$DOAMOS,
                            "c"   => \$CHECKFIX);

if (!$err) { $base->bail("Command line parsing failed. See -h option"); }

if (scalar @ARGV == 0)
{
  print "Usage: ".$base->getUsage()."\n";
  exit(0);
}

my $multidelta = (scalar @ARGV) > 1;

foreach my $deltafile (@ARGV)
{
  print ">$deltafile\n" if $multidelta;

  my %fixes;
  if ($CHECKFIX)
  {
    my $fixname = dirname(File::Spec->rel2abs($deltafile)) . "/all.feat";

    open FIXES, "< $fixname" or die "Can't open $fixname ($!)\n";
    while (<FIXES>)
    {
      my @vals = split /\s+/, $_;
      if ($vals[1] eq "F")
      {
        my $fix;
        $fix->{start} = $vals[2];
        $fix->{end}   = $vals[3];

        if ($fix->{start} > $fix->{end})
        {
          $fix->{start} = $vals[3];
          $fix->{end}   = $vals[2];
        }

        push @{$fixes{$vals[0]}}, $fix;
      }
    }
  }

  my $cmd = "show-coords -Hcrl $deltafile";
  open COORDS, "$cmd |" or die "Can't run $cmd ($!)\n";

  my $lastalign = undef;

  while (<COORDS>)
  {
    #print $_;

    my @vals = split /\s+/, $_;

    my $align;
    $align->{rstart} = $vals[1];
    $align->{rend}   = $vals[2];

    $align->{qstart} = $vals[4];
    $align->{qend}   = $vals[5];

    $align->{ralen}  = $vals[7];
    $align->{qalen}  = $vals[8];

    $align->{pid}    = $vals[10];

    $align->{rlen}   = $vals[12];
    $align->{qlen}   = $vals[13];

    $align->{rid}    = $vals[18];
    $align->{qid}    = $vals[19];

    $align->{qrc}    = ($align->{qend} < $align->{qstart}) ? 1 : 0;

    if ($align->{qrc})
    {
      my $t = $align->{qstart};
      $align->{qstart} = $align->{qend};
      $align->{qend} = $t;
    }

    next if ($align->{qlen} < $MINLENGTH);


    my $flag = " ";
    if ((defined $FLAGDIST) &&
        (defined $lastalign) &&
        ($lastalign->{rid} eq $align->{rid}) &&
        ($align->{rstart} - $lastalign->{rend} < $FLAGDIST))
    {
      $flag = "*";
    }

    if ((defined $lastalign) &&
        ((defined $FLAGSAME) || $COLLAPSEONLY) &&
        ($lastalign->{rid} eq $align->{rid}) &&
        ($lastalign->{qid} eq $align->{qid})) 
    {
      $flag = "*";

      if ($COLLAPSEONLY && 
         ($align->{qrc} == $lastalign->{qrc}))
      {
        my $rdist = $align->{rstart} - $lastalign->{rend};


        my $s;
        my $e;

        if ($align->{qrc})
        {
          $s = $align->{qend};
          $e = $lastalign->{qstart};
        }
        else
        {
          $s = $lastalign->{qend};
          $e = $align->{qstart};
        }

        my $qdist = $e - $s;
        my $delta = $qdist - $rdist;

        if ($DOAMOS)
        {
          print "$align->{qid}\tL\t$s\t$e\tCOLLAPSE $delta\n";
        }
        else
        {
          print ">$align->{rid}\t$align->{qid}\t";
          print "[$lastalign->{rend},$align->{rstart}]\t$rdist\t";
          print "[$s,$e]\t$qdist\t";
          print "|\t$delta\n";

          printAlignment($lastalign); print "\n";
          printAlignment($align);     print "\n";

          print "\n";
        }
      }
    }
        

    my $breakcount = 0;


    if (( $align->{qrc} && ($align->{rlen} - $align->{rend} <= $CIRCLEWIGGLE)) ||
        (!$align->{qrc} && ($align->{rstart} - 1            <= $CIRCLEWIGGLE)))

    {

    }
    elsif (($align->{qstart} - 1) > $TRIMWIGGLE)
    {
      my $dist = $align->{qstart} - 1;
      my $len = $align->{qend} - $align->{qstart};
      $breakcount++;

      if (!$COLLAPSEONLY)
      {
        if ($BREAKONLY)
        {
          my $fixed = hasFix(\%fixes, $align->{qid}, $align->{qstart});
          print "$align->{rid} start $align->{rstart} $fixed $align->{qid} $align->{qstart}\n";
        }
        elsif ($DOAMOS)
        {
          my $s = $align->{qstart};
          my $e = $s+1;
          
          print "$align->{qid}\tB\t$e\t$s\tSTART_BREAK: $dist ($len)\n";
        }
        else
        {

          print "S-Break: $dist\tAlen: $len $flag\t";
          printAlignment($align);
          print "\n";
        }
      }
    }

    if ((!$align->{qrc} && ($align->{rlen} - $align->{rend} <= $CIRCLEWIGGLE)) ||
        ( $align->{qrc} && ($align->{rstart} - 1            <= $CIRCLEWIGGLE)))

    {

    }
    elsif (($align->{qlen} - $align->{qend}) > $TRIMWIGGLE)
    {
      my $dist = $align->{qlen} - $align->{qend};
      my $len = $align->{qend} - $align->{qstart};
      $breakcount++;

      if (!$COLLAPSEONLY)
      {
        if ($BREAKONLY)
        {
          my $fixed = hasFix(\%fixes, $align->{qid}, $align->{qend});
          print "$align->{rid} end $align->{rend} $fixed $align->{qid} $align->{qend}\n";
        }
        elsif ($DOAMOS)
        {
          my $s = $align->{qend};
          my $e = $s+1;
          
          print "$align->{qid}\tB\t$s\t$e\tEND_BREAK: $dist ($len)\n";
        }
        else
        {
          print "E-Break: $dist\tAlen: $len $flag\t";
          printAlignment($align);
          print "\n";
        }
      }
    }

    if ($breakcount)
    {
      $lastalign = $align;
    }

    #print $_ if $breakcount;
  }
}
