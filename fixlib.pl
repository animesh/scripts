#!/usr/local/bin/perl

# fixlib.pl     - recomputes library sizes based on reads within contigs

use TIGR::Foundation;
use AMOS::AmosLib;
use XML::Parser;
use Statistics::Descriptive;

use strict;

my $BUCKETSIZE = 100;
my $MEANSTOP = 50;
my $SDSTOP = 50;

my $VERSION = '$Revision: 1.5 $ ';
my $HELP = q~
    fixlib (-m mates|-x traceinfo.xml|-f frg) 
           (-c contig|-a asm|-ta tasm|-ace ace) 
           [-circ] -o outfile 
           [-i insertfile] [-map dstmap]
~;

my $base = new TIGR::Foundation();
if (! defined $base) {
    die("A horrible death\n");
}


$base->setVersionInfo($VERSION);
$base->setHelpInfo($HELP);

my $matesfile;
my $traceinfofile;
my $ctgfile;
my $frgfile;
my $asmfile;
my $tasmfile;
my $acefile;
my $circular;
my $outfile;
my $insertfile;
my $libmap;

my $err = $base->TIGR_GetOptions("m=s"   => \$matesfile,
				 "x=s"   => \$traceinfofile,
				 "c=s"   => \$ctgfile,
				 "f=s"   => \$frgfile,
				 "a=s"   => \$asmfile,
				 "ta=s"  => \$tasmfile,
				 "ace=s" => \$acefile,
				 "circ"  => \$circular,
				 "o=s"   => \$outfile,
				 "i=s"   => \$insertfile,
				 "map=s" => \$libmap);


my $matesDone = 0;

# this is where all my data live
my %contigs;    # contig ids to contig length map
my %seqids;     # seq_name to seq_id map
my %seqnames;   # seq id to seq name map
my %seqcontig;  # seq id to contig map
my %contigseq;  # contig id to sequence id list 
my %seq_range;  # seq id to clear range
my %asm_range;  # seq id to range within contig
my %contigcons; # contig id to consensus sequence

my %forw;       # insert to forw (rev resp) end mapping 
my %rev; 
my %libraries;  # libid to lib range (mean, stdev) mapping
my %insertlib;  # lib id to insert list
my %seenlib;    # insert id to lib id map
my %seqinsert;  # sequence id to insert id map
my %libnames;   # lib id to lib name

my $minSeqId = 1;  # where to start numbering reads

my $outprefix;

#first get the contig information

if (! defined $outfile){
    $base->bail("You must specify an output file with option -o\n");
}
open(OUT, ">$outfile") || $base->bail("Cannot open $outfile: $!\n");

#then figure out the mates
if (defined $frgfile){
    open(IN, $frgfile) || $base->bail("Cannot open $frgfile: $!\n");
    parseFrgFile(\*IN);
    close(IN);
    $matesDone = 1;
}

if (defined $asmfile){
    $outprefix = $asmfile;
    open(IN, $asmfile) || $base->bail("Cannot open $asmfile: $!\n");
    parseAsmFile(\*IN);
    close(IN);
}

if (defined $ctgfile){
    $outprefix = $ctgfile;
    open(IN, $ctgfile) || $base->bail("Cannot open $ctgfile: $!\n");
    parseContigFile(\*IN);
    close(IN);
}

if (defined $tasmfile) {
    $outprefix = $tasmfile;
    open(IN, $tasmfile) || $base->bail("Cannot open $tasmfile: $!\n");
    parseTAsmFile(\*IN);
    close(IN);
}

if (defined $acefile){
    $outprefix = $acefile;
    open(IN, $acefile) || $base->bail("Cannot open $acefile: $!\n");
    parseACEFile(\*IN);
    close(IN);
}

$outprefix =~ s/\.[^.]*$//;

# now it's time for library and mates information

if (defined $traceinfofile){
    $matesDone = 1;
    open(IN, $traceinfofile) || $base->bail("Cannot open $traceinfofile: $!\n");
    parseTraceInfoFile(\*IN);
    close(IN);
}


if (! $matesDone && defined $matesfile) { # the mate file contains either mates
    # or regular expressions defining them
    open(IN, $matesfile) || 
	$base->bail("Cannot open \"$matesfile\": $!\n");
    parseMatesFile(\*IN);
    close(IN);
} # if mates not done defined matesfile

if (defined $insertfile){
    open(IN, $insertfile) || $base->bail("Cannot open $insertfile: $!\n");
    parseInsertFile(\*IN);
    close(IN);
}

if (defined $libmap){
    open(IN, $libmap) || $base->bail("Cannot open $libmap: $!\n");
    parseLibMapFile(\*IN);
    close(IN);
}


# now it's time to figure it all out.
# for each insert with a defined size range:
#   if both ends are in the same contig
#       add to library size array
#   if ends are in different contigs
#       add them to list of linking clones
#
# for each pair of contigs linked by clones do in order of insert sizes:
#   find the average insert size (assuming any size gap)
#   add the deviations to a deviation array for the library
#
# for all arrays, screen out observations outside SOME RANGE
# 
# for each library, compute a mean (based on inserts in the same contig) and
# a standard deviation (based on all inserts, both linking and within the same
# contig.
my $genomesize = 0;
while (my ($ctg, $len) = each %contigs){
    $genomesize += $len;
}

