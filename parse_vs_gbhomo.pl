#!/util/bin/perl -w
use strict;



##
# parse_vs_gbhomo
#
# Minimalistic parser for megablast output (to use when main=gbhomosapiens,
# secondary=mouse). It saves all the queries (ie mouse contigs) aligning at
# least to one subject, if the e value is smaller than a threshold value, or
# if the number of matches is close to the length of the query (ie of the
# mouse contig).
#



# Constants.
my $threshold_e = 250;
my $ratio = 0.9;

# Parse arguments.
my $file_name = $ARGV[0];
open ( BLAST_OUT, $file_name );

# Legenda.
print "# query   q_length   subj   s_length   ",
  "prob   n_matches   align_length\n";

# Some variables.
my $letters = 0;
my $bigsign = 0;
my $qlength = 0;
my $expect = 0;
my $ident = 0;

my @hit;
my @splitted_line;
my $a_line;

# Main loop.
while ( $a_line = <BLAST_OUT> ) {  

  # Query name.
  if ( ( substr $a_line, 0, 6 ) eq "Query=" ) {  
    @splitted_line = split "_", $a_line;

    $hit[0] = $splitted_line[1] - 1;

    $letters = 0;
    $bigsign = 0;
    $qlength = 0;
    $expect = 0;
    $ident = 0;
  }

  # Query length.
  if ( $letters == 0  && $a_line =~ /letters\)/ ) {
    @splitted_line = split " ", $a_line;
    $hit[1] = substr( $splitted_line[0], 1);
    $hit[1] =~ s/,//;
    $letters = 1;
  }

  # Subject name.
  if ( $bigsign == 0  && ( substr $a_line, 0, 1 ) eq ">" ) {
    @splitted_line = split /\|/ , $a_line;
    $hit[2] = $splitted_line[1];
    $bigsign = 1;
  }

  # Subject length.
  if ( $qlength == 0 && $a_line =~ "Length = " ) {
    @splitted_line = split / = /, $a_line;
    $hit[3] = $splitted_line[1];
    chomp $hit[3];
    $hit[1] =~ s/,//;
    $qlength = 1;
  }
  
  # Probability.
  if ( $expect == 0 && $a_line =~ " Expect = " ) {
    @splitted_line = split / = /, $a_line;
    $hit[4] = $splitted_line[2];
    chomp $hit[4];
    $expect = 1;
  }
  
  # Nmuber of matches and length of alignment.
  if ( $ident == 0  && $a_line =~ " Identities = " ) {
    @splitted_line = split / = | \(/, $a_line;
    my $match_length = $splitted_line[1];
    @splitted_line = split /\//, $match_length;

    $hit[5] = $splitted_line[0];
    $hit[6] = $splitted_line[1];
    $hit[5] =~ s/,//;
    $hit[6] =~ s/,//;
    $ident = 1;
    
    # Print if probability is small enough, or if number of matches is
    #  close to length of query sequence (contig).
    my @splitted_prob = split /e-/, $hit[4];
    if ( $hit[4] eq "0.0"
	 || $splitted_prob[1] > $threshold_e
	 || $hit[5] > $ratio * $hit[1] ) {
      foreach my $loc ( @hit ) {
	print $loc, "\t";      
      }
      print "\n";
    }
  }

}
