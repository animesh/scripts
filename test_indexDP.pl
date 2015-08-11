#!/usr/bin/perl

# Test designed to be run via make check
# Should return 0 for success, non-zero for failure and 
# the special value of 77 for 'ignore me'.
# 
# check executables are run without arguments, but values can be added via
# TESTS_ENVIRONMENT automake variable
#

use Test::More;

# Check free memory
if ( system("free -V") == 0 ) {
    my $mem = `free -mt | grep '^Mem'`;
    my @fields = split '\s+', $mem;
    if ( $fields[3] < 4000 ) {
	plan skip_all => "indexDP tests.  $fields[3]Mb is insufficient free memory to run the indexDP check\n";
    }
    else {
	plan tests => 3;
    }
}
else {
    print STDERR "Can't determine free memory\n";
    exit(77);
}

my $reads = $ENV{IDP_READS_FILE};

my $references = $ENV{IDP_REFERENCES_FILE};

my $seedSize = "20";
my $numErr = "1";
my $weight = "16";
my $repository = $ENV{IDP_REPOSITORY}; 
my $outPrefix = $ENV{IDP_OUT_PREFIX};
my $paf_out_prefix = "M13_bin";         # $ENV{PAF_OUT_PREFIX}
my $paf_input_file = "M13_bin_indexDP_binary.bin";
my $output_file = $ENV{IDP_OUTPUT_FILE};
my $config = $ENV{IDP_CONFIG};
my $benchmark = $ENV{IDP_BENCHMARK};
my $paf_benchmark = "testing/etc/M13_bin_indexDP_verbose.txt";  # $ENV{PAF_BENCHMARK}
my $paf_output_file = "M13_bin_verbose.txt";
my $hpdp_scores_file = $ENV{HPDP_SCORES_FILE};
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};
#"/gpfs2/bioinf/config/HPDP/hpdp_GL_noHP_config";

#Copy hpdp scores locally
system("cp -f $hpdp_scores_file .") && die "Unable to copy hpdp scores file $hpdp_scores_file\n";
my $result = 1;
# Test execution
is(system("./indexDP --template_repository $repository --weight $weight --reads_file $reads --reference_file $references --seed_size $seedSize --num_errors $numErr --out_prefix  $outPrefix --config_file $config --percent_error 25 $io_redirect"),0,'indexDP execution')
    or $result = 0;

# Test comparison to benchmark
#$output_file = $outPrefix . '_indexDP_verbose.txt';
is(`diff $output_file $benchmark`,'','indexDP match to benchmark')
    or $result = 0;

# Generate binary output and test printAlignmentFile
system("./indexDP --template_repository $repository --weight $weight --reads_file $reads --reference_file $references --seed_size $seedSize --num_errors $numErr --out_prefix  $paf_out_prefix --config_file $config --percent_error 25 --binary $io_redirect");

system("./printAlignmentFile --input_file $paf_input_file --output_file_prefix $paf_out_prefix --verbose");
is(`diff $paf_output_file $paf_benchmark`,'','printAlignmentFile match to benchmark')
    or $result = 0;