my $nsingle = 0;
my $nlinking = 0;
my $nori = 0;
my $nlen = 0;

my %percontig;
my %contigins;
my %insertlen;
my $it;

while (my ($lib, $sz) = each %libraries){
    my ($mean, $std) = split(" ", $sz);

    %percontig = ();
    %contigins = ();
    %insertlen = ();

    my $stat = Statistics::Descriptive::Full->new();

    if ($insertlib{$lib} =~ /^\s*$/){
	next; # empty library
    }

    my @inserts = split(' ', $insertlib{$lib});

    if (exists $libnames{$lib}){
	$lib = $libnames{$lib};
    }

    print STDERR ">$lib\n";

    print "library $lib\n";
    print "\tmean=$mean sd=$std\n"; 

    print OUT "[library_${lib}_initial]\n";
    print OUT "mean=$mean\n";
    print OUT "sd=$std\n";

    for (my $i = 0; $i <= $#inserts; $i++){
	my $ins = $inserts[$i];
	
	if (exists $forw{$ins} && exists $rev{$ins}){
	    if (! exists $seqcontig{$forw{$ins}} ||
		! exists $seqcontig{$rev{$ins}}) {
		$nsingle++;
		next; # if reads are not in contigs we don't care
	    }
#	    print "$seqnames{$forw{$ins}} $seqnames{$rev{$ins}}\n";
	    if ($seqcontig{$forw{$ins}} ne $seqcontig{$rev{$ins}}){
#		print "linking\n";
		$nlinking++;
		next; # ignore for now
	    }

	    print STDERR "seqcontig is $seqcontig{$forw{$ins}} - $seqcontig{$rev{$ins}}\n";

	    my $contiglen = $contigs{$seqcontig{$forw{$ins}}};
	    $percontig{$seqcontig{$forw{$ins}}}++;
	    $contigins{$seqcontig{$forw{$ins}}} .= "$ins ";
	    # here all the inserts have both mates in the same contig
	    my $f = $forw{$ins};
	    my $r = $rev{$ins};
	    my ($fl, $fr) = split(" ", $asm_range{$f});
	    my ($sfl, $sfr) = split(" ", $seq_range{$f});
	    my ($rl, $rr) = split(" ", $asm_range{$r});
	    my ($srl, $srr) = split(" ", $seq_range{$r});

	    print STDERR "$seqnames{$f} $fl $fr\n";
	    print STDERR "$seqnames{$r} $rl $rr\n";
	    
	    my $ef; # end of forward read
	    my $er; 
	    my $of; # orientation of forward read
	    my $or;
	    
	    if ($sfl < $sfr){
		$of = 1;
		$ef = $fl;
	    } else {
		$of = -1;
		$ef = $fr;
	    }

	    if ($srl < $srr){
		$or = 1;
		$er = $rl;
	    } else {
		$or = -1;
		$er = $rr;
	    }

	    if ($ef > $er){ # swap the values, keep forward toward the beggining of the contig
		my $tmp = $ef; $ef = $er; $er = $tmp;
		$tmp = $of; $of = $or; $or = $tmp;
	    }

	    if ($of == 1 && $or == -1){ # proper orientation
		$nlen++;
#		$stat->add_data($er - $ef);
		$insertlen{$ins} = $er - $ef;
		print STDERR "len $er $ef ", $er - $ef, "\n";
	    } elsif ($circular && $of == -1 && $or == 1){
		$nlen++;
#		$stat->add_data($ef + $contiglen - $er);
		$insertlen{$ins} = $ef + $contiglen - $er;
		print STDERR "len $er $ef $contiglen ", $ef + $contiglen - $er, "\n"; 
	    } else {
		$nori++;
	    }
	} else {
	    $nsingle++;
#	    print "ONE\n";
	}
    }  # for each insert

    
    while (my ($i, $l) = each %insertlen){
	$stat->add_data($l);
    }

    my $newmean;
    my $newstd;
    my $nout;
    if ($stat->count() < 2) {
	$newmean = 0;
	$newstd = 0;
	$nout = 0;
    } else {
	my ($low, $lowidx) = $stat->percentile(2);
	my ($high, $highidx) = $stat->percentile(98);
	
	my @data = $stat->get_data();
	print OUT "hist=<<EOH\n";
	print OUT join("\n", @data);
	print OUT "\nEOH\n";
	$nout = $lowidx + $#data - $highidx;
    
	$stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@data[$lowidx..$highidx]); # trim the outliers

	$newmean = $stat->mean();
	$newstd = $stat->standard_deviation();
    }
    print OUT "\n";
