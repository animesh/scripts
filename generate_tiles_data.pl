#! /util/bin/perl

# Useage: generate_tiles_data.pl
#

if ($#ARGV != 1)
{
    print "Useage: $0  wanted.i  tiles_data.i\n";
    print "   for each  wanted.i  file, writes to the file  tiles_data.i\n";
    print "   a list of contig coordinates for the reads that appear in  wanted.i\n";
    exit(0);
}

$wanted_file = $ARGV[0];
$out_file = $ARGV[1];

$now_time = localtime;
print "$now_time: Doing $wanted_file --> $out_file ...\n";

@reads = ();

open(WANTED_FILE, $wanted_file) || die "Can't open $wanted_file\n";
@reads = <WANTED_FILE>;
close(WANTED_FILE);

open(OUT_FILE, "> $out_file") || die "Can't open $out_file for output\n";
foreach (@reads)
{
    /QUERY\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/;

    $first_index = $1;
#	$first_start = $2;
#	$first_end = $3;
#	$first_length = $4;
#	$first_rc = $5;
    $first_start_coord = $7;
    $first_end_coord = $8;

    for ($i = $first_start_coord;
	 $i < $first_end_coord;
	 $i += 10)
    {
	$outstring = sprintf "%8u\t%8u\n", ($i,$first_index);
	print OUT_FILE $outstring;
    }
} # outer loop

close(OUT_FILE);

$now_time = localtime;
print "$now_time: Doing $wanted_file --> $out_file ...done.\n";
