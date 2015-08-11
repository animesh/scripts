use strict;

sub runMeryl ($$$$) {
    my $merSize   = shift @_;
    my $merComp   = shift @_;
    my $merThresh = shift @_;
    my $merType   = shift @_;
    my $cmd;

    if (getGlobal("doMeryl") == 0) {
        touch "$wrk/0-mercounts/$asm.nmers.$merType.fasta";
        return;
    }

    if (merylVersion() eq "Mighty") {

        #  Use the better meryl!  This is straightforward.  We count,
        #  then we dump.

        if (! -e "$wrk/0-mercounts/$asm-ms$merSize-cm$merComp.mcdat") {
            my $merylMemory = getGlobal("merylMemory");

            $cmd .= "$bin/meryl ";
            $cmd .= " -B -C -v -m $merSize -memory $merylMemory -c $merComp ";
            $cmd .= " -s $wrk/$asm.gkpStore ";
            $cmd .= " -o $wrk/0-mercounts/$asm-ms$merSize-cm$merComp ";
            $cmd .= "> $wrk/0-mercounts/meryl.out 2>&1";

            if (runCommand("$wrk/0-mercounts", $cmd)) {
                caFailure("Failed.\n");
            }
        }

        if (! -e "$wrk/0-mercounts/$asm.nmers.$merType.fasta") {
            $cmd  = "$bin/meryl ";
            $cmd .= "-Dt -n $merThresh ";
            $cmd .= "-s $wrk/0-mercounts/$asm-ms$merSize-cm$merComp ";
            $cmd .= "> $wrk/0-mercounts/$asm.nmers.$merType.fasta ";

            if (runCommand("$wrk/0-mercounts", $cmd)) {
                unlink "$wrk/0-mercounts/$asm.nmers.$merType.fasta";
                caFailure("Failed.\n");
            }
        }
    } elsif (merylVersion() eq "CA") {

        #  Sigh.  The old meryl.  Not as easy.  If we assume the
        #  process, in particular that the Ovl threshold is less than
        #  the Obt threshold, and that we have already computed the
        #  Ovl mers, we could filter the Ovl mers to get the Obt mers.
        #  But that's tough, especially if we allow mer compression.

        my $merSkip = 10;
        my $ofile = "$wrk/0-mercounts/$asm-ms$merSize-mt$merThresh-ms$merSkip.$merType.fasta";

        if ($merComp > 0) {
            print STDERR "ERROR!  merOverlap and merCompression not supported without\n";
            print STDERR "        installing kmer (http://sourceforge.net/projects/kmer/).\n";
            print STDERR "If you have installed kmer, then your build is broken, as I\n";
            print STDERR "did not find the correct 'meryl' (meryl -V should have said Mighty).\n";
            die;
        }

        if (! -e $ofile) {
            $merThresh /= $merSkip;

            $cmd  = "$bin/meryl ";
            $cmd .= "-s $wrk/$asm.gkpStore -m $merSize -n $merThresh -K $merSkip ";
            $cmd .= " -o $ofile";
            $cmd .= "> $wrk/0-mercounts/meryl.out 2>&1";

            if (runCommand("$wrk/0-mercounts", $cmd)) {
                unlink $ofile;
                caFailure("Failed.\n");
            }
        }

        if (! -e "$wrk/0-mercounts/$asm.nmers.$merType.fasta") {
            symlink("$ofile", "$wrk/0-mercounts/$asm.nmers.$merType.fasta");
        }
    } else {
        caFailure("Unknown meryl version.\n");
    }
}

sub meryl {
    system("mkdir $wrk/0-mercounts") if (! -d "$wrk/0-mercounts");

    my $ovlc = 0;
    my $obtc = 0;
    my $type = getGlobal("merOverlap");

    $ovlc = getGlobal("merCompression") if (($type eq "both") || ($type eq "ovl"));
    $obtc = getGlobal("merCompression") if (($type eq "both") || ($type eq "obt"));

    runMeryl(getGlobal('merSizeOvl'), $ovlc, getGlobal("merylOvlThreshold"), "ovl");
    runMeryl(getGlobal('merSizeObt'), $obtc, getGlobal("merylObtThreshold"), "obt");
}

1;
