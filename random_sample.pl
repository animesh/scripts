#! /util/bin/perl

if ($#ARGV != 2)
{
    print "Useage: $0  input_file  output_file  sample_size\n";
    print "    Randomly selects  sample_size  many lines from  input_file,\n";
    print "    and writes the selected lines to  output_file\n";
    exit(0);
}

$input_file = $ARGV[0];
$output_file = $ARGV[1];
$sample_size = $ARGV[2];

######

$now_time = localtime;
print "$now_time: Reading $input_file...\n";

@input_lines = ();

open(INPUT_FILE, $input_file) || die "Can't open $input_file\n";
@input_lines = <INPUT_FILE>;
close(INPUT_FILE);

$num_input_lines = scalar(@input_lines);

$now_time = localtime;
print "$now_time: Reading $input_file...done.\n";

print "$num_input_lines many lines found in $input_file\n";

######

$now_time = localtime;
print "$now_time: Generating $sample_size lines to $output_file...\n";

%found_indices = ();
$num_output_lines = 0;

open(OUTPUT_FILE, "> $output_file") || die "Can't open $output_file for output\n";
while ($num_output_lines < $sample_size)
{
    $index = rand $num_input_lines;

    next if (exists($found_indices{$index}));

    $found_indices{$index} = $index;

    print OUTPUT_FILE $input_lines[$index];
    $num_output_lines++;
}
close(OUTPUT_FILE);

$now_time = localtime;
print "$now_time: Generating $sample_size lines to $output_file...done.\n";


