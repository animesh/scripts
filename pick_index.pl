#! /util/bin/perl

# Useage: pick_index.pl  unique_index_file  target.1  [target.2 ...]
#


if ($#ARGV < 1)
{
    print "Useage: $0  unique_index_file  target.1  [target.2 ...]\n";
    print "   for each  target.i  file, writes to the file  unique.i  all the entries\n";
    print "   of  unique_index_file  that occurs in  target.i\n";
    exit(0);;
}

$unique_index_file = shift(@ARGV);
@target_files = @ARGV;

open(UNIQUE_INDEX_FILE, $unique_index_file) || die "Can't open $unique_index_file\n";
@unique_indexs = <UNIQUE_INDEX_FILE>;
close(UNIQUE_INDEX_FILE);

# The first line of $unique_index_file
# is assumed to contain the number of entries;
# it is ignored.
shift(unique_indexs);  

while (@target_files > 0)
{
    $target_file = shift(@target_files);
    $target_file =~ /.+\.(\d+)/;
    $out_file = "unique.$1";

    print "Doing $target_file --> $out_file ...";

    %target_lines = ();

    open(TARGET_FILE, $target_file) || die "Can't open $target_file\n";
    while ($line = <TARGET_FILE>)
    {
	if ($line =~ /QUERY\s+(\d+)/)
	{
	    $target_lines{$1} = $line;
	}
    }
    close(TARGET_FILE);

    open(OUT_FILE, "> $out_file") || die "Can't open $out_file for output\n";
    foreach (@unique_indexs)
    {
	$id = $_;
	chomp $id;

	if (exists($target_lines{$id}))
	{
	    print OUT_FILE $target_lines{$id};
	}
    }
    close(OUT_FILE);

    print "done.\n";
}

