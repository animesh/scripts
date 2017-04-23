use strict;
use warnings;
use Text::ParseWords;

my @files=<*mpileup.txt>;
my @filesb=<*mpileup.base.txt>;
my @filesq=<*mpileup.qual.txt>;
my %id;
my %idc;
my %ids;
my %cc;
my %ccb;
my %ccq;
my $cnt;

print "Seq-Pos-Nuc\t";
for($cnt=0;$cnt<=$#files;$cnt++){
    my $f1=$files[$cnt];
    my $fb=$filesb[$cnt];
    my $fq=$filesq[$cnt];
    print "$f1\t";
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    open (F1, $f1) || die "can't open \"$f1\": $!";
    open (FB, $fb) || die "can't open \"$fb\": $!";
    open (FQ, $fq) || die "can't open \"$fq\": $!";
    while (my $line = <F1>) {
        chomp $line;
        $line =~ s/\r|\`|\"|\'/ /g;
        $lcnt++;
    	@tmp=parse_line('\t',0,$line);
    	my $idi="$f1-$tmp[0]-$tmp[1]-$tmp[2]";
	$id{$idi}.="$tmp[3]";
	$idc{$idi}++;
	$cc{"$tmp[0]-$tmp[1]-$tmp[2]"}+=$tmp[3];
	$ids{"$tmp[0]-$tmp[1]-$tmp[2]"}++;
    }
    close F1;
    while (my $line = <FB>) {
        chomp $line;
        $line =~ s/\r|\`|\"|\'/ /g;
    	@tmp=parse_line('\t',0,$line);
	$ccb{"$tmp[0]-$tmp[1]-$tmp[2]"}.="$tmp[3]";
    }
    close FB;
    while (my $line = <FQ>) {
        chomp $line;
        $line =~ s/\r|\`|\"|\'/ /g;
    	@tmp=parse_line('\t',0,$line);
	$ccq{"$tmp[0]-$tmp[1]-$tmp[2]"}.="$tmp[3]";
    }
    close FQ;
}
print "Depth\tCount\n";


foreach my $g  (keys %ids){
	print "$g\t";
	for($cnt=0;$cnt<=$#files;$cnt++){
		my $f1="$files[$cnt]-$g";
		print "$id{$f1}\t";
	}
	print "$cc{$g}\t$ids{$g}\n";
}


__END__

perl /home/animeshs/misccb/mpileupcount.pl > base.txt
http://samtools.sourceforge.net/samtools.shtml
https://github.com/arq5x/bedtools2
http://www.broadinstitute.org/gatk/guide/topic?name=methods
http://genome.sph.umich.edu/wiki/BamUtil:_stats
http://bedtools.readthedocs.org/en/latest/content/tools/intersect.html
http://barcwiki.wi.mit.edu/wiki/SOPs/miningSAMBAM
http://biobits.org/samtools_primer.html

for i in *.bam ; do echo $i ; samtools mpileup -f tRNA.nrm  $i > $i.mpileup.all.txt ; done
less SL32553.fastq.gz.ca.fastq.sam.so.bam.mpileup.all.txt
for i in *.bam ; do echo $i ; samtools mpileup -f tRNA.nrm  $i | awk '{print $1"\t"$2"\t"$3"\t"$5}' > $i.mpileup.base.txt ; done
for i in *.bam ; do echo $i ; samtools mpileup -f tRNA.nrm  $i | awk '{print $1"\t"$2"\t"$3"\t"$6}' > $i.mpileup.qual.txt ; done
