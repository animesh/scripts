use strict;

#  Prepare for consensus on the grid
#    Partition the contigs
#    Repartition the frag store

sub createPostScaffolderConsensusJobs ($) {
    my $cgwDir   = shift @_;

    return if (-e "$wrk/8-consensus/jobsCreated.success");

    #  Check that $cgwDir is complete
    #
    caFailure("Didn't find '$cgwDir/$asm.SeqStore'.\n") if (! -d "$cgwDir/$asm.SeqStore");
    caFailure("Didn't find '$cgwDir/$asm.cgw_contigs'.\n" ) if (! -e "$cgwDir/$asm.cgw_contigs");

    my $lastckpt = findLastCheckpoint($cgwDir);
    caFailure("Didn't find any checkpoints in '$cgwDir'\n") if (!defined($lastckpt));

    my $partitionSize = int($numFrags / getGlobal("cnsPartitions"));
    $partitionSize = getGlobal("cnsMinFrags") if ($partitionSize < getGlobal("cnsMinFrags"));

    if (! -e "$wrk/8-consensus/partitionSDB.success") {
        my $cmd;
        $cmd  = "$bin/PartitionSDB -all -seqstore $cgwDir/$asm.SeqStore -version $lastckpt -fragsper $partitionSize -input $cgwDir/$asm.cgw_contigs ";
        $cmd .= "> $wrk/8-consensus/partitionSDB.err 2>&1";

        caFailure("Failed.\n") if (runCommand("$wrk/8-consensus", $cmd));
        touch("$wrk/8-consensus/partitionSDB.success");
    }

    if (-z "$wrk/8-consensus/UnitigPartition.txt") {
        print STDERR "WARNING!  Nothing for consensus to do!  Forcing consensus to skip!\n";
        touch("$wrk/8-consensus/partitionFragStore.success");
        touch("$wrk/8-consensus/jobsCreated.success");
        return;
    }

    if (! -e "$wrk/8-consensus/$asm.partitioned") {
        my $cmd;
        $cmd  = "$bin/gatekeeper -P $wrk/8-consensus/FragPartition.txt $wrk/$asm.gkpStore ";
        $cmd .= "> $wrk/8-consensus/$asm.partitioned.err 2>&1";

         "Failed.\n" if (runCommand("$wrk/8-consensus", $cmd));
        touch("$wrk/8-consensus/$asm.partitioned");
    }

    ########################################
    #
    #  Build consensus jobs for the grid -- this is very similar to that in createPostUnitiggerConsensus.pl
    #
    my $jobP;
    my $jobs = 0;

    open(CGW, "ls $cgwDir/$asm.cgw_contigs.* |") or caFailure("ls of $cgwDir/$asm.cgw_contigs.* failed.");
    while (<CGW>) {
        if (m/cgw_contigs.(\d+)/) {
            $jobP .= "$1\t";
            $jobs++;
        } else {
            print STDERR "Didn't match cgw_contigs.# in $_\n";
        }
    }
    close(CGW);

    $jobP = join ' ', sort { $a <=> $b } split '\s+', $jobP;

    open(F, "> $wrk/8-consensus/consensus.sh") or caFailure("Can't open '$wrk/8-consensus/consensus.sh'\n");
    print F "#!/bin/sh\n";
    print F "\n";
    print F "jobid=\$SGE_TASK_ID\n";
    print F "if [ x\$jobid = x -o x\$jobid = xundefined ]; then\n";
    print F "  jobid=\$1\n";
    print F "fi\n";
    print F "if [ x\$jobid = x ]; then\n";
    print F "  echo Error: I need SGE_TASK_ID set, or a job index on the command line.\n";
    print F "  exit 1\n";
    print F "fi\n";
    print F "jobp=`echo $jobP | cut -d' ' -f \$jobid`\n";
    print F "\n";
    print F "if [ -e $wrk/8-consensus/$asm.cns_contigs.\$jobp.success ] ; then\n";
    print F "  exit 0\n";
    print F "fi\n";
    print F "\n";
    print F "AS_OVL_ERROR_RATE=", getGlobal("ovlErrorRate"), "\n";
    print F "AS_CNS_ERROR_RATE=", getGlobal("cnsErrorRate"), "\n";
    print F "AS_CGW_ERROR_RATE=", getGlobal("cgwErrorRate"), "\n";
    print F "export AS_OVL_ERROR_RATE AS_CNS_ERROR_RATE AS_CGW_ERROR_RATE\n";
    print F "\n";
    print F "echo \\\n";
    print F "$gin/consensus \\\n";
    print F "  -s $cgwDir/$asm.SeqStore \\\n";
    print F "  -V $lastckpt \\\n";
    print F "  -p \$jobp \\\n";
    print F "  -S \$jobp \\\n";
    print F "  -m \\\n";
    print F "  -o $wrk/8-consensus/$asm.cns_contigs.\$jobp \\\n";
    print F "  $wrk/$asm.gkpStore \\\n";
    print F "  $cgwDir/$asm.cgw_contigs.\$jobp \\\n";
    print F " \\> $wrk/8-consensus/$asm.cns_contigs.\$jobp.err 2\\>\\&1\n";
    print F "\n";
    print F "$gin/consensus \\\n";
    print F "  -s $cgwDir/$asm.SeqStore \\\n";
    print F "  -V $lastckpt \\\n";
    print F "  -p \$jobp \\\n";
    print F "  -S \$jobp \\\n";
    print F "  -m \\\n";
    print F "  -o $wrk/8-consensus/$asm.cns_contigs.\$jobp \\\n";
    print F "  $wrk/$asm.gkpStore \\\n";
    print F "  $cgwDir/$asm.cgw_contigs.\$jobp \\\n";
    print F " >> $wrk/8-consensus/$asm.cns_contigs.\$jobp.err 2>&1 \\\n";
    print F "&& \\\n";
    print F "touch $wrk/8-consensus/$asm.cns_contigs.\$jobp.success\n";
    print F "exit 0\n";
    close(F);

    chmod 0755, "$wrk/8-consensus/consensus.sh";

    if (getGlobal("cnsOnGrid") && getGlobal("useGrid")) {
        my $sge          = getGlobal("sge");
        my $sgeConsensus = getGlobal("sgeConsensus");

        my $SGE;
        $SGE  = "qsub $sge $sgeConsensus -r y -N NAME ";
        $SGE .= "-t MINMAX ";
        $SGE .= "-j y -o /dev/null ";
        $SGE .= "$wrk/8-consensus/consensus.sh\n";

	my $numThreads = 1;
        my $waitTag = submitBatchJobs("cns2", $SGE, $jobs, $numThreads);

        if (runningOnGrid()) {
            touch("$wrk/8-consensus/jobsCreated.success");
            submitScript("$waitTag");
            exit(0);
        } else {
            touch("$wrk/8-consensus/jobsCreated.success");
            exit(0);
        }
    } else {
        for (my $i=1; $i<=$jobs; $i++) {
            &scheduler::schedulerSubmit("sh $wrk/8-consensus/consensus.sh $i > /dev/null 2>&1");
        }

        &scheduler::schedulerSetNumberOfProcesses(getGlobal("cnsConcurrency"));
        &scheduler::schedulerFinish();

        touch("$wrk/8-consensus/jobsCreated.success");
    }
}


