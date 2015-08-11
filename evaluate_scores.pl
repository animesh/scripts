#! /util/bin/perl

if ($#ARGV < 2 || $#ARGV > 3)
{
    print "Useage: $0  scores_file  true_aligns_file  prefix  [cutoff]\n";
    print "    NB: scores_file    should be the output of  GetAlignmentScores\n";
    print "    Generates five output files:\n";
    print "        prefix.notfound   : true alignments which were not found\n";
    print "        prefix.true_pass  : true alignments that pass the cutoff score\n";
    print "        prefix.true_fail  : true alignments that fail the cutoff score\n";
    print "        prefix.false_pass : false alignments that pass the cutoff score\n";
    print "        prefix.false_fail : false alignments that fail the cutoff score\n";
    print "    If the optional  cutoff  score is not given, then\n";
    print "    the best cutoff score will be evaluated, and\n";
    print "    an additional output file will be generated:\n";
    print "        prefix.eval       : evaluation of cutoff scores\n";
    exit(0);
}

$scores_file = $ARGV[0];
$true_aligns_file = $ARGV[1];
$prefix = $ARGV[2];
$eval_file = "$prefix.eval";
$notfound_file = "$prefix.notfound";
$true_pass_file = "$prefix.true_pass";
$true_fail_file = "$prefix.true_fail";
$false_pass_file = "$prefix.false_pass";
$false_fail_file = "$prefix.false_fail";

######

$now_time = localtime;
print "$now_time: Reading $scores_file...\n";

%found_aligns = ();
$num_found_aligns = 0;

open(SCORES_FILE, $scores_file) || die "Can't open $scores_file\n";
while (<SCORES_FILE>)
{
    /^\s*([\d.]+)\s+(\d+)\s+(\d+)/;
    $found_aligns{"$2,$3"} = $_;
    $num_found_aligns++;
}
close(SCORES_FILE);

$now_time = localtime;
print "$now_time: Reading $scores_file...done.\n";

if ($num_found_aligns == 0)
{
    die "No alignments found in $scores_file\n";
}

######

$now_time = localtime;
print "$now_time: Reading $true_aligns_file and evaluating...\n";

@true_found = ();
@false_found = ();
@true_notfound = ();

$num_true_aligns = 0;
open(TRUE_ALIGNS_FILE, $true_aligns_file) || die "Can't open $true_aligns_file\n";
while (<TRUE_ALIGNS_FILE>)
{
    $num_true_aligns++;

    $align = $_;
    /^\s*(\d+)\s+(\d+)/;

    $index1 = $1;
    $index2 = $2;

    if ( exists($found_aligns{"$index1,$index2"}) )
    {
	## true alignment
	push @true_found, $found_aligns{"$index1,$index2"};
	delete $found_aligns{"$index1,$index2"};
    }
    elsif ( exists($found_aligns{"$index2,$index1"}) )
    {
	## true alignment
	push @true_found, $found_aligns{"$index2,$index1"};
	delete $found_aligns{"$index2,$index1"};
    }
    else
    {
	## false negative
	if ($index1 <= $index2)
	{
	    $notfound_align = sprintf "%10u %10u\n", ($index1, $index2);
	}
	else
	{
	    $notfound_align = sprintf "%10u %10u\n", ($index2, $index1);
	}
	
	push @true_notfound, $notfound_align;
    }
}
close(TRUE_ALIGNS_FILE);


foreach $key (keys %found_aligns)
{
    push @false_found, $found_aligns{$key};
}

undef %found_aligns;

$now_time = localtime;
print "$now_time: Reading $true_aligns_file and evaluating...done.\n";


if ($num_true_aligns == 0)
{
    die "No alignment found in $true_aligns_file\n";
}


if ($num_found_aligns != scalar(@true_found) + scalar(@false_found))
{
    warn "WARNING: the number $num_found_aligns of alignments in $scores_file\n";
    warn "         is different from the sum of the number of true alignments found\n";
    warn "         and the number of false alignments found.\n";
}

if ($num_true_aligns != scalar(@true_found) + scalar(@true_notfound))
{
    warn "WARNING: the number $num_true_aligns of true alignments in $true_aligns_file\n";
    warn "         is different from the sum of the number of true alignments found\n";
    warn "         and the number of true alignments not found.\n";
}


#######

$now_time = localtime;
print "$now_time: Sorting results...\n";


@temp = ();
@tempall = ();

for (@true_found)
{
    /^\s*([\d.]+)/;
    push @temp, $1;
    push @tempall, $1;
}
@true_found_scores = sort {$a <=> $b} @temp;

if (scalar(@true_found_scores) != scalar(@true_found))
{
    die "Entries were lost while sorting true_found_scores\n";
}


@temp = ();
for (@false_found)
{
    /^\s*([\d.]+)/;
    push @temp, $1;
    push @tempall, $1;
}
@false_found_scores = sort {$a <=> $b} @temp;


if (scalar(@true_found_scores) != scalar(@true_found))
{
    die "Entries were lost while sorting false_found_scores\n";
}

@all_scores = sort {$a <=> $b}  @tempall;

if (scalar(@all_scores) != $num_found_aligns)
{
    print scalar(@all_scores);
    print "\n$num_found_aligns\n";
    print scalar(@true_found_scores);
    print "\n";
    print scalar(@false_found_scores);
    print "\n";

    die "Entries were lost while sorting all_scores\n";
}

$now_time = localtime;
print "$now_time: Sorting results...done.\n";

#####

if ($#ARGV == 3)
{
    # cutoff score was given by user
    $now_time = localtime;
    print "$now_time: Using given cutoff score $best_cutoff.\n";

    $best_cutoff = $ARGV[3];
    @best_evalout = eval_cutoff($best_cutoff);
}
else
{
    $now_time = localtime;
    print "$now_time: Computing best cutoff score...\n";

    $best_cutoff = -1;
    $best_accuracy = 0;
    @best_evalout = ();

    $prev_cutoff = -1;
    $prev_accuracy = 0.001;

    $num_consec_drop_accuracy = 0;

    open(EVAL_FILE, "> $eval_file") || die "Can't open $eval_file for output\n";

    foreach (@all_scores)
    {
	$cutoff = sprintf "%3.2f", $_;
	next if ($cutoff == $prev_cutoff);

	next if ($cutoff - $prev_cutoff < $prev_cutoff/100);

	@evalout = eval_cutoff($cutoff);
	$accuracy = $evalout[0];
	$prev_cutoff = $cutoff;

	if ($best_accuracy < $accuracy)
	{
	    $best_accuracy = $accuracy;
	    @best_evalout = @evalout;
	    $best_cutoff = $cutoff;
	}

	$outstring = sprintf "%3.2f  %3.3f  %3.3f  %6u %6u %6u %6u\n", ($cutoff, @evalout);
	print EVAL_FILE $outstring;
    }

    close(EVAL_FILE);

    $now_time = localtime;
    print "$now_time: Computing best cutoff score...done.\n";
}

######

$now_time = localtime;
print "$now_time: Writing output...\n";


open(NOTFOUND_FILE, "> $notfound_file") ||
    die "Can't open $notfound_file for output\n";
foreach (sort @true_notfound)
{
    print NOTFOUND_FILE $_;
}
close(NOTFOUND_FILE);


open(TRUE_PASS_FILE, "> $true_pass_file") ||
    die "Can't open $true_pass_file for output\n";
open(TRUE_FAIL_FILE, "> $true_fail_file") ||
    die "Can't open $true_fail_file for output\n";
foreach (@true_found)
{
    /\s*([\d.]+)/;
    if ($1 <= $best_cutoff)
    {
	print TRUE_PASS_FILE $_;
    }
    else
    {
	print TRUE_FAIL_FILE $_;
    }
}
close(TRUE_FAIL_FILE);
close(TRUE_PASS_FILE);


open(FALSE_PASS_FILE, "> $false_pass_file") ||
    die "Can't open $false_pass_file for output\n";
open(FALSE_FAIL_FILE, "> $false_fail_file") ||
    die "Can't open $false_fail_file for output\n";
foreach (@false_found)
{
    /\s*([\d.]+)/;
    if ($1 <= $best_cutoff)
    {
	print FALSE_PASS_FILE $_;
    }
    else
    {
	print FALSE_FAIL_FILE $_;
    }
}
close(FALSE_FAIL_FILE);
close(FALSE_PASS_FILE);


$now_time = localtime;
print "$now_time: Writing output...done.\n";


######

print "\n";

$summary0 = sprintf "%8u true alignments in total\n",
    $num_true_aligns;
$summary1 = sprintf "%8u (%3.1f\%) true alignments were found\n",
    (scalar(@true_found), 100 * scalar(@true_found) / $num_true_aligns);
$summary2 = sprintf "%8u (%3.1f\%) true alignments were not found\n\n",
    (scalar(@true_notfound), 100 * scalar(@true_notfound) / $num_true_aligns);
$summary3 = sprintf "%8u alignments found; of these, %3.1f",
    ($num_found_aligns, 100 * scalar(@true_found) / $num_found_aligns);
$summary3 = "$summary3\% are true alignments.\n\n";

print ($summary0,$summary1,$summary2,$summary3);

($accuracy, $true_proportion,
 $num_true_pass, $num_false_fail, $num_true_fail, $num_false_pass) = @best_evalout;

print "For these $num_found_aligns alignments found,\n";

$summary0 = sprintf "the best cutoff score is $best_cutoff with an accuracy of %3.3f\%.\n\n",
    $accuracy;
$summary1 = sprintf "%8u are true alignments which passed (%3.1f",
    ($num_true_pass, 100 * $num_true_pass / scalar(@true_found));
$summary1 = "$summary1\% of true alignments found)\n";
$summary2 = sprintf "%8u are false alignments which failed (%3.1f",
    ($num_false_fail, 100 * $num_false_fail / scalar(@false_found));
$summary2 = "$summary2\% of false alignments found)\n";
$summary3 = sprintf "%8u are true alignments which failed (%3.1f",
    ($num_true_fail, 100 * $num_true_fail / scalar(@true_found));
$summary3 = "$summary3\% of true alignments found)\n";
$summary4 = sprintf "%8u are false alignments which passed (%3.1f",
    ($num_false_pass, 100 * $num_false_pass / scalar(@false_found));
$summary4 = "$summary4\% of false alignments found)\n\n";
$num_pass = $num_true_pass+$num_false_pass;
$summary5 = sprintf "%8u alignments passed; of these, %3.3f",
    ($num_pass, $true_proportion);
$summary5 = "$summary5\% are true alignments.\n\n";

print ($summary0, $summary1, $summary2, $summary3, $summary4, $summary5, $summary6);

exit(0);

####################

sub eval_cutoff
{
    $cutoff = shift(@_);

    my ($true_pass, $true_fail, $false_pass, $false_fail);

    $true_pass = count_leq($cutoff, \@true_found_scores);
    $true_fail = scalar(@true_found_scores) - $true_pass;

    $false_pass = count_leq($cutoff, \@false_found_scores);
    $false_fail = scalar(@false_found) - $false_pass;

    return (100*($true_pass+$false_fail)/$num_found_aligns,
	    100*$true_pass/($true_pass+$false_pass),
	    $true_pass, $false_fail, $true_fail, $false_pass);
}

####################

sub count_leq
{
    # returns the number of elements in the sorted (reference) array $arrayref
    # whose values are <= the given $val
    
    ($val, $arrayref) = @_;

    my ($begin, $end, $mid);

    $begin = 0;
    $end = scalar(@$arrayref);

    while (1)
    {
	if ($begin >= $end)
	{
	    return $end;
	}

	$mid = int ($begin + $end)/2;

	if ($val < $$arrayref[$mid])
	{
	    $end = $mid;
	}
	elsif ($val > $$arrayref[$mid])
	{
	    $begin = $mid+1;
	}
	else
	{
	    while ( ($mid < $end) &&
		    ($val == $$arrayref[$mid]) )
	    {
		$mid++;
	    }
	    return $mid;
	}
    }
}
