#! /usr/bin/perl

if ($#ARGV < 0)
{
    print "Useage: $0  file1.bzh  [file2.bzh ...]\n";
    print "   Scans each bzh file and prints out the human genome fasta file\n";
    print "   corresponding to those runs which failed.\n";
    exit(0);
}

$num_files = $#ARGV + 1;
$num_success = 0;

for ($i = 0; $i < $num_files; $i++)
{
    $filename = $ARGV[$i];

    open (FILE, $filename) ||
	die "ERROR: Can't open $filename\n";

    $done = 0;

    while ($done == 0)
    {
	$line = <FILE>;

	if ($line =~ /LSBATCH/)
	{	
	    $done = 1;

	    $cmdline = <FILE>;
	    $cmdline =~ m|\s+.*\s.+/(.+\.fa)\s|;
	    $humanfile = $1;

	    $line = <FILE>;
	    $line = <FILE>;
	    $line = <FILE>;
	    
	    if ($line =~ /Successfully completed\./)
	    {
		$num_success++;
		# print "Success: $humanfile\n";
	    }
	    else
	    {
		print "$humanfile\n";
		# print "Failed:  $humanfile\n";
	    }
	}
    }

    close(FILE);
}

print "Out of $num_files files, $num_success many succeeded.\n";