sub postScaffolderConsensus ($) {
    my $cgwDir   = shift @_;

    system("mkdir $wrk/8-consensus") if (! -d "$wrk/8-consensus");

    goto alldone if (-e "$wrk/8-consensus/consensus.success");

    $cgwDir = "$wrk/7-CGW" if (!defined($cgwDir));

    createPostScaffolderConsensusJobs($cgwDir) if (! -e "$wrk/8-consensus/jobsCreated.success");

    #
    #  Check that consensus finished properly
    #
    my $failedJobs = 0;

    open(CGWIN, "ls $cgwDir/$asm.cgw_contigs.* |") or caFailure("ls of $cgwDir/$asm.cgw_contigs.* failed.\n");
    while (<CGWIN>) {
        chomp;

        if (m/cgw_contigs.(\d+)/) {
            if ((-e "$wrk/8-consensus/$asm.cns_contigs.$1.failed") ||
                ((! -z $_) && (! -e "$wrk/8-consensus/$asm.cns_contigs.$1.success"))) {
                print STDERR "$wrk/8-consensus/$asm.cns_contigs.$1 failed.\n";
                $failedJobs++;
            }
        } else {
            print STDERR "WARNING: didn't match $_ for cgw_contigs filename!\n";
        }
    }
    close(CGWIN);

    caFailure("$failedJobs consensusAfterScaffolder jobs failed.  Good luck.\n") if ($failedJobs);

    touch("$wrk/8-consensus/consensus.success");

  alldone:
    stopAfter("consensusAfterScaffolder");
}

1;
