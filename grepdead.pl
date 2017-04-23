#! /usr/bin/perl

if ($#ARGV < 0)
{
    print "Useage: $0  file1  [file2 ...]\n";
    print "   Scans each file for NULL characters and prints out\n";
    print "   the human genome fasta file corresponding to it.\n";
    exit(0);
}

$num_files = $#ARGV + 1;
$num_success = 0;

for ($i = 0; $i < $num_files; $i++)
{
    $filename = $ARGV[$i];

    open (FILE, $filename) ||
	die "ERROR: Can't open $filename\n";

    $filename =~ /(.+)\.fa.+/;
    $humanfile = "$1.fa";

    $failed = 0;

    while ( ($failed == 0) &&
	    ($line = <FILE>) )
    {
	if ($line =~ /\x0/)
	{	
	    $failed = 1;
	    print "$humanfile\n";
	}
    }

    close(FILE);

    if ($failed == 0)
    {
	$num_success++;
    }
}

print "Out of $num_files files, $num_success many succeeded.\n";