#    my $nprobm = $newmean;
#    my $nprobsd = $newstd;
    my $nartm = $newmean;
    my $nartsd = $newstd;
    my $artstat;
    my $artmean; my $artstd;
    for ($it = 0; $it <= 5; $it++){
#	my ($newestmean, $neweststd) = contigbyNum($newmean, $newstd);
#	my ($probmean, $probstd) = contigbyProb($nprobm, $nprobsd);
	
	($artmean, $artstd, $artstat) 
	    = contigbyArt($nartm, $nartsd, \@inserts);
	
	print ">$it\n";
	print "\tinserts all=", 
	$#inserts + 1, 
	" nomate=$nsingle linking=$nlinking ori=$nori len=$nout good=$nlen\n";
	printf("\tnewmean=%.2f newsd=%.2f\n", $stat->mean(), 
	       $stat->standard_deviation());
	printf("\t5mean=%.2f\n", $stat->trimmed_mean(0.05));
	printf("\tmin=%d max=%d median=%d\n", $stat->min(), $stat->max(), $stat->median());
#	printf("\tnewestmean=%.2f newestsd=%.2f\n", $newestmean, $neweststd);
#	printf("\tprobmean=%.2f probsd=%.2f\n", $probmean, $probstd);
	printf("\tartmean=%.2f artsd=%.2f\n", $artmean, $artstd);
	
#	my %dist = $stat->frequency_distribution(($stat->max() - $stat->min()) / 10);
#	for (sort {$a <=> $b} keys %dist){
#	    print STDERR "$_ $dist{$_}\n";
#	}
#	if ($newestmean != 0){
#	    $newmean = $newestmean;
#	    $newstd = $neweststd;
#	}
#	if ($probmean != 0) {
#	    $nprobm = $probmean;
#	    $nprobsd = $probstd;
#	}

	if ($artmean == 0 ||
	    (abs($artmean - $nartm) < $MEANSTOP &&
	     abs($nartsd - $artstd) < $SDSTOP)) {
	    last;
	}

	if ($artmean != 0){
	    $nartm = $artmean;
	    $nartsd = $artstd;
	}
    }

    print OUT "[library_${lib}_final]\n";
    print OUT "mean=$artmean\n";
    print OUT "sd=$artstd\n";
    if ($artmean != 0){
	print OUT "median=", $artstat->median(), "\n";
	my @data = $artstat->get_data();
	print OUT "hist=<<EOH\n";
	print OUT join("\n", @data);
	print OUT "\nEOH\n";
    }
    print OUT "\n";
    
} # for each library

close(OUT);

exit(0);




###############################################################################

sub contigbyNum
{
    my $inmean = shift;
    my $insd = shift;
    
    my $mean;
    my $sd;

    my $req_obs = ($insd / 500) ** 2;

    my $stat = Statistics::Descriptive::Full->new();
    
    while (my ($ctg, $nobs) = each %percontig){
	my $testlen = $inmean + 3 * $insd;
	my $ctglen = $contigs{$ctg};
	my $ratio = ($ctglen > $testlen) ? 1.0 * (($ctglen - $testlen) / $genomesize) : 0;
	$ratio /= ($nobs / ($nlinking + $nlen));
	if ($ratio > 0.95){
	    my @ins = split(' ', $contigins{$ctg});
	    for (my $i = 0; $i <= $#ins; $i++){
		if (exists $insertlen{$ins[$i]}){
		    $stat->add_data($insertlen{$ins[$i]});
		}
	    }
	}
	print STDERR "testmean $inmean testlen $testlen contigsize $ctglen ratio $ratio nobs = $nobs\n";
    }

    if ($stat->count() < $req_obs){
	print STDERR "num too few observations ", $stat->count(), " < $req_obs\n";
	return (0, 0);
    } else {
	my ($low, $lowidx) = $stat->percentile(2);
	my ($high, $highidx) = $stat->percentile(98);
	
	my @data = $stat->get_data();
	
	$stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@data[$lowidx..$highidx]); # trim the outliers
	return ($stat->mean(), $stat->standard_deviation());
    }
} # contigbyNum

sub contigbyProb
{
    my $inmean = shift;
    my $insd = shift;
    
    my $mean;
    my $sd;

    my $req_obs = ($insd / 500) ** 2;
    my $stat = Statistics::Descriptive::Full->new();
    
    while (my ($ctg, $nobs) = each %percontig){
	my $testlen = $inmean + 3 * $insd;
	my $ctglen = $contigs{$ctg};
	my $ratio = ($ctglen > $testlen) ? 1.0 * ($ctglen - $testlen) : 0;
	my $probsum = 0.0;
	for (my $l = 0; $l <$ctglen; $l++){
	    $probsum += 1.0 * ($ctglen - $l) * bell($inmean, $insd, $l);
	}
	$ratio /= $probsum;
	if ($ratio > 0.95){
	    my @ins = split(' ', $contigins{$ctg});
	    for (my $i = 0; $i <= $#ins; $i++){
		if (exists $insertlen{$ins[$i]}){
		    $stat->add_data($insertlen{$ins[$i]});
		}
	    }
	}
	print STDERR "Prob $ctg testmean $inmean testlen $testlen contigsize $ctglen ratio $ratio nobs = $nobs\n";
    }

    if ($stat->count() < $req_obs){
	print STDERR "prob too few observations ", $stat->count(), " < $req_obs\n";
	return (0, 0);
    } else {
	my ($low, $lowidx) = $stat->percentile(2);
	my ($high, $highidx) = $stat->percentile(98);
	
	my @data = $stat->get_data();
	
	$stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@data[$lowidx..$highidx]); # trim the outliers

	open(OUT, ">$outprefix.Prob.$it") || die ("cannot open $outprefix.Prob.$it: $!\n");
#	my %dist = $stat->frequency_distribution(($stat->max() - $stat->min()) / 1000);
#	for (sort {$a <=> $b} keys %dist){
#	    print OUT "$_ $dist{$_}\n";
#	}
	for (my $d = 0; $d <= $#data; $d++){
	    print OUT "$data[$d]\n";
	}
	close(OUT);


	return ($stat->mean(), $stat->standard_deviation());
    }
} # contigbyProb


