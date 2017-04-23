#!/usr/local/bin/perl

use DBI;
use POSIX;

my $query = qq~
    select s.seq_name, b.sequence, b.quality, f.end5, f.end3, 
    l.cat#, l.min_clone_len, l.max_clone_len, l.med_clone_len
    from sequence s, bases b, feature f, track..library l
    where 
      s.trash = null
      and s.latest_bases_id = b.id
      and f.seq_name = s.seq_name
      and f.feat_type = "CLR"
      and f.end3 - f.end5 >= 64
      and l.lib_id = substring(s.seq_name, 1, 4)
    ~;


open(SEQ, ">$ARGV[0].seq") || die ("Cannot open $ARGV[0].seq: $!\n");
open(QUAL, ">$ARGV[0].qual") || die ("Cannot open $ARGV[0].qual: $!\n");
open(XML, ">$ARGV[0].xml") || die ("Cannot open $ARGV[0].xml: $!\n");
print XML "<?xml version=\"1.0\"?>\n";
print XML "<trace_volume>\n";

$dbh = DBI->connect("dbi:Sybase:server=SYBTIGR;packetSize=8092", "access", "access");
if (! defined $dbh) {
    die ("Cannot connect to server\n");
}

$dbh->do("use $ARGV[0]");
$dbh->do("set textsize 12288");

my @regex;
my @dir;
my @type;
my $query_dirs = "select name, direction, read_type from primer_dir where read_type = \"RANDOM\"";

my $qh = $dbh->prepare($query_dirs) || die ("Cannot prepare $query_dirs\n");
$qh->execute() || die ("Cannot execute $query_dirs\n");

while (my @row = $qh->fetchrow()){
    my $reg = $row[0];
    $reg =~ s/_%/..*/;
    push(@regex, $reg);
    push(@dir, $row[1]);
    push(@type, $row[2]);
}


my $qh = $dbh->prepare($query) || die ("Cannot prepare $query");
$qh->execute() || die ("Cannot execute $query");

while (my @row = $qh->fetchrow())
{
    $nrows++;
    print SEQ ">$row[0] $row[6] $row[7] $row[8] $row[3] $row[4]\n" ;
    print XML " <trace>\n";
    print XML "  <trace_name>$row[0]</trace_name>\n";
    my $tem = substr($row[0], 0, 7);
    my $primer = substr($row[0], 7);
    my $seq_type;
    my $seq_end;

    for (my $i = 0; $i <= $#regex; $i++){
        if ($primer =~ /^${regex[$i]}$/){
		$seq_end = $dir[$i];
		$seq_type = "paired_production";
	}
    }

    if (! defined $seq_type){
	$seq_end = "N";
	$seq_type = "closure";
    }

    print XML "  <template_id>$tem</template_id>\n";
    print XML "  <trace_end>$seq_end</trace_end>\n";
    print XML "  <library_id>$row[5]</library_id>\n";

    my $insize = int(($row[6] + $row[7]) / 2);
    my $insd = int(($row[7] - $row[6]) / 6);

    print XML "  <insert_size>$insize</insert_size>\n";
    print XML "  <insert_stdev>$insd</insert_stdev>\n";
    print XML "  <type>$seq_type</type>\n";
    print XML " </trace>\n";
    my $line=1;
    
    my $line_len = length($row[1]);
    my $line_num = floor($line_len/60);
    
    my @seq_segs = unpack("A60" x $line_num, $row[1]);
    my $exclude = 60*$line_num;
    my $last_seg = unpack("x$exclude A*", $row[1]);
    
    if((defined $last_seg) && ($last_seg ne "")) {
	push @seq_segs, $last_seg;
    }
    
    my $qual_str = join("\n", @seq_segs);
    print SEQ "$qual_str\n";
    
    my $qual_len = length($row[2]);
    if ($qual_len == (4 * $line_len)) {
	my @hvals  = map hex, (unpack("A4" x $line_len, $row[2]));
	my $hval = undef;
	
	my $i = 0;
	for($i = 0 ; $i < scalar(@hvals) ; $i++) {
	    $hval = $hvals[$i];
	    if($hval > 60  || $hval < 0) {
		my $pos = $i*4;
		print STDERR "Warning: Bad quality value ($hval) for sequence $row[0] at position $pos (from 0).\n";
		$hval = 0;
	    }
	    $hvals[$i] = sprintf("%02d", $hval);
	}
	print QUAL ">$row[0]\n";
                 
	for (my $j = 0; $j <= $#hvals; $j += 17) {
	    print QUAL join(" ", @hvals[$j .. $j + 16]), "\n";
	}
    }
    $count_total_seqs++;
}

close(SEQ);
close(QUAL);
print XML "</trace_volume>\n";
close(XML);
exit(0);
