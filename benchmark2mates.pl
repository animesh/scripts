#!/usr/local/bin/perl

use strict;

use TIGR::Foundation;
use AMOS::AmosLib;

my $ID = 1;

my $base = new TIGR::Foundation;

if (! defined $base){ 
    die("Ouch\n");
}

my $VERSION = '1.0 ($Revision: 1.3 $)';
$base->setVersionInfo($VERSION);

my $HELP = q~
    benchmark2mates -o <outprefix> [-C] fasta1 fasta2 ... fastan 

<outprefix>  - prefix for the resulting .mates file.  Required.
-C           - generate Bambus <outprefix>.conf file
    ~;
$base->setHelpInfo($HELP);

my $outfname;
my $doConf;
my $err = $base->TIGR_GetOptions("o=s" => \$outfname,
				 "C" => \$doConf);
if ($err == 0) {
    $base->bail("Command line processing failed\n");
}

my %clones;
my %seqs;
my %seqId;
my %lib ;
my %clr;

if (! defined $outfname) {
    $base->bail("You must provide an output prefix\n");
}

my $matename = "$outfname.mates";
my $conffile = "$outfname.conf";

if (defined $doConf){
    open(CONF, ">$conffile") || $base->bail("Cannot open $conffile: $!");
}
open(MATE, ">$matename") || $base->bail("Cannot open $matename: $!");

my %inserts; # inserts in a library
my %end3;    # insert end3
my %end5;    # insert end5
my %seenins;
for (my $f = 0; $f <= $#ARGV; $f++){
    my $sfname = $ARGV[$f];
    
    print STDERR "parsing $sfname\n";
    
    open(CSEQ, "$sfname") || $base->bail("Cannot open $sfname: $!");
    
    my ($frec, $fhead) = getFastaContent(\*CSEQ, undef);
    
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
	
	($frec, $fhead) = getFastaContent(\*CSEQ, undef);
	
	if (eof(CSEQ)){
	    print STDERR "found end of seq file\n";
	    $frec .= $fhead;
	    $fhead = undef;
	}
	
	my $recId = getId();
	
	$seqId{$fid} = $recId;
	
	print STDERR "$recId\r";
    } # while $fhead
} # for each file

print STDERR "done\n";
close(CSEQ);

print STDERR "doing mates\n";


open(LIB, "library.info") || $base->bail("Cannot open library.info: $!\n");

while (<LIB>){
    if (/^\#/){
	next;
    }

    my @fields = split('\t', $_);

    my $lib = $fields[0];
    my $mea = $fields[1];
    my $std = $fields[2];
    
    my $minlib = $mea - 3 * $std; 
    if ($minlib < 0 ) {$minlib = 0;}
    
    my $maxlib = $mea + 3 * $std;

    if ($mea == 0){
	next;
    }

    my $dstId = getId();

    if (defined $doConf){
	print CONF "priority lib_$dstId 1\n";
	print CONF "overlaps lib_$dstId Y\n";
    }
    print MATE "library\t$dstId\t$minlib\t$maxlib\n";
    
    my @insert = split(' ', $inserts{$lib});

    for (my $ii = 0; $ii <= $#insert; $ii++){
	if (! exists $end5{$insert[$ii]} ||
	    ! exists $end3{$insert[$ii]}){
	    next;
	}

	print MATE "$end5{$insert[$ii]}\t$end3{$insert[$ii]}\t$dstId\n";
    }
} 

if (defined $doConf){
    print CONF "mingroupsize 0\n";
    print CONF "redundancy 2\n";
    close(CONF);
}
close(LIB);
print STDERR "done\n";

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

sub getId
{
    return $ID++;
}

