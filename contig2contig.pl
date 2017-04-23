#!/usr/local/bin/perl

print STDERR "Usage: contig2contig <seqfile> <contigfile> <outcontigfile>\n";
my @names;
open(FASTA, "$ARGV[0]") || die("Cannot open $ARGV[0]: $!\n");

while (<FASTA>){
    if (/>(\S+)/){
	push(@names, $1);
    }
}
close(FASTA);

open(CONTIG, "$ARGV[1]") || die ("Cannot open $ARGV[1]: $!\n");
open(OUT, ">$ARGV[2]") || die ("Cannot open $ARGV[2]: $!\n");
my $contig_id;
my $contig_len;
my $nseqs;
while (<CONTIG>){
    if (/^\s*$/){ # end of a contig
	close(TMP);
	print OUT "##$contig_id $nseqs $contig_len bases\n";
	open(TMP, "TMP") || die ("Cannot open TMP: $!\n");
	while (<TMP>){
	    print OUT;
	}
	close(TMP);
    } elsif (/^C (\d+)$/) {
	$contig_id = $1;
	$contig_len = 0;
	$nseqs = 0;
	open(TMP, ">TMP") || die ("Cannot open TMP: $!\n");
    } elsif (/^(\d+) (\d+) (\d+)/){
	my $id = $1;
	my $asml = $2;
	my $asmr = $3;
	my $seql; 
	my $seqr;
	my $seqlen;

	$nseqs++;
	if ($asml < $asmr){
	    $seql = 0;
	    $seqr = $seqlen = $asmr - $asml;
	} else {
	    $seql = $seqlen = $asml - $asmr;
	    $seqr = 0;
	    my $tmp = $asml;
	    $asml = $asmr;
	    $asmr = $tmp;
	}
	if ($contig_len < $asmr) {
	    $contig_len = $asmr;
	}
	print TMP "#$names[$id]($asml) $seqlen bases {$seql $seqr} <$asml $asmr>\n";
    }
}

close(TMP);
print OUT "##$contig_id $nseqs $contig_len bases\n";
open(TMP, "TMP") || die ("Cannot open TMP: $!\n");
while (<TMP>){
    print OUT;
}
close(TMP);

close(OUT);
close(CONTIG);
