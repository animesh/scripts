#!/usr/local/bin/perl

my $BASEDIR = "/local/asmg/work/mpop/WGA/";
my $BINDIR  = $BASEDIR . "bin/";

$trim       = $BINDIR . "trimends";
$grep       = "/bin/grep";


$infile = $ARGV[0];

$inittime = time();
$time = time();
print "###Doing prelimnary trimming\n";
system("$trim $infile");
($sec, $min, $hour, $day) = gmtime(time() - $time); $day--;
print "###finished trimming in $day days $hour:$min:$sec\n";
if (! -s "${infile}_trimmed.qc"){
    die ("trimming ($trim $infile) appears to have failed\n");
}

$iter = 0;
do {
    $iter++;
    print "###Starting iteration $iter\n";
    $time = time();

    open(STAT, "$grep \"SeqsInBigContigs\" ${infile}_trimmed.qc |") ||
	die ("couldn't run $grep :$!\n");
    $_ = <STAT>;
    $_ =~ /=(\d+)$/;
    $startbases = $1;
    print "###we start with $startbases sequences in big contigs now\n";
    close(STAT);

    
    system("$trim ${infile}_trimmed");

    if (! -s "${infile}_trimmed_trimmed.qc"){
	die ("trimming appears to have failed\n");
    }

    open(STAT, "$grep \"SeqsInBigContigs\" ${infile}_trimmed_trimmed.qc |") ||
	die ("couldn't run $grep :$!\n");
    $_ = <STAT>;
    $_ =~ /=(\d+)$/;
    $endbases = $1;
    print "###we have $endbases sequences in big contigs now\n";
    close(STAT);
    
    $diff = 100.0 * ($endbases - $startbases) / $startbases;
    print "### the difference is $diff %\n";

    system("rm -rf ${infile}_trimmed.*");

    @copyprefixes = ("qc", "seq", "qual", "frg", "contig", "fasta", "tasm", "asm");
    for ($i = 0; $i <= $#copyprefixes; $i++){
	rename("${infile}_trimmed_trimmed.$copyprefixes[$i]", 
	       "${infile}_trimmed.$copyprefixes[$i]") ||
		   die ("Cannot rename ${infile}_trimmed_trimmed.$copyprefixes[$i]: $!\n");
    }

    system("rm -rf ${infile}_trimmed_trimmed.*");

    ($sec, $min, $hour, $day) = gmtime(time() - $time); $day--;
    print "###iteration $iter finished in $day days $hour:$min:$sec\n";
    ($sec, $min, $hour, $day) = gmtime(time() - $inittime); $day--;
    print "###total elapsed time: $day days $hour:$min:$sec\n";
} until ($diff < 1);

