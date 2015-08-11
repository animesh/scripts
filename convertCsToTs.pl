#!/usr/bin/perl -w

use strict;
use Getopt::Long;


sub usage {
  print "\n Usage: convertCsToTs.pl --in=fname [--out=fhead]\n\n",
        "    For each sequence found in the input fasta file, converts \n",
        "    all C bases to T in this sequence and in its reverse complement \n",
        "    and writes forward converted sequences and reverse complement \n",
        "    converted sequences in two separate output fasta files.\n\n",
        "    --in input file name, required argument. \n",
        "    --out output file name base, optional. If not specified the output \n",
        "      file name base is derived from input filename: if input filename \n",
        "      ends with .fasta, then part of the input name before .fasta will \n",
        "      be used as a base, otherwise the whole input file name will be   \n",
        "      used as a base. Output file names are formed as \n",
        "      <output_base>.fw.CtoT.fasta and <output_base>.rc.CtoT.fasta\n\n";
}


my $fasta_in = "";
my $fasta_out_base = "";

GetOptions('in=s'=> \$fasta_in,
           'out:s'=> \$fasta_out_base) || die("Unrecognized command line arguments");


if ( ! defined $fasta_in || $fasta_in eq "" ) {
  print "ERROR: input fasta file name must be specified. \n";
  usage();
  exit(1);
}


if ( ! defined $fasta_out_base || $fasta_out_base eq "" ) {
  $fasta_out_base = $fasta_in;
  $fasta_out_base =~ s/\.fasta$//;
}

open ( INPUT, " < $fasta_in" );
open ( FW_OUT, " > $fasta_out_base.fw.CtoT.fasta" );
open ( RC_OUT, " > $fasta_out_base.rc.CtoT.fasta" );

my $sequence ="";
my $linewidth = 80;

LINE: while ( <INPUT> ) {
  chomp;

  if ( /^>/ ) {
    if ( $sequence ne "" ) {
      my $revseq = scalar reverse $sequence; # reverse,
      $revseq =~ tr/ACGTacgt/TGTAtgta/; # complement and Bisulfite-convert
      $sequence =~ tr/Cc/Tt/;

      # multiline format:
      $revseq =~ s/\S{$linewidth}/$&\n/sg;
      $sequence =~ s/\S{$linewidth}/$&\n/sg;
      print FW_OUT $sequence,"\n";
      print RC_OUT $revseq,"\n";
      $sequence = "";
    }
    print FW_OUT $_, " [C-->T]\n";
    print RC_OUT $_ , " [rc] [C-->T]\n";
    next LINE;
  }
  if ( /^\s*$/ ) {
    next LINE;
  }
  if ( ! /^[NACTGnactg]+$/ ) {
    print $_, "\n";
    die("Illegal string found in input fasta file");
  }
  $sequence = $sequence.$_;
}

if ( $sequence ne "" ) {
  my $revseq = scalar reverse $sequence; # reverse,
  $revseq =~ tr/ACGTacgt/TGTAtgta/; # complement and Bisulfite-convert
  $sequence =~ tr/Cc/Tt/;
  
  # multiline format:
  $revseq =~ s/\S{$linewidth}/$&\n/sg;
  $sequence =~ s/\S{$linewidth}/$&\n/sg;
  print FW_OUT $sequence,"\n";
  print RC_OUT $revseq,"\n";
}

close INPUT;
close FW_OUT;
close RC_OUT;




  
    
    