sub contigbyArt
{
    my $inmean = shift;
    my $insd = shift;
    my $inserts = shift;
    
    my $req_obs = ($insd / 500) ** 2;
    $req_obs = ($req_obs > 10) ? $req_obs : 10; # pick at least ten
    
    my $stat = Statistics::Descriptive::Full->new();

    for (my $i = 0; $i <= $#$inserts; $i++){
	my $ins = $$inserts[$i];
	
	if (exists $forw{$ins} && exists $rev{$ins}){
	    if (! exists $seqcontig{$forw{$ins}} ||
		! exists $seqcontig{$rev{$ins}}) {
		next; # if reads are not in contigs we don't care
	    }
	    if ($seqcontig{$forw{$ins}} ne $seqcontig{$rev{$ins}}){
		next; # ignore for now
	    }

	    my $contiglen = $contigs{$seqcontig{$forw{$ins}}};
#	    $percontig{$seqcontig{$forw{$ins}}}++;
#	    $contigins{$seqcontig{$forw{$ins}}} .= "$ins ";
	    # here all the inserts have both mates in the same contig
	    my $f = $forw{$ins};
	    my $r = $rev{$ins};
	    my ($fl, $fr) = split(" ", $asm_range{$f});
	    my ($sfl, $sfr) = split(" ", $seq_range{$f});
	    my ($rl, $rr) = split(" ", $asm_range{$r});
	    my ($srl, $srr) = split(" ", $seq_range{$r});

	    my $ef; # end of forward read
	    my $er; 
	    my $of; # orientation of forward read
	    my $or;
	    
	    if ($sfl < $sfr){
		$of = 1;
		$ef = $fl;
	    } else {
		$of = -1;
		$ef = $fr;
	    }

	    if ($srl < $srr){
		$or = 1;
		$er = $rl;
	    } else {
		$or = -1;
		$er = $rr;
	    }

	    if ($ef > $er){ # swap the values, keep forward toward the beggining of the contig
		my $tmp = $ef; $ef = $er; $er = $tmp;
		$tmp = $of; $of = $or; $or = $tmp;
	    }

	    if ($of == 1 && $or == -1){ # proper orientation
		if (! $circular && ($ef + 3 * $insd > $contiglen ||
		    $er - 3 * $insd < 0)){ # skip inserts that could fall off
		    next;
		} else {
		    $stat->add_data($er - $ef);
		    if ($er < $ef) {
			print "Weird: $seqnames{$f} - $seqnames{$r}\n";
		    }
		}
	    } elsif ($circular && $of == -1 && $or == 1){
		$stat->add_data($ef + $contiglen - $er);
		if ($er > $contiglen) {
		    print "Weird c: $seqnames{$f} - $seqnames{$r}\n";
		}
	    }
	}
    }  # for each insert
    
    if ($stat->count() < $req_obs){
	print STDERR "too few observations ", $stat->count(), " < $req_obs\n";
	return (0, 0);
    } else {
	my ($low, $lowidx) = $stat->percentile(2);
	my ($high, $highidx) = $stat->percentile(98);
	
	my @data = $stat->get_data();
	
	$stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@data[$lowidx..$highidx]); # trim the outliers
	if ($stat->count() < $req_obs){
	    print STDERR "too few observations after trimming ", $stat->count(), " < $req_obs\n";
	    return (0, 0);
	}
	    
#	open(OUT, ">$outprefix.Art.$it") || die ("cannot open $outprefix.Art.$it: $!\n");
#	my %dist = $stat->frequency_distribution(($stat->max() - $stat->min()) / 1000);
#	for (sort {$a <=> $b} keys %dist){
#	    print OUT "$_ $dist{$_}\n";
#	}
#	for (my $d = 0; $d <= $#data; $d++){
#	    print OUT "$data[$d]\n";
#	}
#	close(OUT);

	return ($stat->mean(), $stat->standard_deviation(), $stat);
    }
}

