#!/usr/local/bin/perl

use strict;

use AMOS::AmosLib;
use AMOS::AmosFoundation;
use AMOS::ParseFasta;
use XML::Parser;
use IO::Handle;

my $MINSEQ = 64;
my $MAXSEQ = 2048;

my $tag; # XML tag
my $library;
my $template;
my $clipl;
my $clipr;
my $mean;
my $stdev;
my $end;
my $seqId;

my %end5;
my %end3;
my %means;
my %stdevs;
my %inserts;
my %clr;

my $gzip = "gzip";

my $base = new AMOS::AmosFoundation;

if (! defined $base) {
    die ("Walk, do not run, to the nearest exit!\n");
}

#$base->setLogLevel(1);

my $VERSION = '1.0 ($Revision: 1.13 $)';
$base->setVersion($VERSION);

$base->setLogFile("tarchive2ca.log");
$base->setMihaiMode();

my $HELPTEXT = qq~
    tarchive2ca -o <out_prefix> [-c <clear_ranges>] [-l <libinfo>] fasta1 ... fastan
    
    <out_prefix> - prefix for the output files
    <clear_ranges> - file containing clear ranges for the reads.  If this file
    is provided, any sequence that does not appear in it is excluded
    from the output.
    <libinfo> - tab-delimited file of lib_id, mean, stdev
    fasta1 ... fastan - list of files to be converted.
           The program assumes that for each program called <file>.seq there
           is a <file>.qual and a <file>.xml.  
    ~;
$base->setHelpText($HELPTEXT);


my $outprefix;
my $clears;
my $ID = 1;
my $silent;
my $libfile;
my $err = $base->getOptions("o=s" => \$outprefix,
			    "c=s" => \$clears,
			    "i=i" => \$ID,
			    "l=s" => \$libfile,
			    "silent" => \$silent);
if ($err == 0) {
    $base->bail("Command line processing failed\n");
}

if (! defined $outprefix) {
    $base->bail("A prefix must be set with option -o\n");
}

my $xml = new XML::Parser(Style => 'Stream');
if (!defined $xml) {
    $base->bail("Cannot create an XML parser");
}


my %clones;
my %seqs;
my %seqId;
my %lib ;

if ($outprefix =~ /\.frg$/){
    $outprefix =~ s/\.frg$//;
}
my $fragname = "$outprefix.frg";
my $dstname = "$outprefix.dst";

open(FRAG, ">$fragname") || die ("Cannot open $fragname: $!");
open(DST, ">$dstname") || die ("Cannot open $dstname: $!");
printFragHeader(\*FRAG);

if (defined $libfile){
    open(LIB, $libfile) || die ("Cannot open $libfile: $!");
    while (<LIB>){
	chomp;
	if (/^(\S+)\t(\d+.?\d*)\t(\d+.?\d*)$/){
	    $means{$1} = $2;
	    $stdevs{$1} = $3;
	} else {
	    print STDERR "Cannot parse line $. of $libfile: $_\n";
	}
    }
    close(LIB);
}

