#!/util/bin/perl -w
use strict;



##
# parse_vs_mouse
#
# Minimalistic parser for megablast output (to use when main=mouse).
# It saves all the subjects (ie mouse contigs) aligning at least to one
# query, if the e value is smaller than a threshold value, or if the 
# number of matches is close to the length of the subject (ie of the
# mouse contig).
#



# Constants.
my $threshold_e = 250;
my $ratio = 0.9;

# Parse arguments.
my $file_name = $ARGV[0];
open ( BLAST_OUT, $file_name );

# Legenda.
print "# mouse_cg_id   cg_length   subj   s_length   ",
  "prob   n_matches   align_length\n";

# Some variables.
my $expect = 0;
my $ident = 0;

my @splitted_line;
my $a_line;

my $query_name;
my $query_length;
my $subj_name;
my $subj_length;
my $blast_prob;
my $n_matches;
my $align_length;

# Main loop.
while ( $a_line = <BLAST_OUT> ) {  
  
  # Query name.
  if ( $a_line =~ "Query=" ) {
    if ( $a_line =~ /contig/ ) {
      @splitted_line = split /= / , $a_line;
      $query_name = $splitted_line[1];
      chomp $query_name;
    }
    else {
      @splitted_line = split /\|/ , $a_line;
      $query_name = $splitted_line[1];
    }
  }
  
  # Query length.
  if ( $a_line =~ /letters\)/ ) {
    @splitted_line = split " ", $a_line;
    $query_length = substr( $splitted_line[0], 1);
    $query_length =~ s/,//;
  }
  
  # Subject name.
  if ( $a_line =~ />/ ) {
    @splitted_line = split />|_/ , $a_line;
    $subj_name = $splitted_line[2] - 1;
    chomp $subj_name;
  }

  # Subject length.
  if ( $a_line =~ /Length = / ) {
    @splitted_line = split / = / , $a_line;
    $subj_length = $splitted_line[1];
    chomp $subj_length;
    $subj_length =~ s/,//;

    $expect = 0;
    $ident = 0;
  }
  
  # Probability.
  if ( $expect == 0 && $a_line =~ /Expect =/ ) {
    @splitted_line = split / = /, $a_line;
    $blast_prob = $splitted_line[2];
    chomp $blast_prob;
    $expect = 1;
  }

  # Nmuber of matches and length of alignment.
  if ( $ident == 0  && $a_line =~ /Identities =/ ) {
    @splitted_line = split / = | \(/, $a_line;
    my $match_length = $splitted_line[1];
    @splitted_line = split /\//, $match_length;
    
    $n_matches = $splitted_line[0];
    $align_length = $splitted_line[1];
    $n_matches =~ s/,//;
    $align_length =~ s/,//;

    $ident = 1;
    
    # Print if probability is small enough, or if number of matches is
    #  close to length of subj sequence (mouse contig).
    my @splitted_prob = split /e-/, $blast_prob;
    if ( $blast_prob eq "0.0"
	 || $splitted_prob[1] > $threshold_e
	 || $subj_length > $ratio * $n_matches ) {
      print
	$subj_name, "  ", $subj_length, "  ",
	$query_name, "  ", $query_length, "  ",
	$blast_prob, "  ", $n_matches, "  ", $align_length, "\n";
    }
  }
}
