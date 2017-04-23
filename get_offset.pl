#! /util/bin/perl

if ($#ARGV != 2)
{
    print "Useage: $0  wanted_file  zaligns_file  output_file\n";
    print "   reads in the  zaigns_file , computes the offset of\n";
    print "   the alignments there from the  wanted_file , and writes\n";
    print "   to  output_file.\n";
    exit(0);
}

$wanted_file = $ARGV[0];
$zaligns_file = $ARGV[1];
$out_file = $ARGV[2];

$now_time = localtime;
print "$now_time: Reading $wanted_file...\n";

%start_coords = ();
%rc_status = ();

open(WANTED_FILE, $wanted_file) || die "Can't open $wanted_file\n";

while(<WANTED_FILE>)
{
    /QUERY\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/;

    $first_index = $1;
    # $first_start = $2;
    # $first_end = $3;
    # $first_length = $4;
    $first_rc = $5;
    $first_start_coord = $7;
    # $first_end_coord = $8;

    $start_coords{$first_index} = $first_start_coord;
    $rc_status{$first_index} = $first_rc;
}
close(WANTED_FILE);

$now_time = localtime;
print "$now_time: Reading $wanted_file...done.\n";

##########

$now_time = localtime;
print "$now_time: Doing $zaligns_file --> $out_file...\n";

open(ZALIGNS_FILE, "$zaligns_file") || die "Can't open $zaligns_file\n";
open(OUT_FILE, "> $out_file") || die "Can't open $out_file for output\n";

while(<ZALIGNS_FILE>)
{
    /\s*(\d+)\s+(\d+)/;

    $id1 = $1;
    $id2 = $2;

    if ( !exists($start_coords{$id1}) ||
	 !exists($start_coords{$id2}) ||
	 !exists($rc_status{$id1}) ||
	 !exists($rc_status{$id2}) )
    {
	print "Unable to compute offset of alignment $id1 with $id2.\n";
    }
    else
    {
	$start1 = $start_coords{$id1};
	$start2 = $start_coords{$id2};
	$rc1 = $rc_status{$id1};
	$rc2 = $rc_status{$id2};
	
	$offset = $start2 - $start1;

	$outstring = sprintf "%8u %1u %1u\n", ($offset, $rc1, $rc2);
	print OUT_FILE $outstring;
    }
}
close(OUT_FILE);
close(ZALIGNS_FILE);

$now_time = localtime;
print "$now_time: Doing $zaligns_file --> $out_file...done.\n";

