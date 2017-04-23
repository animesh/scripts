#!/usr/bin/perl

if ($#ARGV < 0)
{
    print "Useage: $0  file1.ecf  [file2.ecf ...]\n";
    print "  Convert the given ECF files into a single sorted list\n";
    print "  of entries, filter the list to pick out the good alignments\n";
    print "  and print the results to the standard output.\n";
    print "\n";
    exit(0);
}


####################
# Load all input ECF files
# and grep for those lines beginning with "chain"

$num_files = $#ARGV + 1;

@chains = ();

for ($i = 0; $i < $num_files; $i++)
{
    $filename = $ARGV[$i];

    open (DATAFILE, $filename) ||
	die "ERROR: Can't open $filename\n";

    while ($chainline = <DATAFILE>)
    {
	if ($chainline =~ /^chain (\d+) .+ \d+ . \d+ \d+ (.+) \d+ . \d+ \d+/)
	{
	    $score = $1;
	    $read_id = $2;

	    @stanza_lines = ();
	    $line = <DATAFILE>;
	    
	    while ($line =~ /^\d+/)
	    {
		chomp($line);
		push @stanza_lines, $line;
		$line = <DATAFILE>;
	    }
	    
	    $dataline = join(',', @stanza_lines);

	    chomp($chainline);
	    push @chains, "$read_id $score == $chainline,$dataline";
	}
    }

    close (DATAFILE);
}


####################
# Sort the list of chains according to the read ID

@sorted_chains = sort @chains;
undef @chains;


####################
# Create separate lists of read IDs and alignment scores 

$num_aligns = 0;
@align_read_id = ();
@align_score = ();
@align_line = ();

foreach $line (@sorted_chains)
{
    $line =~ /(.+) (\d+) == (.+)$/;

    $read_id = $1;
    $score = $2;
    $rmdrline = $3;

    push @align_read_id, $read_id;
    push @align_score, $score;
    push @align_line, $rmdrline;

    $num_aligns++;
}


####################
# Filter the list according the alignment score

# array index for a block of consecutive entries with the same read_id
$blk_index = 0;

while ($blk_index < $num_aligns)
{
    @blk_scores = ();
    $blk_size = 0;

    $curr_blk_index = $blk_index;
    $curr_read_id = $align_read_id[$blk_index];

    while ($blk_index < $num_aligns &&
	   $align_read_id[$blk_index] eq $curr_read_id)
    {
	push @blk_scores, $align_score[$blk_index];
	$blk_size++;

	$blk_index++;
    }

    # now the indices in the interval  [$curr_blk_index, $blk_index)
    # all have the same  $align_read_id[..] value, equal to $curr_read_id

    @sorted_blk_scores = sort {$b <=> $a} @blk_scores;

    $sorted_blk_index = 0;
    while ($sorted_blk_index < $blk_size - 1  &&
	   $sorted_blk_scores[$sorted_blk_index] -
	   $sorted_blk_scores[$sorted_blk_index+1] < 3000)
    {
	$sorted_blk_index++;
    }
    $blk_cutoff_score = $sorted_blk_scores[$sorted_blk_index];


    if ($blk_cutoff_score >= 3000)
    {
	for ($i = $curr_blk_index; $i < $blk_index; $i++)
	{
	    if ($align_score[$i] >= $blk_cutoff_score)
	    {
		# print the align_line entry
		
		$line = $align_line[$i];
		$line =~ s/,/\n/g;

		print $line;
		print "\n";
	    }
	}
    }

} # while ($blk_index < $num_aligns)