for (my $f = 0; $f <= $#ARGV; $f++){
# for each file
#   read anciliary XML data
#   read the seq and qual files
    my $seqname = $ARGV[$f];
    my $qualname;
    my $xmlname;
    my $prefix;

    if ($seqname =~ /fasta\.(.*)(\.gz)?/){
	$prefix = $1;
    } elsif ($seqname =~ /(.*)\.seq(\.gz)?/){
	$prefix = $1;
    } else {
	$base->bail("Fasta file ($seqname) must be called either fasta.<file> or <file>.seq\n");
    }
    
    if (-e "qual.$prefix"){
	$qualname = "qual.$prefix";
    } elsif (-e "qual.$prefix.gz") {
	$qualname = "qual.$prefix.gz";
    } elsif (-e "$prefix.qual"){
	$qualname = "$prefix.qual";
    } elsif ( -e "$prefix.qual.gz") {
	$qualname = "$prefix.qual.gz";
    } else {
	$base->bail("Cannot find the quality file corresponding to $seqname");
    }

    if (-e "xml.$prefix"){
	$xmlname = "xml.$prefix";
    } elsif (-e "xml.$prefix.gz") {
	$xmlname = "xml.$prefix.gz";
    } elsif (-e "$prefix.xml"){
	$xmlname = "$prefix.xml";
    } elsif ( -e "$prefix.xml.gz") {
	$xmlname = "$prefix.xml.gz";
    } else {
	$base->bail("Cannot find the xml file corresponding to $seqname");
    }

    my $XML = new IO::Handle;

    if ($xmlname =~ /\.gz$/){
	open($XML, "$gzip -dc $xmlname |") ||
	    $base->bail("Cannot open $xmlname: $!\n");
    } else {
	open($XML, "$xmlname") ||
	    $base->bail("Cannot open $xmlname: $!\n");
    }

    $xml->parse($XML);

    close($XML);

    if (defined $clears){
	open(CLR, $clears) || $base->bail("Cannot open $clears: $!\n");
	while (<CLR>){
	    chomp;
	    my @fields = split(' ', $_);
	    $fields[0] =~ s/gnl\|ti\|//;
	    $clr{$fields[0]} = "$fields[1],$fields[2]";
	}
	close(CLR);
    }

    if ($seqname =~ /\.gz$/){
	open(SEQ, "$gzip -dc $seqname |") ||
	    $base->bail("Cannot open $seqname: $!\n");
    } else {
	open(SEQ, "$seqname") ||
	    $base->bail("Cannot open $seqname: $!\n");
    }
    
    if ($qualname =~ /\.gz$/){
	open(QUAL, "$gzip -dc $qualname |") ||
	    $base->bail("Cannot open $qualname: $!\n");
    } else {
	open(QUAL, "$qualname") ||
	    $base->bail("Cannot open $qualname: $!\n");
    }

    if (! defined $silent){
	print STDERR "Parsing $seqname and $qualname\n";
    }

    my $seqparse = new AMOS::ParseFasta(\*SEQ);
    my $qualparse = new AMOS::ParseFasta(\*QUAL, ">", " ");

    my $fhead; my $frec;
    my $qhead; my $qrec;
    while (($fhead, $frec) = $seqparse->getRecord()){
	my $qid;
	my $fid;
	my $fidname;

	($qhead, $qrec) = $qualparse->getRecord();
	$fhead =~ /^(\S+)/;
	$fid = $1;
	$qhead =~ /^(\S+)/;
	$qid = $1;
	if ($fid ne $qid) {
	    $base->bail("fasta and qual records have different IDs: $fid vs $qid\n");
	}
	
	if ($fhead =~ /^(\S+)\s+\d+\s+\d+\s+\d+\s+(\d+)\s+(\d+)/){
# if TIGR formatted, fetch the clear range
#	    print STDERR "got TIGR: $1 $2 $3\n";
	    my $l = $2;
	    my $r = $3;
	    $l--;
	    $fidname = $1;
	    $fid = $1;
	    if (defined $clears && ! exists $clr{$fid}){
		# clear range file decides which sequences stay and which go
		next;
	    }
	    # allow XML or clear file to override the clear range info
	    if (! exists $clr{$fid}) {
		$clr{$fid} = "$l,$r";
	    }
	} elsif ($fhead =~ /^gnl\|ti\|(\d+).* name:(\S+)/) {
#	    print STDERR "got ncbi: $1 $2\n";
	    # NCBI formatted using keywords
	    $fid = $1;
	    $fidname = $2;
	    if (defined $clears && 
		! exists $clr{$fid} && 
		! exists $clr{$fidname}) {
		# clear range file decides with sequences stay and which go
		$base->log("Couldn't find clear for $fid or $fidname\n");
		next;
	    }
	    if (exists $clr{$fidname} && ! exists $clr{$fid}) {
		$clr{$fid} = $clr{$fidname};
	    }
	} elsif ($fhead =~ /^ ?(\S+) ?(\S+)?/){
#	    print STDERR "got ncbi: $1 $2\n";
# NCBI formatted, first is the trace id then the trace name
	    $fid = $1;
	    $fidname = $2;

	    if (! defined $fidname || $fidname eq "bases"){
		$fidname = $fid;
	    }

	    if (defined $clears && 
		! exists $clr{$fid} && 
		! exists $clr{$fidname}) {
		$base->log("Couldn't find clear for $fid or $fidname\n");
		# clear range file decides which sequences stay and which go
		next;
	    }
	    if (exists $clr{$fidname} && ! exists $clr{$fid}) {
		$clr{$fid} = $clr{$fidname};
	    }
	} # done parsing head


	my $recId = getId();

	my $seqlen = length($frec);
	$qrec =~ s/^ //;
	my @quals = split(/ +/, $qrec);
	if ($#quals + 1 != $seqlen) {
	    $base->bail("Fasta and quality for $fid($fidname) disagree: $seqlen vs " . sprintf("%d\n", $#quals + 1));
	}

	my $caqual = "";
	for (my $q = 0; $q <= $#quals; $q++){
	    my $qv = $quals[$q];
	    if ($qv > 60) {
		$qv = 60;
	    }
	    
	    $caqual .= chr(ord('0') + $qv);
	}
	
	if (! defined $silent && ($recId % 100 == 0)){
	    print STDERR "$recId\r";
	}
	
	if (! exists $clr{$fid}){
	    $clr{$fid} = "0,$seqlen";
	}

	$seqId{$fidname} = $recId;

	my $seq_lend;
	my $seq_rend;

	($seq_lend, $seq_rend) = split(',', $clr{$fid});

	if ($seqlen > $MAXSEQ){
	    $frec = substr($frec, 0, $seq_rend + 1);
	    $caqual = substr($caqual, 0, $seq_rend + 1);
	    $seqlen = length($frec);
	    if ($seqlen > $MAXSEQ){
		if (! defined $silent){
		    $base->log("skipping sequence $fidname due to length $seqlen\n");
		}
		delete $seqId{$fidname};
		next;
	    }
	}
	    if ($seq_rend - $seq_lend < $MINSEQ){
		if (! defined $silent){
		$base->log("skipping sequence $fidname since it's short\n");
	    }
	    delete $seqId{$fidname};
	    next;
	}

	print FRAG "{FRG\n";
	print FRAG "act:A\n";
	print FRAG "acc:$recId\n";
	print FRAG "typ:R\n";
	print FRAG "src:\n$fidname\n.\n";
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
	if ($seq_rend > $seqlen){
	    print "right end of clear range $seq_rend > $seqlen - shrinking it\n";
	    $seq_rend = $seqlen;
	}
	print FRAG ".\n";
	print FRAG "clr:$seq_lend,$seq_rend\n";
	print FRAG "}\n";
    } # while $fhead
    
    if (! defined $silent){
	print STDERR "done\n";
    }
    close(SEQ);
    close(QUAL);
}

if (! defined $silent){
    print STDERR "doing mates\n";
}
my %seentem;

while (my ($lib, $mean) = each %means){
    if ($#{$inserts{$lib}} == -1){
	next; # nothing to see here
    }

    my $dstId = getId();

    print DST "$dstId\t$lib\t$means{$lib} +/- $stdevs{$lib}\n";

    if ($stdevs{$lib} > $means{$lib} / 3){
	$stdevs{$lib} = int($means{$lib} / 3);
    }
    
    print FRAG "{DST\n";
    print FRAG "act:A\n";
    print FRAG "acc:$dstId\n";
    print FRAG "mea:$means{$lib}\n";
    print FRAG "std:$stdevs{$lib}\n";
    print FRAG "}\n";

    for (my $tem = 0 ; $tem <= $#{$inserts{$lib}}; $tem++){
	my $tmplte = ${$inserts{$lib}}[$tem];
        if (exists $seentem{$tmplte}){
	   next;
	}

	if (! exists $end5{$tmplte} ||
	    ! exists $end3{$tmplte} ||
	    ! exists $seqId{$end5{$tmplte}} ||
	    ! exists $seqId{$end3{$tmplte}}){
	    if (! defined $silent){
		$base->log("Template $tmplte ($tem) does not have both mates\n");
	    }
	} else {
            $seentem{$tmplte} = 1;
	    print FRAG "{LKG\n";
	    print FRAG "act:A\n";
	    print FRAG "typ:M\n";
	    print FRAG "fg1:$seqId{$end5{$tmplte}}\n";
	    print FRAG "fg2:$seqId{$end3{$tmplte}}\n";
	    print FRAG "etm:0\n";
	    print FRAG "dst:$dstId\n";
	    print FRAG "ori:I\n";
	    print FRAG "}\n";
	}
    }
}

if (! defined $silent){
    print STDERR "done\n";
}
close(FRAG);
close(DST);


exit(0);


sub StartDocument
{
    if (! defined $silent){
	print "starting\n";
    }
}

sub EndDocument
{
    if (! defined $silent){
	print "done\n";
    }
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
	    if (! defined $silent){
		$base->log("trace has no name???\n");
	    }
	}
	if (! defined $library){
	    if (! defined $silent){
		$base->log("trace $seqId has no library\n");
	    }
	}
        if (! defined $mean  &&  ! exists $means{$library}){
            if (! defined $silent){
                $base->log("library $library has no mean - replacing with 33333\n");
            }
            $means{$library} = 33333; 
            $mean = 33333;
        } else {
            if (defined $mean && ! exists $means{$library}){
                $means{$library} = $mean;
            } else {
                $mean = $means{$library};
            }
        }
        
        if (! defined $stdev  &&  ! exists $stdevs{$library}){
            if (! defined $silent){
                $base->log("library $library has no stdev - replacing with 10% of $mean\n");
            }
            $stdevs{$library} = $means{$library} * 0.1;
            $stdev = $means{$library} * 0.1;
        } else {
            if (! exists $stdevs{$library}){
                $stdevs{$library} = $stdev;
            } else {
                $stdev = $stdevs{$library};
            }
        }
	
	if (! defined $template){
	    if (! defined $silent){
		$base->log("trace $seqId has no template\n");
	    }
	} 
	
	if (! defined $end) {
	    if (! defined $silent){
		$base->log("trace $seqId has no end\n");
	    }
	}
	
	if ($end =~ /^R/i){
	    if (! exists $end3{$template} ||
		$seqId gt $end3{$template}){
		$end3{$template} = $seqId;
	    }
	}

	if ($end =~ /^F/i){
	    if (! exists $end5{$template} ||
		$seqId gt $end5{$template}){
		$end5{$template} = $seqId;
	    }
	}
	
	push (@{$inserts{$library}}, $template);
	
	if (defined $clipl && defined $clipr){
	    $clipr--;
	    if (! defined $clears) {$clr{$seqId} = "$clipl,$clipr";}
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
	    $seqId = $_;
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
		 $tag eq "clip_vector_left" ||
		 $tag eq "clip_left"){
	    if (! defined $clipl || $_ > $clipl){
		$clipl = $_;
	    }
	} elsif ($tag eq "clip_quality_right" ||
		 $tag eq "clip_vector_right" ||
		 $tag eq "clip_right"){
	    if (! defined $clipr || $_ < $clipr){
		$clipr = $_;
	    }
	}
    }
}

sub pi
{

}

sub printFragHeader
{
    my $file = shift;

    my $id = getId();

    print $file "{BAT\n";
    print $file "bna:Celera Assembler\n";
    print $file "crt:" . time() . "\n";
    print $file "acc:$id\n";
    print $file "com:\nDrosophila pseudoobscura\n.\n";
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

