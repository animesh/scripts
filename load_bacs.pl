#!/util/bin/perl -w
use strict;



##
#
# load_bacs
#
#
# To use:
#
#  perl load_bacs BAC_NAMES SAVE_DIR
#
# where BAC_NAMES is a file with the names of the BACs you want, and
# SAVE_DIR the name of the directory where the output will be sent to.
# An example of the BAC_NAMES file:
#  AC010833
#  AC013716
#  AC055866
#  AC092704
#
#
# What it does:
#
# It creates a fasta file for each of the BACs in the input file, and
# it "cat"s them together into a result file.
#
#



# Parse arguments
my $project_names = $ARGV[0];
my $save_dir = $ARGV[1];

# Project names.
my @all_projects;

open ( PROJECTS, $project_names );
while ( my $this_project = <PROJECTS> ) {
  chomp $this_project;
  push @all_projects, $this_project;
}

# Check if YANK_INDEX_PATH is properly set.
if ( !$ENV{YANK_INDEX_PATH} ||
     $ENV{YANK_INDEX_PATH} ne "/seq/blastdb/genbank/yank" ) {
  print "\n";
  print "YANK_INDEX_PATH is not properly set: ";
  print "I will temporarily set it to '/seq/blastdb/genbank/yank'.\n";
  $ENV{YANK_INDEX_PATH} = "/seq/blastdb/genbank/yank";
}

# Define yank and gb2fasta commands.
my $yank_command = "yank -i yank_index_gb -v -a ";
my $gb2fasta_command = "gb2fasta";

# Clean up old stuff, and create directory and temp files.
if ( opendir FASTA_DIR, $save_dir ) {
  system ( "rm -rf $save_dir" );
}
umask 0;
mkdir $save_dir, 0777;
my $temp_yank_file = $save_dir . "/yank_save";

# Create fasta files.
print "\n";
foreach my $one_project ( @all_projects ) {
  print "Creating fasta for $one_project.\n";

  my $fasta_out = $save_dir . "/" . $one_project;

  system ( $yank_command . " " . $one_project . " > " . $temp_yank_file );
  system ( $gb2fasta_command . " " . $temp_yank_file . " > " . $fasta_out );
}

# Cat fasta files.
unlink $temp_yank_file;

opendir FASTA_DIR, $save_dir;
my @all_fasta = readdir FASTA_DIR;
my $all_fasta = @all_fasta;
my $result_fasta = $save_dir . "/result.fasta";
print "\nStart to merge fasta files.\n";

foreach my $one_fasta ( @all_fasta ) {
  if ( $one_fasta ne "." && $one_fasta ne ".." ) {
    my $loc_fasta = $save_dir . "/" . $one_fasta;
    print "Add $loc_fasta.\n";
    system ( "cat $loc_fasta >> $result_fasta" );
  }
}

print "\nThere were a total of ", $all_fasta - 2, " valid fasta files.\n";

