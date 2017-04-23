#! /util/bin/perl

if ($#ARGV < 1)
{
    print "Useage: $0  pairto_file  wanted.1  [wanted.2 ...]\n";
    print "   for each  wanted.i  file, writes to the file  wanted_and_partner.i\n";
    print "   the indices of all reads in  wanted.i  and the indices of their partners\n";
    print "   as given by the reads.pairto file.\n";
    exit(0);
}

$pairto_file = shift @ARGV;
@wanted_files = @ARGV;


$now_time = localtime;
print "$now_time: Reading $pairto_file...\n";

open(PAIRTO_FILE, $pairto_file) || die "Can't open $pairto_file\n";
$num_pairs = <PAIRTO_FILE>;  # the first line is the number of pairs
chomp $num_pairs;

%partner = ();

while (<PAIRTO_FILE>)
{
    /\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/;

    $id1 = $1;
    # $separation = $2;
    $id2 = $3;
    # $std_dev = $4;
    # $type = $5;
    # $weight = $6;

    $partner{$id1} = $id2;
    $partner{$id2} = $id1;
}

close(PAIRTO_FILE);

$now_time = localtime;
print "$now_time: Reading $pairto_file...done.\n";


while (@wanted_files > 0)
{
    $wanted_file = shift(@wanted_files);
    $wanted_file =~ /.+\.(\d+)/;
    $out_file = "wanted_and_partner.$1";

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
	# $first_start = $2;
	# $first_end = $3;
	# $first_length = $4;
	# $first_rc = $5;
	# $first_start_coord = $7;
	# $first_end_coord = $8;
	
	print OUT_FILE "$first_index\n";

	if (exists($partner{$first_index}))
	{
	    $partner_index = $partner{$first_index};
	    print OUT_FILE "$partner_index\n";
	}

    } # outer loop

    close(OUT_FILE);

    $now_time = localtime;
    print "$now_time: Doing $wanted_file --> $out_file ...done.\n";
}

