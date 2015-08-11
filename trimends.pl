#!/usr/local/bin/perl

my $BASEDIR  = "/local/asmg/work/mpop/WGA/";
my $BINDIR   = $BASEDIR . "bin/";

$findends    = $BINDIR . "find_ends";
$exclude     = $BINDIR . "excl_seqs";
$fixfrg      = $BINDIR . "fixfrg";
$vecfix      = $BINDIR . "vecfix";
$ovlps       = $BINDIR  . "tab2ovls";
$findsingles = $BINDIR . "singles";

$tasm        = "/usr/local/bin/run_TA";
$casm        = "/local/asmg/bin/run_CA";
$lucy        = "/usr/local/bin/lucy";
$lucyparms   = "-error 0.025 0.02 -window 50 0.03 5 0.01 -bracket 10 0.02";
$nucmum      = "/usr/local/bin/nucmer";
$show        = "/usr/local/bin/show-coords";
$blast       = "/usr/local/bin/blastall";
$format      = "/usr/local/bin/formatdb";
$getlens     = "/local/asmg/bin/getlengths";
$qc          = "/local/asmg/bin/caqc";
$grep        = "/bin/grep";
$cat         = "/bin/cat";

select STDOUT;
$| = 1;


$infile = $ARGV[0];

# run CA
if (! -f "$infile.seq" ||
    ! -f "$infile.qual" ||
    ! -f "$infile.frg"){
    die ("$infile.seq, $infile.qual, and $infile.frg must exist\n");
}

if (-f "$infile.contig"){
    print "$infile.contig exists, skipping first run of CA\n";
} else {
    print "running CA for the first time...";
    system("$casm $infile > ca.log 2>&1");
    print "done\n";
}


# run nucmummer
if (! -f "$infile.fasta"){
    die ("looks like CA died before creating $infile.fasta\n");
}

if (-s "$infile.coords"){
    print "$infile.delta exists, skipping nucmer\n";
} else {
    print "running nucmer db...";
    system("$nucmum -a max-match -p $infile $infile.fasta $infile.fasta");
    print "done\n";
    print "Running show-coords...";
    system("$show -HTcl $infile.delta > $infile.coords");
    print "done\n";
}

#find "grasta" ends
if (! -s "$infile.coords"){
    die ("looks like blast died before creating $infile.coords\n");
}

if (-s "$infile.ovlps"){
    print "$infile.ovlps exists, skipping overlap finding\n";
} else {
#    print "getting seq lens...";
#    system("$getlens $infile.fasta > $infile.lens");
#    print "done\n";
    print "finding overlaps...";
    system("$ovlps $infile.coords nuc tab > $infile.ovlps");
    print "done\n";
}

# find "end" sequences
if (! -s "$infile.ovlps"){
    die ("looks like $ovlps died before creating $infile.ovlps\n");
}

if (-s "$infile.excl"){
    print "$infile.excl exists, skipping the finding of end sequences\n";
} else {
    print "finding ends...";
    system("$findends $infile.contig $infile.ovlps> $infile.excl");
    print "done\n";
}

# find  singletons
if (! -s "$infile.excl"){
    die ("looks like ends were not found\n");
}

if (system ("$grep '^00000' $infile.excl") == 0){
    print "singletons were already found\n";
} else {
    print "finding singletons...";
    system("$findsingles $infile.contig $infile.seq >> $infile.excl");
    print "done\n";
}

# creating trimmable files
if (! -s "$infile.excl"){
    die ("looks like $findends died before creating $infile.excl");
}

if (-s "$infile.iseq"){
    print "$infile.iseq exists, skipping creation of trimmable files\n";
} else {
    print "excluding seq file...";
    system("$exclude $infile.seq $infile.excl > $infile.iseq");
    print "done\n";

    print "excluding qual file...";
    system("$exclude $infile.qual $infile.excl > $infile.iqual");
    print "done\n";

    print "creating trimmable seq file ...";
    system("$exclude $infile.seq $infile.excl include > $infile.eseq");
    print "done\n";
    
    print "creating trimmable qual file ...";
    system("$exclude $infile.qual $infile.excl include > $infile.equal");
    print "done\n";
}

# trimming
if (! -s "$infile.eseq"){
    die ("looks like trimmable files were not created\n");
}

if (-s "$infile.lseq"){
    print "$infile.lseq exists skipping trimming step\n";
} else {
    print "running lucy...";
    system("$lucy $lucyparms -output $infile.lseq $infile.lqual $infile.eseq $infile.equal");
    print "done\n";
}

# catting the files
if (! -s "$infile.lseq"){
    die ("looks like lucy died before creating $infile.lseq\n");
}

if (-s "${infile}_trimmed.seq"){
    print "${infile}_trimmed.seq exists, skipping file concatenation\n";
} else {
    print "fixing vector...";
    system("$vecfix $infile.lseq $infile.seq > $infile.vseq");
    print "done\n";
    print "cating files...";
    system("$cat $infile.iseq $infile.vseq> ${infile}_trimmed.seq");
    open(SEQS, "$grep \'>\' ${infile}_trimmed.seq |") ||
	die ("Cannot read ${infile}_trimmed.seq: $!\n");
    while (<SEQS>){
	if (/^>(\S+)/){
	    $seqname{$1} = 1;
	}
    }
    close(SEQS);

    system("cp $infile.iqual ${infile}_trimmed.qual");
    open(OUT, ">>${infile}_trimmed.qual") ||
	die ("Cannot append to ${infile}_trimmed.qual: $!\n");

    open(IN, "$infile.lqual") ||
	die ("Cannot open $infile.lqual: $!\n");
    
    $toout = 1;
    while (<IN>){
	if (/^>(\S+)/){
	    if (! exists $seqname{$1}){
		$toout = 0;
	    } else {
		$toout = 1;
	    }
	} 
	if ($toout == 1){
	    print OUT;
	}
    }
    close(IN);
    close(OUT);
    $seqname = ();

    print "done\n";
}

# updating the .frg file
if (! -s "${infile}_trimmed.seq"){
    die ("looks like catting failed\n");
}

if (-s "${infile}_trimmed.frg"){
    print "${infile}_trimmed.frg exists, skipping .frg file generation\n";
} else {
    print "fixing FRG file...";
    system("$fixfrg ${infile}_trimmed.seq $infile.frg > ${infile}_trimmed.frg");
    print "done\n";
}

# running the assembler again
if (! -s "${infile}_trimmed.frg"){
    die ("file ${infile}_trimmed does not exists\n");
}

if (-s "${infile}_trimmed.contig"){
    print "${infile}_trimmed.contig exists, skipping second CA\n";
} else {
    print "running CA for the second time...";
    system("$casm ${infile}_trimmed > ca.log 2>&1");
    print "done\n";
}

if (! -s "${infile}_trimmed.contig"){
    die ("Assembly failed\n");
}

# collecting stats
if (-s "${infile}_trimmed.qc"){
    print "${infile}_trimmed.qc exists, skipping QC step\n";
} else {
    print "Collecting statistics...";
    system("$qc ${infile}_trimmed.asm >/dev/null");
    print "done\n";
}

exit(0);
