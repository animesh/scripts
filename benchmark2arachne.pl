#!/usr/local/bin/perl

# Copyright (c) 2003, The Institute for Genomic Research (TIGR), Rockville,
# Maryland, U.S.A.  All rights reserved.

use TIGR::Foundation;
use TIGR::FASTAiterator;
use TIGR::FASTArecord;

my $base = new TIGR::Foundation;
if (! defined $base){
    die("Ouch!\n");
}

my $VERSION = 'version 1.0 ($Revision: 1.1 $)';
$base->setVersionInfo($VERSION);

my $HELP = q~
    benchmark2arachne -o <out_dir> -g <genomesize> fasta1 fasta2 ... fastan

<out_dir>    is the output directory given relative to $ARACHNE_DATA_DIR 
             (which must be set for this program to run)
<genomesize> is an estimate on the size of the genome being assembled. This
             parameter is also required.
    ~;

$base->setHelpInfo($HELP);

my $outdir;
my $genomesize;
my $err = $base->TIGR_GetOptions("o=s" => \$outdir,
				 "g=i" => \$genomesize);

if ($err == 0) {
    $base->bail("Command line processing failed\n");
}

if (! exists $ENV{ARACHNE_DATA_DIR}) {
    $base->bail("The environment variable ARACHNE_DATA_DIR must be set\n");
}

if (! defined $outdir){ 
    $base->bail("You must set the output directory with option -o \n");
}

if (! defined $genomesize){
    $base->bail("You must provide a genome size with option -g \n");
}

my $basedir = $ENV{ARACHNE_DATA_DIR};

# check that the relevant directories exist
if (! -d "$basedir/$outdir") {
    # output directory does not exist, make it
    mkdir("$basedir/$outdir") || 
	$base->bail("Cannot create directory $basedir/$outdir: $!\n");
}

my $seqdir = "$basedir/$outdir/fasta";
my $qualdir = "$basedir/$outdir/qual";
my $tracedir = "$basedir/$outdir/traceinfo";

if (! -d $seqdir) {
    # sequence directory does not exist, make it
    mkdir($seqdir) ||
	$base->bail("Cannot create directory $seqdir: $!\n");
}

if (! -d $qualdir) {
    # quality directory does not exist, make it
    mkdir($qualdir) ||
	$base->bail("Cannot create directory $qualdir: $!\n");
}

if (! -d $tracedir) {
    # trace directory does not exist make it
    mkdir($tracedir) ||
	$base->bail("Cannot create directory $tracedir: $!\n");
}

my $seqname = "$seqdir/$outdir.fasta";
my $qualname = "$qualdir/$outdir.qual";
my $tracename = "$tracedir/$outdir.xml";
my $sizename = "$basedir/$outdir/genome.size";
my $confname = "$basedir/$outdir/reads_config.xml";

my @errors;

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

open(SIZE, ">$sizename") ||
    $base->bail("Cannot open $sizename: $!\n");
print SIZE "$genomesize\n";
close(SIZE);

open(CONF, ">$confname") ||
    $base->bail("Cannot open $confname: $!\n");
print CONF 
q~<?xml version="1.0"?> 
<!DOCTYPE configuration SYSTEM "configuration.dtd">
<configuration>
      <rule> 
         <name> all reads are paired production reads </name> 
         <match>
            <match_field>trace_name</match_field>
            <regex>.</regex>
         </match> 
         <action> 
            <set>
               <set_field>type</set_field>
               <value>paired_production</value>
            </set> 
         </action> 
      </rule> 
</configuration>
    ~;
close(CONF);


open(SEQ, ">$seqname") ||
    $base->bail("Cannot open $seqname: $!\n");

open(QUAL, ">$qualname") ||
    $base->bail("Cannot open $qualname: $!\n");

open(XMLOUT, ">$tracename") ||
    $base->bail("Cannot open $tracename: $!\n");
    print XMLOUT "<?xml version=\"1.0\"?>\n";
    print XMLOUT "<trace_volume>\n";

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
    my %clips = ();
    while (<FASTA>) {
	chomp;
	if (/^>/) {
	    # first we write what we already got
	    if ($sequence ne ""){
		$sequence = substr($sequence, $clipl - 1, $clipr - $clipl + 1);
		print SEQ ">$id\n";
		for (my $j = 0; $j < length($sequence); $j += 60){
		    print SEQ substr($sequence, $j, 60), "\n";
		}
		$sequence = "";
	    }

	    $head = $_;
	    $head =~ />(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\d+)\s(\d+)/;
	    
	    $id = $1;
	    my $insert = $3;
	    my $library = $2;
	    $clipl = $5;
	    $clipr = $6;
	    $clips{$id} = "$clipl,$clipr";
	    my $dir = $4;
	    my $plate = substr($id, 0, 5);
	    my $well = substr($id, 5, 2); 
	    if ($dir =~ /^R/) {
		$dir = "R";
	    } else {
		$dir = "F";
	    }
	    
	    print XMLOUT " <trace>\n";
	    print XMLOUT "  <trace_name>$id</trace_name>\n";
	    print XMLOUT "  <plate_id>$plate</plate_id>\n";
	    print XMLOUT "  <well_id>$well</well_id>\n";
	    print XMLOUT "  <template_id>$insert</template_id>\n";
	    print XMLOUT "  <trace_end>$dir</trace_end>\n";
#	print XMLOUT "  <clip_quality_left>$clipl</clip_quality_left>\n";
#	print XMLOUT "  <clip_quality_right>$clipr</clip_quality_right>\n";
	    print XMLOUT "  <library_id>$library</library_id>\n";
	    print XMLOUT "  <insert_size>$mean{$library}</insert_size>\n";
	    print XMLOUT "  <insert_stdev>", int($stdev{$library}), "</insert_stdev>\n";
	    print XMLOUT "  <center_name>TIGR</center_name>\n";
	    print XMLOUT "  <type>paired_production</type>\n";
	    print XMLOUT " </trace>\n";
	} else {
	    $sequence .= $_;
	}

    }
    if ($sequence ne ""){
	$sequence = substr($sequence, $clipl - 1, $clipr - $clipl + 1);
	print SEQ ">$id\n";
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
		@qualval = @qualval[($clipl - 1) .. ($clipr - 1)];
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
	@qualval = @qualval[($clipl - 1) .. ($clipr - 1)];
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