sub bell
{
    my $mean = shift;
    my $sd = shift;
    my $x = shift;

    my $PI = 3.141592;

    return 1.0 / (sqrt(2 * $PI) * $sd) * exp(-($x - $mean) ** 2 / 2 / $sd ** 2);
} # bell

# LIBRARY NAME PARSING
sub parseInsertFile {
    my $IN = shift;

    while (<IN>){
	if (/GenomicLibrary Id=\"(\S+)\" acc=\"(\d+)\"/){
	    $libnames{$2} = $1;
	    print STDERR "lib-id = $2; lib-name = $1\n";
	}
    }
} # parseInsertFile

sub parseLibMapFile {
    my $IN = shift;

    while (<IN>){
	my ($name, $id) = split(' ', $_);
	$libnames{$id} = $name;
    }
}
# MATES PARSING FUNCTIONS

# parse Trace Archive style XML files
my $tag;
my $library;
my $template;
my $clipl;
my $clipr;
my $mean;
my $stdev;
my $end;
my $seqId;

sub parseTraceInfoFile {
    my $IN = shift;

    my $xml = new XML::Parser(Style => 'Stream');

    if (! defined $xml){
	$base->bail("Cannot create an XML parser");
    }

    # start parsing away.  The hashes will magically fill up

    $xml->parse($IN);

} # parseTraceInfoFile


# Celera .frg
# populates %seqids, %seqnames, and %seq_range, %libraries, %insertlib,
# %seenlib, %seqinsert
sub parseFrgFile {
    my $IN = shift;

    while (my $record = getRecord($IN)){
	my ($type, $fields, $recs) = parseRecord($record);
	if ($type eq "FRG") {
	    my $id = getCAId($$fields{acc});
	    my $nm = $$fields{src};
	    my @lines = split('\n', $nm);
	    $nm = join('', @lines);
	    if ($nm ne "" && $nm !~ /^\s*$/){
		$seqnames{$id} = $nm;
		$seqids{$nm} = $id;
	    }
	    my ($seql, $seqr) = split(',', $$fields{clr});
	    $seq_range{$id} = "$seql $seqr";
	    next;
	}
	
	if ($type eq "DST"){
	    my $id = getCAId($$fields{acc});
	    $libraries{$id} = "$$fields{mea} $$fields{std}";
	    next;
	}
	
	if ($type eq "LKG"){
	    my $id = $minSeqId++;
	    $insertlib{$$fields{dst}} .= "$id ";
	    $seenlib{$id} = $$fields{dst};
	    $seqinsert{$$fields{fg1}} = $id;
	    $seqinsert{$$fields{fg2}} = $id;
	    $forw{$id} = $$fields{fg1};
	    $rev{$id} = $$fields{fg2};
	    next;
	}
    }
} #parseFrgFile


