#!/usr/local/bin/perl

use strict;

use TIGR::Foundation;
use AMOS::AmosLib;

my $MINSEQ = 100;
my $MAXSEQ = 2048;
my $ID = 1;

my $base = new TIGR::Foundation;

if (! defined $base){ 
    die("Ouch\n");
}

my $VERSION = '1.0 ($Revision: 1.3 $)';
$base->setVersionInfo($VERSION);

my $HELP = q~
    benchmark2ca -o <outprefix> fasta1 fasta2 ... fastan

<outprefix>  - prefix for the resulting .frg file.  Required.
    ~;
$base->setHelpInfo($HELP);

my $outfname;
my $err = $base->TIGR_GetOptions("o=s" => \$outfname);
if ($err == 0) {
    $base->bail("Command line processing failed\n");
}

my %clones;
my %seqs;
my %seqId;
my %lib ;
my %clr;


# steps : generate .frg headers
# generate .frg FRG records
# generate .seq and .qual files
# add DST and LKG records to .frg file
my $fragname = "$outfname.frg";

#my $seqname = "$prefix.seq";
#my $qualname = "$prefix.qual";

open(FRAG, ">$fragname") || die ("Cannot open $fragname: $!");

printFragHeader(\*FRAG);

my %inserts; # inserts in a library
my %end3;    # insert end3
my %end5;    # insert end5
my %seenins;
for (my $f = 0; $f <= $#ARGV; $f++){
    my $sfname = $ARGV[$f];
    my $qfname;
    if ($sfname =~ /^(.*)\.seq$/){
	$qfname = "$1.qual";
    } else {
	$base->bail("File $sfname does not end in .seq\n");
    }
    
    print STDERR "parsing $sfname and $qfname\n";
    
    open(CSEQ, "$sfname") || die ("Cannot open $sfname: $!");
    open(CQUAL, "$qfname") || die ("Cannot open $qfname: $!");
    
    my ($frec, $fhead) = getFastaContent(\*CSEQ, undef);
    my ($qrec, $qhead) = getFastaContent(\*CQUAL, 1);
    
    while (defined $fhead){
	$fhead =~ />(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\d+)\s(\d+)/;
	my $fid = $1;
	my $l = $5 - 1; my $r = $6;
	my $lb = $2;
	my $ins = $3;
	my $dir = $4;
	
	$clr{$fid} = "$l,$r";
	if (! exists $seenins{$ins}){
	    $inserts{$lb} .= "$ins ";
	    $seenins{$ins} = 1;
	}
	
	if ($dir =~ /^R/){
	    if (! exists $end3{$ins} ||
		$end3{$ins} lt $fid){
		$end3{$ins} = $fid;
	    }
	} else {
	    if (! exists $end5{$ins} ||
		$end5{$ins} lt $fid){
		$end5{$ins} = $fid;
	    }
	}
	
	$qhead =~ />(\S+)/;
	my $qid = $1;
	
	if ($fid != $qid){
	    die ("fasta and qual records have different IDs: $fid vs $qid\n");
	}
	
	($frec, $fhead) = getFastaContent(\*CSEQ, undef);
	($qrec, $qhead) = getFastaContent(\*CQUAL, 1);
	
	if (! exists $clr{$fid}){
	    print "$fid has no clear range\n";
	    next;
	}
	
	if (eof(CSEQ)){
	    print STDERR "found end of seq file\n";
	    $frec .= $fhead;
	    $qrec .= " $qhead";
	    $fhead = undef;
	}
	
	my $seqlen = length($frec);
	if ($seqlen < $MINSEQ){
	    print STDERR "sequence is too short\n";
	    next;
	}
	my ($seq_lend, $seq_rend) = split(',', $clr{$fid});
	
	my $recId = getId();
	
	$seqId{$fid} = $recId;
	
	my @quals = split(' ', $qrec);
	if ($#quals + 1 != $seqlen) {
	    die ("\nFasta and quality disagree ($fid): $seqlen vs " . sprintf("%d", $#quals + 1) . "\n");
	}
	
	my $caqual = "";
	for (my $q = 0; $q <= $#quals; $q++){
	    my $qv = $quals[$q];
	    if ($qv > 60) {
		$qv = 60;
	    }
	    
	    $caqual .= chr(ord('0') + $qv);
	}
	
	print STDERR "$recId\r";
	
	if ($seqlen > $MAXSEQ){
	    $frec = substr($frec, 0, $seq_rend + 1);
	    $caqual = substr($caqual, 0, $seq_rend + 1);
	    $seqlen = length($frec);
	    if ($seqlen > $MAXSEQ){
		print STDERR "\nskipping sequence $fid due to length $seqlen\n";
		delete $seqId{$fid};
		next;
	    }
	}
	
	print FRAG "{FRG\n";
	print FRAG "act:A\n";
	print FRAG "acc:$recId\n";
	print FRAG "typ:R\n";
	print FRAG "src:\n$fid\n.\n";
	print FRAG "etm:0\n";
	print FRAG "seq:\n";
	$frec =~ s/[^actgnACTGN]/N/g;
	for (my $s = 0; $s < $seqlen; $s += 60){
	    print FRAG substr($frec, $s, 60), "\n";
	}
	print FRAG ".\n";
	print FRAG "qlt:\n";
	for (my $s = 0; $s < $seqlen; $s += 60){
	    print FRAG substr($caqual, $s, 60), "\n";
	}
	print FRAG ".\n";
	print FRAG "clr:$seq_lend,$seq_rend\n";
	print FRAG "}\n";
    } # while $fhead
} # for each file

print STDERR "done\n";
close(CSEQ);
close(CQUAL);

print STDERR "doing mates\n";


open(LIB, "library.info") ||
    die ("Cannot open library.info: $!\n");

while (<LIB>){
    if (/^\#/){
	next;
    }

    my @fields = split('\t', $_);

    my $lib = $fields[0];
    my $mea = $fields[1];
    my $std = $fields[2];

    if ($mea == 0){
	next;
    }

    my $dstId = getId();
    
    print FRAG "{DST\n";
    print FRAG "act:A\n";
    print FRAG "acc:$dstId\n";
    print FRAG "mea:$mea\n";
    print FRAG "std:$std\n";
    print FRAG "}\n";
    
    my @insert = split(' ', $inserts{$lib});

    for (my $ii = 0; $ii <= $#insert; $ii++){
	if (! exists $end5{$insert[$ii]} ||
	    ! exists $end3{$insert[$ii]}){
	    next;
	}

	print FRAG "{LKG\n";
	print FRAG "act:A\n";
	print FRAG "typ:M\n";
	print FRAG "fg1:$seqId{$end5{$insert[$ii]}}\n";
	print FRAG "fg2:$seqId{$end3{$insert[$ii]}}\n";
	print FRAG "etm:0\n";
	print FRAG "dst:$dstId\n";
	print FRAG "ori:I\n";
	print FRAG "}\n";
    }
} 

close(LIB);
print STDERR "done\n";
close(FRAG);


exit(0);


sub getFastaContent
{
    my $file = shift;
    my $isqual = shift;

    if (eof($file)){
	return undef;
    }

    $_ = <$file>;

    chomp;
    my $outline = "";

    while (! eof($file) && $_ !~ /^>/){
	if (defined $isqual){
	    $outline .= " ";
	}
	$outline .= $_;
	$_ = <$file>;
	chomp;
    }
    return ($outline, $_);
}

sub printFragHeader
{
    my $file = shift;

    my $id = getId();

    print $file "{BAT\n";
    print $file "bna:Celera Assembler\n";
    print $file "crt:" . time() . "\n";
    print $file "acc:$id\n";
    print $file "com:\n";
    for (my $i = 0; $i <= $#ARGV; $i++){
	print $file "$ARGV[$i]\n";
    }
    print $file ".\n";
    print $file "}\n";

    print $file "{ADT\n";
    print $file "{ADL\n";
    print $file "who:$ENV{USER}\n";
    print $file "ctm:" . time() . "\n";
    print $file "vsn:1.00\n";
    print $file "com:\nGenerated by cs2ca.pl\n.\n";
    print $file "}\n";
    print $file ".\n";
    print $file "}\n";
}

sub getId
{
    return $ID++;
}

