#!/usr/local/bin/perl5 -w

# Regression test driver for primer3 executable.
#
# Usage: $0 [<primer3>]
#
# <primer3> defaults to primer3, in which case the executable
# run is ../src/primer3.
#
# If <primer3> is specified, the executable run is 
# ../src/<primer3>.
#
# Stderr difference tests for fatal errors are performed only
# if <primer3> is 'primer3' (because the executable name
# is part of the text written to stderr).

$ENV{TC_SILENT} = '1';	# TestCenter proofed executables will not 
                        # write extra stuff to std{err,out}, and
                        # consequently will not cause spurious diff's.

$ENV{TC_RESULTDIR} = './tc_results'; # Directory for testcenter results.
    

$exe = 'primer3_core';
$exe = $ARGV[0] if defined $ARGV[0];
$p1 =  "../src/$exe";
$EXIT_STAT = 0;

die "Cannot execute $p1" unless -x $p1;

print STDERR "\n\n$0: testing $p1 ", `date`;

test_fatal_errors($p1);

my $cmd;
for $test (
           'primer_boundary',   # Put the quickest tests first.
           'primer_internal',
           'primer_boundary_formated',
           'primer_internal_formated',
	   'primer_start_codon',
           'primer_boundary1',
           'primer_internal1',
	   'primer_task',
	   'primer_task_formated',
           'primer_boundary1_formated',
           'primer_internal1_formated',
	   'primer_check',
	   'primer_must_use',
	   'primer_must_use_formated',
           'primer_syntax',
           'primer_end_pathology',
           'primer_num_best',
	   'primer_quality_boundary',
	   'primer_obj_fn',
           'primer',
           'primer1',
           'primer_mispriming',
           'primer_mispriming_formated',
           'primer_mispriming_boundary1',
           'primer_mispriming_boundary1_formated',
           'primer_mispriming_boundary2',
           'primer_mispriming_boundary2_formated',
           'primer_mispriming_long_lib',
           'primer_rat',
           'primer_human',
           'primer_ch',
           'long_seq',
           'primer_position_penalty',
           'primer_position_penalty_formated',
	   ) {
    print STDERR "$test ";
    $testx = $test;
    $testx =~ s/_formated$//;
    $input = $testx . '_input';
    $output = $test . '_output';
    $tmp = $test . '_tmp';
    if ($test ne 'primer_ch') {
	die "Cannot read $input"  unless -r $input;
	die "Cannot read $output"  unless -r $output;
    }

    if ($test eq 'primer' || $test eq 'primer1') {
	$list_tmp = $test.'_list_tmp';
	# We need to chdir below because primer3 puts the 'list' files
        # in the current working directory.  Therefore we adjust
	# the TestCenter result directory.
	$cmd = "rm -f $list_tmp/*.*; "
	    . "cd $list_tmp; ../$p1 -strict_tags <../$input >../$tmp";
	$ENV{TC_COMMENT} = $cmd;
	# Reset the TestCenter result directory.
	$save_results = $ENV{TC_RESULTDIR};
	$ENV{TC_RESULTDIR} = "../$save_results";
	$r = system $cmd;
	$ENV{TC_RESULTDIR} = $save_results;
	$ENV{TC_COMMENT} = '';
    } elsif ($test =~ /formated$/) {
	$cmd = "$p1 -strict_tags -format_output <$input >$tmp";
	$ENV{TC_COMMENT} = $cmd;
	$r = system $cmd;
	$ENV{TC_COMMENT} = '';
    } else {
	# We do not distribute primer_ch_input.
	unless ($test eq 'primer_ch' && !-e 'primer_ch_input') {
	    $cmd = "$p1 -strict_tags <$input >$tmp";
	    $ENV{TC_COMMENT} = $cmd;
	    $r = system $cmd;
	    $ENV{TC_COMMENT} = '';
	}
    }

    unless ($r == 0) {
	print STDERR "NON-0 EXIT: $r\n";
	$EXIT_STAT = -1;
	next;
    }

    $r = system "diff $output $tmp"
	unless ($test eq 'primer_ch' && !-e 'primer_ch_input');

    if ($r == 0) {
	print STDERR "OK\n";
    } else {
	print STDERR "FAILED\n";
	$EXIT_STAT = -1;
    }
    if ($test eq 'primer' || $test eq 'primer1') {
	$list_tmp = $test.'_list_tmp';
	$list_last = $test.'_list_last';
	if  (-e "$list_tmp/.cvsignore") {
	    $r = system "mv $list_tmp/.cvsignore ./saved.cvsignore; "
		. "diff $list_last $list_tmp";
	    system "mv ./saved.cvsignore $list_tmp/.cvsignore";
	} else {
	    $r = system "diff $list_tmp $list_last";
	}
	print STDERR "$test list files ";
	if ($r == 0) {
	    print STDERR "OK\n";
	} else { 
	    print STDERR "FAILED\n";
	    $EXIT_STAT = -1;
	}
    }
}

print STDERR "DONE\n";
exit ($EXIT_STAT);

sub test_fatal_errors {
    my $exe = $_[0];
    my $skip_stderr = 0;
    if ($exe ne '../src/primer3_core') {
	print STDERR "Skipping comparisons of stderr because ",
	"executable is not ../src/primer3_core";
	$skip_stderr = 1;
    }
    my $inputs = `ls primer_global_err/*.in`;
    my @inputs = split /\s/, $inputs;
    my ($root, $cmd, $r);
    my $problem = 0;
    print STDERR "\nTesting fatal errors\n";
    for (@inputs) {
	($root) = /(.*)\.in$/;
	$cmd = "$exe <$_ > $root.tmp 2> $root.tmp2";
	$ENV{TC_COMMENT} = $cmd;
	system $cmd;
	$ENV{TC_COMMENT} = '';
	if ($? == 0) {
	    $r = $? >> 8;
	    print STDERR "\nErroneous 0 exit status ($?) from command $cmd\n";
	    $problem = 1;
	}
	$r = system "diff $root.out $root.tmp";
	if ($r != 0) {
	    print STDERR
		"Difference found between $root.out and $root.tmp\n\n";
	    $problem = 1;
	}
	unless ($skip_stderr) {
	    $r = system "diff $root.out2 $root.tmp2";
	    if ($r != 0) {
		print STDERR
		    "\nDifference found between $root.out2 and $root.tmp2\n\n";
		$problem = 1;
	    }
	}
    }
    print STDERR $problem ? "FAILED" : "OK" ,"\n\n";
}