# parses BAMBUS style .mates file
# * expects %seqids to be populated
# * populates %libraries, %forw, %rev, %insertlib, %seenlib, %seqinsert
sub parseMatesFile {
    my $IN = shift;

    my @libregexp;
    my @libids;
    my @pairregexp;
    my $insname = 1;
    while (<$IN>){
	chomp;
	if (/^library/){
	    my @recs = split('\t', $_);
	    if ($#recs < 3 || $#recs > 4){
		print STDERR "Only ", $#recs + 1, " fields\n";
		$base->logError("Improperly formated line $. in \"$matesfile\".\nMaybe you didn't use TABs to separate fields\n", 1);
		next;
	    }
	    
	    if ($#recs == 4){
		$libregexp[++$#libregexp] = $recs[4];
		$libids[++$#libids] = $recs[1];
	    }
	    my $mean = ($recs[2] + $recs[3]) / 2;
	    my $stdev = ($recs[3] - $recs[2]) / 6;
	    $libraries{$recs[1]} = "$mean $stdev";
	    next;
	} # if library
	if (/^pair/){
	    my @recs = split('\t', $_);
	    if ($#recs != 2){
		$base->logError("Improperly formated line $. in \"$matesfile\".\nMaybe you didn't use TABs to separate fields\n");
		next;
	    }
	    @pairregexp[++$#pairregexp] = "$recs[1] $recs[2]";
	    next;
	}
	if (/^\#/) { # comment
	    next;
	}
	if (/^\s*$/) { # empty line
	    next;
	}
	
	# now we just deal with the pair lines
	my @recs = split('\t', $_);
	if ($#recs < 1 || $#recs > 2){
	    $base->logError("Improperly formated line $. in \"$matesfile\".\nMaybe you didn't use TABs to separate fields\n");
	    next;
	}
	
# make sure we've seen these sequences
	if (! defined $seqids{$recs[0]}){
	    $base->logError("No contig contains sequence $recs[0] at line $. in \"$matesfile\"");
	    next;
	}
	if (! defined $seqids{$recs[1]} ){
	    $base->logError("No contig contains sequence $recs[1] at line $. in \"$matesfile\"");
	    next;
	}
	
	if (defined $recs[2]){
	    $insertlib{$recs[2]} .= "$insname ";
	    $seenlib{$insname} = $recs[2];
	} else {
	    $base->logError("$insname has no library\n");
	}
	
	$forw{$insname} = $seqids{$recs[0]};
	$rev{$insname} = $seqids{$recs[1]};
	
	$seqinsert{$seqids{$recs[0]}} = $insname;
	$seqinsert{$seqids{$recs[1]}} = $insname;
	
	$insname++;
    } # while <IN>

    # now we have to go through all the sequences and assign them to
    # inserts
    while (my ($nm, $sid) = each %seqids){
	for (my $r = 0; $r <= $#pairregexp; $r++){
	    my ($freg, $revreg) = split(' ', $pairregexp[$r]);
	    $base->logLocal("trying $freg and $revreg on $nm\n", 2);
	    if ($nm =~ /$freg/){
		$base->logLocal("got forw $1\n", 2);
		if (! exists $forw{$1}){
		    $forw{$1} = $sid;
		    $seqinsert{$sid} = $1;
		}
		last;
	    }
	    if ($nm =~ /$revreg/){
		$base->logLocal("got rev $1\n", 2);
		if (! exists $rev{$1}){
		    $rev{$1} = $sid;
		    $seqinsert{$sid} = $1;
		}
		last;
	    }
	} # for each pairreg
    } # while each %seqids
    
    while (my ($ins, $nm) = each %forw) {
	if (! exists $seenlib{$ins}){
	    my $found = 0;
	    
	    $nm = $seqnames{$nm};

	    for (my $l = 0; $l <= $#libregexp; $l++){
		$base->logLocal("Trying $libregexp[$l] on $nm\n", 2);
		if ($nm =~ /$libregexp[$l]/){
		    $base->logLocal("found $libids[$l]\n", 2);
		    $insertlib{$libids[$l]} .= "$ins ";
		    $seenlib{$ins} = $libids[$l];
		    $found = 1;
		    last;
		}
	    }
	    if ($found == 0){
		$base->logError("Cannot find library for \"$nm\"");
		next;
	    }
	}
    }
} # parseMateFile;


# CONTIG PARSING FUNCTIONS
#
# Each function parses either a file or a database table and
# fills in the following hashes:
# 
# %contigs - contig_ids and sizes
# %seqids - seq_name to seq_id
# %seqnames - seq_id to seq_name
# %seq_range - seq_id to seq_range 
# %asm_range - seq_id to asm_range as blank delimited string
# %seqcontig - seq_id to contig
# %contigcons - contig consensus for each contig



# Celera .asm
# populates %contigs, %asm_range, %seqcontig, %contigcons
# expects %seq_range to be populated
sub parseAsmFile {
    my $IN = shift;

    while (my $record = getRecord($IN)){
	my ($type, $fields, $recs) = parseRecord($record);
	if ($type eq "CCO"){
	    my $id = getCAId($$fields{acc});
	    my $contiglen = $$fields{len};

	    my @offsets; my $coord;

	    my $consensus = $$fields{cns};
	    my @consensus = split('\n', $consensus);
	    $consensus = join('', @consensus);
	    
	    $#offsets = length($consensus) - 1;

	    for (my $i = 0; $i < length($consensus); $i++){
		if (substr($consensus, $i, 1) ne "-"){
		    $coord++;
		} else {
		    $contiglen--;
		}
		$offsets[$i] = $coord;
	    }


#           my @gaps;
#	    while ($$fields{cns} =~ /-/g){
#		$contiglen--;
#		push(@gaps, $-[0]);
#	    }

	    $contigs{$id} = $contiglen;

#	    $contigcons{$id} = $consensus;
#	    $contigcons{$id} =~ s/-//g;

	    for (my $i = 0; $i <= $#$recs; $i++){
		my ($sid, $sfs, $srecs) = parseRecord($$recs[$i]);
		if ($sid eq "MPS"){
		    my $fid = getCAId($$sfs{mid});
		    my ($cll, $clr) = split(' ', $seq_range{$fid});
		    
		    $seqcontig{$fid} = $id;
		    $contigseq{$id} .= "$fid ";
		    
		    my ($asml, $asmr) = split(',', $$sfs{pos});
		    if ($asml > $asmr) {
			my $tmp = $cll;
			$cll = $clr;
			$clr = $tmp;
			$tmp = $asml;
			$asml = $asmr;
			$asmr = $tmp;
			$seq_range{$fid} = "$cll $clr";
		    }

		    $asml = $offsets[$asml]; $asml--;
		    $asmr = $offsets[$asmr - 1];

# 		    my $g = 0;
# 		    while ($g <= $#gaps && $gaps[$g] < $asml){
# 			$g++;
# 		    } 
# 		    $asml -= $g;
		    
# 		    while ($g <= $#gaps && $gaps[$g] < $asmr){
# 			$g++;
# 		    } 

# 		    $asmr -= $g;

		    $asm_range{$fid} = "$asml $asmr";
		}
	    }
	} # if type eq CCO
    }
} # parseAsmFile

# TIGR .asm
sub parseTAsmFile {
    my $IN = shift;

    my $ctg; 
    my $len;
    my $sname;
    my $alend;
    my $arend;
    my $slend;
    my $srend;
    my $sid;
    my $consensus;
    while (<$IN>){
	if (/^sequence\s+(\w+)/){
	    $len = length($1);
	    $consensus = $1;
	    next;
	}
	if (/^asmbl_id\s+(\w+)/){
	    $ctg = $1;
	    $contigs{$ctg} = $len;  # here we assume that length 
                                    # was already computed
#            $contigcons{$ctg} = $consensus;
	    next;
	}
	if (/^seq_name\s+(\S+)/){
	    $sname = $1;
	    if (! exists $seqids{$sname}){
		$sid = $minSeqId++;
		$seqids{$sname} = $sid;
		$seqnames{$sid} = $sname;
	    } else {
		$sid = $seqids{$sname};
	    }

	    $seqcontig{$sid} = $ctg;
	    $contigseq{$ctg} .= "$sid ";
	    next;
	}
	if (/^asm_lend\s+(\d+)/){
	    $alend = $1 - 1; # 0 based
	    next;
	}
	if (/^asm_rend\s+(\d+)/){
	    $arend = $1;
	    next;
	}
	if (/^seq_lend\s+(\d+)/){
	    $slend = $1 - 1;
	    next;
	}
	if (/^seq_rend\s+(\d+)/){
	    $srend = $1;
	    next;
	}
	if (/^offset/){
	    $seq_range{$sid} = "$slend $srend";
	    $asm_range{$sid} = "$alend $arend";
	    next;
	}
    }
} # parseTasmFile


# New .ACE format
sub parseACEFile {
    my $IN = shift;
    
    my $ctg; 
    my $len;
    my $sname;
    my $alend;
    my $arend;
    my $slend;
    my $srend;
    my $sid;

    my $inContig = 0;
    my $inSequence = 0;

    my $contigName;
    my $contigLen;
    my $contigSeqs;
    my $seqName;
    my %offset;
    my %rc;
    my $seq;
    my @gaps;
    while (<$IN>){
	if (/^CO (\S+) (\d+) (\d+)/){
	    $contigName = $1;
	    $contigLen = $2;
	    $contigSeqs = $3;
	    $inContig = 1;
	    $seq = "";
	    %offset = ();
	    next;
	}
	if ($inContig && /^\s*$/){
	    $inContig = 0;
	    $seq =~ s/\*/-/g;
	    @gaps = (); 
	    my $gap  = index($seq, "-");
	    while ($gap != -1){
		push(@gaps, $gap + 1);
		$gap = index($seq, "-", $gap + 1);
	    }
#	    $contigcons{$contigName} = $seq;
	    $contigs{$contigName} = $contigLen;
	    
	    next;
	}
	if ($inSequence && $_ =~ /^\s*$/){
	    $inSequence = 0;
	    next;
	}

	if ($inContig || $inSequence) {
	    chomp;
	    $seq .= $_;
	    next;
	}

	
	if (/^AF (\S+) (\w) (-?\d+)/){
	    $offset{$1} = $3;
	    $rc{$1} = $2;
	    next;
	}
	
	if (/^RD (\S+)/){
	    $inSequence = 1;
	    $seqName = $1;
	    $seq = "";
	    next;
	}

	if (/^QA -?(\d+) -?(\d+) (\d+) (\d+)/){
	    my $offset = $offset{$seqName};
	    my $cll = $3;
	    my $clr = $4;
	    my $end5 = $1;
	    my $end3 = $2;
	    $seq =~ s/\*/-/g;
	    my $len = length($seq);
	    $offset += $cll - 2;
	    $seq = substr($seq, $cll - 1, $clr - $cll + 1);
	    
	    my $i = 0;
	    my $asml = $offset;
	    my $asmr = $asml + $clr - $cll + 1;
	    while ($i <= $#gaps && $offset > $gaps[$i]){
		$asml--; $asmr--; $i++;
	    } # get rid of gaps from offset here
	    while ($i <= $#gaps && $offset + $clr - $cll + 1 > $gaps[$i]){
		$asmr--; $i++;
	    }

	    if ($rc{$seqName} eq "C"){ # make coordinates with respect to forw strand
		$cll = $len - $cll + 1;
		$clr = $len - $clr + 1;
		my $tmp = $cll;
		$cll = $clr;
		$clr = $tmp;
	    }

	    while ($seq =~ /-/g){ #make $clr ungapped
		$clr--;
	    }

	    if ($rc{$seqName} eq "C"){
		my $tmp = $cll;
		$cll = $clr;
		$clr = $tmp;
	    }
        
	    my $seqId;
	    if (! exists $seqids{$seqName}){
		$seqId = $minSeqId++;
		$seqids{$seqName} = $seqId;
		$seqnames{$seqId} = $seqName;
	    } else {
		$seqId = $seqids{$seqName};
	    }
	    $seqcontig{$seqId} = $contigName;
	    $contigseq{$contigName} .= "$seqId ";
	    $seq_range{$seqId} = "$cll $clr";
	    $asm_range{$seqId} = "$asml $asmr";
	    next;
	}
    } # while <$IN>
} #parseAceFile



# TIGR .contig file
sub parseContigFile {
    my $IN = shift;

    my $ctg; 
    my $len;
    my $sname;
    my $alend;
    my $arend;
    my $slend;
    my $srend;
    my $sid;
    my $incontig = 0;
    my $consensus = "";
    while (<$IN>){
	if (/^\#\#(\S+) \d+ (\d+)/ ){
	    if (defined $consensus){
		$consensus =~ s/-//g;
#		$contigcons{$ctg} = $consensus;
	    }
	    $consensus = "";
	    $ctg = $1;
	    $contigs{$ctg} = $2;
	    $incontig = 1;
	    next;
	}

	if (/^\#(\S+)\(\d+\) .*\{(\d+) (\d+)\} <(\d+) (\d+)>/){
	    $incontig = 0;
	    $sname = $1;
	    if (! exists $seqids{$sname}){
		$sid = $minSeqId++;
		$seqids{$sname} = $sid;
		$seqnames{$sid} = $sname;
	    } else {
		$sid = $seqids{$sname};
	    }
	    $seqcontig{$sid} = $ctg;
	    $contigseq{$ctg} .= "$sid ";
#	    print STDERR "adding $sname to $ctg\n";
	    $alend = $4 - 1;
	    $arend = $5;
	    $slend = $2 - 1;
	    $srend = $3;
	    $seq_range{$sid} = "$slend $srend";
	    $asm_range{$sid} = "$alend $arend";
	    next;
	}

	if ($incontig){
	    # here I try to get rid of dashes when computing contig sizes
	    my $ind = -1;
	    while (($ind = index($_ ,"-", $ind + 1)) != -1){
		$contigs{$ctg}--;
	    }
	    chomp;
	    $consensus .= $_;
	}
    }
    if (defined $consensus){
	$consensus =~ s/-//g;
#	$contigcons{$ctg} = $consensus;
    }

} # parseContigFile


###############################################################
# XML parser functions
###############################################################
sub StartDocument
{
#    print "starting\n";
}

sub EndDocument
{
#    print "done\n";
}

sub StartTag
{
    $tag = lc($_[1]);
    
    if ($tag eq "trace"){
        $library = undef;
        $template = undef;
        $clipl = undef;
        $clipr = undef;
        $mean = undef;
        $stdev = undef;
        $end = undef;
        $seqId = undef;
    }
}


sub EndTag
{
    $tag = lc($_[1]);
    if ($tag eq "trace"){
        if (! defined $seqId){
            $base->logError("trace has no name???\n");
        }
        if (! defined $library){
            $base->logError("trace $seqId has no library\n");
        }
        if (! defined $mean){
            $base->logError("library $library has no mean\n");
        } 
        
        if (! defined $stdev){
            $base->logError("library $library has no stdev\n");
        }

	if (defined $mean and defined $stdev){
	    $libraries{$library} = "$mean $stdev";
        }

        if (! defined $template){
            $base->logError("trace $seqId has no template\n");
        } 
        
        if (! defined $end) {
            $base->logError("trace $seqId has no end\n");
        }
        
        if ($end eq "R"){
            if (! exists $rev{$template} ||
                $seqnames{$seqId} gt $seqnames{$rev{$template}}){
                $rev{$template} = $seqId;
            }
        }
	 
        if ($end eq "F"){
            if (! exists $forw{$template} ||
                $seqnames{$seqId} gt $seqnames{$forw{$template}}){
                $forw{$template} = $seqId;
            }
        }
	    
	$seqinsert{$seqId} = $template;
	$insertlib{$library} .= "$template ";
	$seenlib{$template} = $library;
	
    
        if (defined $clipl && defined $clipr){
	    $seq_range{$seqId} = "$clipl $clipr";
        }
    }

    $tag = undef;
}


sub Text 
{
    if (defined $tag){
        if ($tag eq "insert_size"){
            $mean = $_;
        } elsif ($tag eq "insert_stdev"){
            $stdev = $_;
        } elsif ($tag eq "trace_name"){
            my $seqName = $_;
	    $seqId = $minSeqId++;
	    $seqids{$seqName} = $seqId;
	    $seqnames{$seqId} = $seqName;
        } elsif ($tag eq "library_id"){
            $library = $_;
        } elsif ($tag eq "seq_lib_id") {
            if (! defined $library) {
                $library = $_;
            }
        } elsif ($tag eq "template_id"){
            $template = $_;
        } elsif ($tag eq "trace_end"){
            $end = $_;
        } elsif ($tag eq "clip_quality_left" ||
                 $tag eq "clip_vector_left"){
            if (! defined $clipl || $_ > $clipl){
                $clipl = $_;
            }
        } elsif ($tag eq "clip_quality_right" ||
                 $tag eq "clip_vector_right"){
            if (! defined $clipr || $_ < $clipr){
                $clipr = $_;
            }
        }
    }
}

sub pi
{

}
