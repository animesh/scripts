#! /util/bin/perl

# Useage: find_aligns.pl unique_file
#


if ($#ARGV < 0)
{
    print "Useage: $0  wanted.1  [wanted.2 ...]\n";
    print "   for each  wanted.i  file, writes to the file  zaligns.i  all the detected\n";
    print "   alignments between the entries in  wanted.i\n";
    print "(NB: this should be run only after running  remove_discarded.pl)\n";
    exit(0);
}

@wanted_files = @ARGV;

while (@wanted_files > 0)
{
    $wanted_file = shift(@wanted_files);
    $wanted_file =~ /.+\.(\d+)/;
    $out_file = "zaligns.$1";

    print "Doing $wanted_file --> $out_file ...";

    @reads = ();

    open(WANTED_FILE, $wanted_file) || die "Can't open $wanted_file\n";
    @reads = <WANTED_FILE>;
    close(WANTED_FILE);

    open(OUT_FILE, "> $out_file") || die "Can't open $out_file for output\n";
    foreach (@reads)
    {
	/QUERY\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/;

	$first_index = $1;
	$first_start = $2;
	$first_end = $3;
	$first_length = $4;
	$first_rc = $5;
	$first_start_coord = $7;
	$first_end_coord = $8;

	foreach (@reads)
	{
	    /QUERY\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/;
	    
	    $second_index = $1;
	    $second_start = $2;
	    $second_end = $3;
	    $second_length = $4;
	    $second_rc = $5;
	    $second_start_coord = $7;
	    $second_end_coord = $8;

	    next if ($first_index == $second_index);

	    if ($first_start_coord <= $second_start_coord &&
		$second_start_coord <= $first_end_coord)
	    {
		# first read overlaps with second read
		# with a hanging head on the first read

		# the case when the hanging head occurs on the second read 
		# will be checked when the roles of the first and second reads
		# are reversed

		# also, skip this case if both reads start at the same point
		# but the first read ends earlier

		next if ($first_start_coord == $second_start_coord &&
			 $first_end_coord < $second_end_coord);

		# now everything is kosher: we have an alignment of reads!
		# so let's output the pair of read-ids

		print OUT_FILE "$first_index     $second_index\n";
	    }
	} # inner loop
    } # outer loop

    close(OUT_FILE);

    print "done.\n";
}

