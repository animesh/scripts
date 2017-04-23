#! /util/bin/perl

if ($#ARGV != 2)
{
    print "Useage: $0  num_samples  contigs_size_file  output_file\n";
    print "  Randomly generate  num_samples  many locations in the\n";
    print "  contigs whose sizes are given in the  contigs_size_file\n";
    print "  (that being the output of FastbSizes with SHOW_INDEX=True)\n";
    print "  and write these locations to the  output_file.\n";
    exit(0);
}

$num_samples = $ARGV[0];
$contigs_size_file = $ARGV[1];
$output_file = $ARGV[2];

######

$now_time = localtime;
print "$now_time: Reading $contigs_size_file...\n";

$num_contigs = 0;
$total_length = 0;
@contigs_sizes = ();

open(CONTIGS_SIZE_FILE, $contigs_size_file) || die "Can't open $contigs_size_file\n";
while (<CONTIGS_SIZE_FILE>)
{
    /^\s*(\d+)\s+(\d+)/;
    # $idx = $1;
    $length = $2;

    push @contigs_sizes, $length;

    $total_length += $length;
    $num_contigs++;
}
close(CONTIGS_SIZE_FILE);

$now_time = localtime;
print "$now_time: Reading $contigs_size_file...done.\n";

print "$num_contigs many contigs\n";
print "$total_length many bases\n";


if ($num_contigs == 0)
{
    die "No entry found in $contigs_size_file\n";
}

######

$now_time = localtime;
print "$now_time: Generating $num_samples random locations...\n";

@temp = ();

for ($i = 0; $i < $num_samples; $i++)
{
    $val = int($total_length * rand);
    push @temp, $val;
}

@locations = sort {$a <=> $b} @temp;

for ($i = 0; $i < $num_samples; $i++)
{
    $loc = $locations[$i];
}

$now_time = localtime;
print "$now_time: Generating $num_samples random locations...done.\n";

######

$now_time = localtime;
print "$now_time: Writing to $output_file...\n";

open(OUTPUT_FILE, "> $output_file") || die "Can't open $output_file for output\n";

$curr_contig = 0;
$contig_covered_length = 0;

for ($i = 0; $i < $num_samples; $i++)
{
    $offset = $locations[$i] - $contig_covered_length;

    while ($offset >= $contigs_sizes[$curr_contig])
    {
	# location falls outside the current contig,
	# so move to the next contig and try again

	$contig_covered_length += $contigs_sizes[$curr_contig];
	$curr_contig++;
	$offset = $locations[$i] - $contig_covered_length;
    }

    $outstring = sprintf "%7u %9u\n", ($curr_contig, $offset);
    print OUTPUT_FILE $outstring;
}

close(OUTPUT_FILE);

$now_time = localtime;
print "$now_time: Writing to $output_file...done.\n";

