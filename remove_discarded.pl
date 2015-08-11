#! /util/bin/perl

# Useage: remove_discarded.pl  unique.1  [unique.2 ...]
#


if ($#ARGV < 0)
{
    print "Useage: $0  unique.1  [unique.2 ...]\n";
    print "   for each  unique.i  file, reads the file  discarded.i, removes those entries\n";
    print "   of  unique.i  that occurs in  discarded.i, and writes the result to  wanted.i\n";
    print "(NB: this should be run only after running  pick_index.pl)\n";
    exit(0);
}

@unique_files = @ARGV;

while (@unique_files > 0)
{
    $unique_file = shift(@unique_files);
    $unique_file =~ /unique\.(\d+)/;
    $discards_file = "discarded.$1";
    $out_file = "wanted.$1";

    print "Doing $unique_file --> $out_file ...";

    %discards_lines = ();

    open(DISCARDS_FILE, $discards_file) || die "Can't open $discards_file\n";
    while ($line = <DISCARDS_FILE>)
    {
	$line =~ /^(\d+)\s+(.+)/;
	$discards_lines{$1} = $2;
    }
    close(DISCARDS_FILE);


    open(UNIQUE_FILE, $unique_file) || die "Can't open $unique_file\n";
    open(OUT_FILE, "> $out_file") || die "Can't open $out_file for output\n";
    while (<UNIQUE_FILE>)
    {
	$line = $_;
	$line =~ /^QUERY\s+(\d+)/;

	if (!exists($discards_lines{$1}))
	{
	    print OUT_FILE $line;
	}
    }
    close(OUT_FILE);
    close(UNIQUE_FILE);

    print "done.\n";
}
