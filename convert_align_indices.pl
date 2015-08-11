#! /util/bin/perl

if ($#ARGV < 2)
{
    print "Useage: $0  old_id_file  new_id_file  zaligns.i\n";
    print "   translates the read indices in  zaligns.i,  based on  old_id_file,\n";
    print "   into new read indices based on  new_id_file, and write them\n";
    print "   to  true_aligns.i\n";
    exit(0);;
}

$old_id_file = shift @ARGV;
$new_id_file = shift @ARGV;

######

@old_ids = ();

$now_time = localtime;
print "$now_time: Reading $old_id_file...\n";

open(IDFILE, $old_id_file) || die "Can't open $old_id_file\n";
$old_ids_length = <IDFILE>;  # the first line is the number of reads
chomp $old_ids_length;

while (<IDFILE>)
{
    chomp;
    push @old_ids, $_;
}

close(IDFILE);

$now_time = localtime;
print "$now_time: Reading $old_id_file...done\n";

if ($old_ids_length != scalar(@old_ids))
{
    print "The declared number $old_ids_legnth of reads in $old_id_file is different\n";
    print "from the actual number ", scalar(@old_ids), " found.\n";
    exit(-1);
}

######

%new_indices = ();

$now_time = localtime;
print "$now_time: Reading $new_id_file...\n";

open(IDFILE, $new_id_file) || die "Can't open $new_id_file\n";
$new_ids_length = <IDFILE>;  # the first line is the number of reads

while (<IDFILE>)
{
    chomp;
    $new_indices{$_} = $i;
    $i++;
}

close(IDFILE);

$now_time = localtime;
print "$now_time: Reading $new_id_file...done\n";

if ($new_ids_length != $i)
{
    print "The declared number $new_ids_legnth of reads in $new_id_file is different\n";
    print "from the actual number $i found.\n";
    exit(-1);
}

######

$input_file = shift @ARGV;
$input_file =~ /zaligns\.(.+)/;
$output_file = "true_aligns.$1";
$unresolved_file = "unresolved.$1";

print "Doing $input_file --> $output_file ...\n";

open(INPUT_FILE, $input_file) || die "Can't open $input_file\n";
open(OUTPUT_FILE, "> $output_file") || die "Can't open $output_file for output\n";

$i = 0;
@unresolved = ();
while (<INPUT_FILE>)
{
    /\s*(\d+)\s+(\d+)/;

    $id1 = $old_ids[$1];
    $id2 = $old_ids[$2];
    if (!exists( $new_indices{$id1} ) ||
	!exists( $new_indices{$id2} ) )
    {
	$outstring = sprintf "%8u %8u\t%s\t%s\n", ($1,$2,$id1,$id2);
	push @unresolved, $outstring;
	print "unresolved: $outstring";
    }
    else
    {
	$new_index1 = $new_indices{$id1};
	$new_index2 = $new_indices{$id2};
	$outstring = sprintf "%8u %8u\n", ($new_index1, $new_index2);
	print OUTPUT_FILE $outstring;
    }
}

close(OUTPUT_FILE);
close(INPUT_FILE);


if (@unresolved > 0)
{
    print "WARNING: There were unresolved alignments: see $unresolved_file\n";

    open(UNRES_FILE, "> $unresolved_file") || die "Can't open $unresolved_file for output\n";
    foreach (@unresolved)
    {
	print UNRES_FILE $_;
    }
    close(UNRES_FILE);
}

print "Doing $input_file --> $output_file ...done\n";

