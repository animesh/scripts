#!/usr/local/bin/perl

# Copyright (c) 2003, The Institute for Genomic Research (TIGR), Rockville,
# Maryland, U.S.A.  All rights reserved.

use TIGR::Foundation;

my $base = new TIGR::Foundation;
if (! defined $base){
    die("Ouch!\n");
}

my $VERSION = 'version 1.0 ($Revision: 1.1 $)';
$base->setVersionInfo($VERSION);

my $HELP = q~
    benchmark2ta -o <out_prefix> fasta1 fasta2 ... fastan

<out_prefix>  - prefix for the output files (<out_prefix>.seq and 
		<out_prefix>.qual).
    ~;

$base->setHelpInfo($HELP);

my $outprefix;
my $err = $base->TIGR_GetOptions("o=s" => \$outdir);

if ($err == 0) {
    $base->bail("Command line processing failed\n");
}

if (! defined $outprefix){ 
    $base->bail("You must set the output prefix with option -o \n");
}

my $seqname = "$outprefix.seq";
my $qualname = "$outprefix.qual";

my %mean;
my %stdev;

open(LIB, "library.info") || $base->bail("cannot open library.info: $!\n");

while (<LIB>){
    if (/^\#/) {
	next;
    }

    my @fields = split('\t', $_);
    $mean{$fields[0]} = $fields[1];
    $stdev{$fields[0]} = $fields[2];
}

close(LIB);

open(SEQ, ">$seqname") ||
    $base->bail("Cannot open $seqname: $!\n");

open(QUAL, ">$qualname") ||
    $base->bail("Cannot open $qualname: $!\n");

for (my $i = 0; $i <= $#ARGV; $i++){
    my $fname = $ARGV[$i];
    my $prefix;
    if ($fname =~ /(.*)\.seq$/) {
	$prefix = $1;
    } else {
	$base->bail("Sequence file ($fname) must end in .seq\n");
    }
    open(FASTA, "$fname") || 
	$base->bail("Cannot open $fname: $!\n");
    open(INQUAL, "$prefix.qual") || 
	$base->bail("Cannot open $prefix.qual: $!\n");
    
    my $rec;
    my $head;
    my $sequence;
    my $id;
    my $clipl;
    my $clipr;
    my %clips;
    my $library;
    while (<FASTA>) {
	chomp;
	if (/^>/) {
	    # first we write what we already got
	    if ($sequence ne ""){
#		$sequence = substr($sequence, $clipl - 1, $clipr - $clipl + 1);
		print SEQ ">$id";

		my $libmin = $mean{$library} - 3 * $stdev{$library};
		my $libmax = $mean{$library} + 3 * $stdev{$library};
		if ($libmin < 0) {
		    $libmin = 0;
		}

		print SEQ " $libmin $libmax $mean{$library} $clipl $clipr\n";
		
		for (my $j = 0; $j < length($sequence); $j += 60){
		    print SEQ substr($sequence, $j, 60), "\n";
		}
		$sequence = "";
	    }

	    $head = $_;
	    $head =~ />(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\d+)\s(\d+)/;
	    
	    $id = $1;
	    $library = $2;
	    $clipl = $5;
	    $clipr = $6;
	    $clips{$id} = "$clipl,$clipr";
	} else {
	    $sequence .= $_;
	}

    }
    if ($sequence ne ""){
	$sequence = substr($sequence, $clipl - 1, $clipr - $clipl + 1);
	print SEQ ">$id";
	my $libmin = $mean{$library} - 3 * $stdev{$library};
	my $libmax = $mean{$library} + 3 * $stdev{$library};
	if ($libmin < 0) {
	    $libmin = 0;
	}
	
	print SEQ " $libmin $libmax $mean{$library} $clipl $clipr\n";
	for (my $j = 0; $j < length($sequence); $j += 60){
	    print SEQ substr($sequence, $j, 60), "\n";
	}
    }
    close(FASTA);
    
    my @qualval = ();
    while (<INQUAL>){
	chomp;
	if (/>(\S+)/){
	    if ($#qualval >= 0){
		print QUAL ">$id\n";
#		@qualval = @qualval[($clipl - 1) .. ($clipr - 1)];
		for (my $j = 0; $j <= $#qualval; $j += 18){
		    if ($j + 18 > $#qualval) {
			print QUAL join(" ", @qualval[$j .. $#qualval]), "\n";
		    } else {
			print QUAL join(" ", @qualval[$j .. $j + 17]), "\n";
		    }
		}
	    }
	    

	    $id = $1;
	    if (exists $clips{$id}){
		($clipl, $clipr) = split(',', $clips{$id});
	    } else {
		$base->bail("Cannot find sequence record for quality $id\n");
	    }
	    @qualval = ();
	} else {
	    push(@qualval, split(' ', $_));
	}
    }
    if ($#qualval >= 0){
	print QUAL ">$id\n";
#	print "clipping $id at $clipl, $clipr\n";
#	@qualval = @qualval[($clipl - 1) .. ($clipr - 1)];
#	print "$id has ", $#qualval + 1, " entries\n";
	for (my $j = 0; $j <= $#qualval; $j += 18){
	    if ($j + 18 > $#qualval) {
		print QUAL join(" ", @qualval[$j .. $#qualval]), "\n";
	    } else {
		print QUAL join(" ", @qualval[$j .. $j + 17]), "\n";
	    }
	}
    }

    close(INQUAL);
}
print XMLOUT "</trace_volume>\n";
close(XMLOUT);
close(SEQ);
close(QUAL);

exit(0);
