#!/usr/bin/perl -w
use strict;
use TIGR::Foundation;
use FileHandle;

my $USAGE = "Usage: filter_seq good.{seq,qual,contig} copy.{seq,qual}\n";

my $HELPTEXT = qq~
Extract specified fasta records from a master file. If available, use
the index file copy.suffix.idx to allow random access. Create the index file
by running 'filter_seq copy.suffix -index'.

  $USAGE

  Options
  -------
  -index Create an index file of the copy file
~;

my $VERSION = " Version 1.00 (Build " . (qw/$Revision: 1.1 $/ )[1] . ")";

my @DEPENDS = 
(
  "TIGR::Foundation",
);

my $createindex = 0;

my $tf = new TIGR::Foundation;
$tf->addDependInfo(@DEPENDS);
$tf->setHelpInfo($HELPTEXT);
$tf->setVersionInfo($VERSION);
my $result = $tf->TIGR_GetOptions('index', \$createindex);
$tf->bail("Command line parsing failed") if (!$result);

my $good = shift @ARGV || die $USAGE;

if ($createindex)
{
  my $orig = new FileHandle "$good", "<"
    or $tf->bail("Can't open $good ($!)");

  open IDX, "> $good.idx"
    or $tf->bail("Can't open $good.idx ($!)");

  while (!$orig->eof())
  {
    my $pos = $orig->tell();
    my $line = $orig->getline();

    if ($line =~ /^\>(\S+)/)
    {
      print IDX "$1 $pos\n";
    }
  }

  close IDX;
}
else
{
  my $copy = shift @ARGV || die $USAGE;

  my %sequencelist;

  ## Find the seqnames from the good list
  open GOOD, "< $good" 
    or $tf->bail("Could't open $good ($!)");

  while (<GOOD>)
  {
    if (/^\#(\S+)\(/ || /^\>(\S+)/)
    {
      $sequencelist{$1} = 1;
    }
  }
  close GOOD;

  if (-r "$copy.idx")
  {
    ## Create the index as: grep -b '>' tvg2.qual | tr -d ':' | tr  '>' ' ' | awk '{print $2" "$1}' > tvg2.qual.idx
    my %offsettable;

    open IDX, "< $copy.idx" 
      or $tf->bail("Couldnt open $copy.idx ($!)");

    while (<IDX>)
    {
      my @val = split / /, $_;

      $offsettable{$val[0]} = $val[1]
        if (exists $sequencelist{$val[0]});
    }
    close IDX;


    my $copy = new FileHandle "$copy", "r" 
      or $tf->bail("Couldnt open $copy ($!)");

    foreach my $seqname (keys %sequencelist)
    {
      if (exists $offsettable{$seqname})
      {
        $sequencelist{$seqname} = 0;

        $copy->seek($offsettable{$seqname}, 0);

        ## Print the headerline for sure
        my $line = $copy->getline();
        print $line;

        ## loop until next record
        $line = $copy->getline();
        while ($line !~ /^>/)
        {
          print $line;
          last if $copy->eof();
          $line = $copy->getline();
        } 
      }
    }
  }
  else
  {
    ## Pull the sequences out of the copy file
    my $printid = 0;

    open COPY, "< $copy" 
      or $tf->bail("Couldnt open $copy ($!)");

    while (<COPY>)
    {
      if (/^\>(\S+)/)
      {
        $printid = $sequencelist{$1};
        $sequencelist{$1} = 0;
      }

      print $_ if $printid;
    }

    close COPY;
  }

  ## Make sure we found each id
  foreach my $seqname (keys %sequencelist)
  {
    $tf->logError("$seqname in $good but not in $copy")
      if ($sequencelist{$seqname});
  }
}
