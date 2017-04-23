use strict;
use warnings;
use Text::ParseWords;

my $idi = 1;
my $i1 = 0;
my @files=<SL22?????.*hamr_mods.txt>;
my %id;
my %idc;
my %ids;
my %cc;

foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
        chomp $line;
        $line =~ s/\r|\`|\"|\'/ /g;
        $lcnt++;
    	@tmp=parse_line('\t',0,$line);
	$id{$tmp[$idi]}.="$tmp[$i1]\t";
	$idc{$tmp[$idi]}++;
	$cc{$tmp[$i1]}++;
	$ids{"$tmp[$idi]-$tmp[$i1]"}++;
    }
    close F1;
}

print "Seq-Pos-Strand\tCount\t";
foreach my $c  (keys %cc){
	print "$c\t";
}
print "Explicit\n";

foreach my $g  (keys %id){
    print "$g\t$idc{$g}\t";
    foreach my $c  (keys %cc){
        print "$ids{\"$g-$c\"}\t";
    }
    print "$id{$g}\n";
}


__END__

cd /cygdrive/l/Elite/gaute/Brede_111412_Raw_Fastq
perl /cygdrive/c/Users/animeshs/misccb/hamrcount.pl
