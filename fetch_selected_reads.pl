#!/util/bin/perl

use Getopt::Std;

$usage = <<EOF;
Usage: $0 -[f|l] list_of_reads_to_fetch fasta_file [fasta_file ...]

Options:
-f Use first word of '>' lines as the read name.
-l Use last word of '>' lines as the read name.
EOF

getopts('fl');

if ( $opt_f and $opt_l ) {
  die "Use only one of -f and -l.\n";
}

if ( ! $opt_f and ! $opt_l ) {
  die "Specify one of -f or -l.\n";
}

$use_first_word = $opt_f;

$file_of_reads_to_fetch  = shift @ARGV;

# Define a hash containing entries only for the read names in which we
# are interested.  The content of these entries is unimportant; their
# existence is all we will check for.
open( SELECTED_READS, "<$file_of_reads_to_fetch" ) || die "$!";
while ( <SELECTED_READS> ) {
  chomp;
  $reads{$_} = '';
  ++$num_reads;
}
close SELECTED_READS;

print STDERR "Looking for $num_reads reads.\n";

# Go through each fasta/qual file
foreach $fasta_file ( @ARGV ) {
  print STDERR "Reading $fasta_file.\n";

  if ( $fasta_file =~ /.gz$/ ) {
    open( FASTA, "zcat $fasta_file |" );
  } else {
    open( FASTA, "<$fasta_file" );
  }

  $is_selected = 0;
  while ( <FASTA> ) {

    # If the line contains a read name...
    if ( /^>/ ) {

      # Get read name
      if ( $use_first_word ) {
	( $name ) = ( /^>\s*(\S+)/ );
      } else {
	( $name ) = ( /([^\s>]+)\s*$/ );
      }

      # If the read name exists in our hash of reads to fetch, set the
      # flag to print; otherwise, unset the flag so we don't print it.
      if ( exists( $reads{$name} ) ) {
	$is_selected = 1;
      } else {
	$is_selected = 0;
      }
    } 
    
    print if ( $is_selected );
  }
}

exit 0;
