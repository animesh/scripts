use strict;
use Text::ParseWords;
my %bh;
my %bhn;

my $f1 = shift;
my $bp = shift;
my $gn = shift;

my $f2 = shift;
my $gnc = shift;
my $scc = shift;
my %score;

open (F1, $f1) || die "can't open \"$f1\": $!";
my $lc;
while (my $line = <F1>) {
	$lc++;
	$line =~ s/\r//g;
	$line =~ s/\'//g;
	chomp $line;
	my @tmp1=parse_line('\t',0,$line);
	my @tmp2=split(/\,/,$tmp1[$gn]);
	$bhn{$tmp1[$bp]}++;
	for(my $c=0;$c<=$#tmp2;$c++){
		$tmp2[$c] =~ s/\s+//g;
		#if ($tmp2[$c]=~/^[0-9]/){
		if ($tmp2[$c] ne ""){
			$bh{$tmp1[$bp]}.="$tmp2[$c],";
		}
	}
}
close F1;

open (F2, $f2) || die "can't open \"$f2\": $!";
while (my $line = <F2>) {
	$line =~ s/\r//g;
	$line =~ s/\'//g;
	chomp $line;
	my @tmp=parse_line('\t',0,$line);
	$score{$tmp[$gnc]}=$tmp[$scc]+0;
}
close F2;


my $fon="$f1.$bp.$gn.$f2.$gnc.$scc.txt";
$fon=~s/\s+|\-|\,|\'|\/|\\//g;
open (FO, ">$fon") || die "can't open \"$fon\": $!";
print FO"$f1-$bp-$gn\t$f2-$gnc-$scc\n";

foreach my $ncc (keys %bh){
	my @tmp=split(/\,/,$bh{$ncc});
	my %hold=();
	@tmp = grep { ! $hold{$_} ++ } @tmp;
	my ($sum,$cnt,$avg)=(0,1,0);
	for(my $c=0;$c<=$#tmp;$c++){
		if($score{$tmp[$c]}>0){
			$sum+=$score{$tmp[$c]};
			$cnt++;
		}
	}
	if($cnt>1 and $ncc=~/[A-Z]/i){
		$avg=$sum/($cnt-1);
		print FO"$ncc\t$avg\n";
	}
	
}
close FO;
print "Processed $f1\t $f2 -> $fon\n";

__END__

for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do for i in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*GN.txt ; do echo $i $j ; perl /cygdrive/c/Users/animeshs/misccb/extractgnipa.pl  $j 0 4 $i 0 27 ; done ; done
for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do for i in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*GN.txt ; do echo $i $j ; perl /cygdrive/c/Users/animeshs/misccb/extractgnipa.pl  $j 0 4 $i 0 28 ; done ; done
for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do for i in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*GN.txt ; do echo $i $j ; perl /cygdrive/c/Users/animeshs/misccb/extractgnipa.pl  $j 0 4 $i 0 47 ; done ; done
for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do for i in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*GN.txt ; do echo $i $j ; perl /cygdrive/c/Users/animeshs/misccb/extractgnipa.pl  $j 0 4 $i 0 48 ; done ; done

for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do echo $j ; perl extractgnipa.pl $j 0 4;   done


perl extractgnipa.pl /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/Unstim-all-S1.txt 0 4 /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/UnstimallSequestcutoff1c.txt 0 1

cd /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil
for j in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.txt ; do echo $j ; perl extractgnipa.pl $j 0 4;   done
for i in /cygdrive/l/Qexactive/Berit_Sissel/B005/Bodil/*-all-*.0.4.csv; do echo $i; sort $i | uniq -ic | awk '{print $2","$1}' > $i.sort ; done
for j in *sort ; do for i in *cutoff1c.csv ; do echo $i $j ; perl /cygdrive/c/Users/animeshs/misccb/matchlist.pl $j $i > $j.$i.ml.csv ; done ; done
for i in *.csv.ml.csv; do echo $i ; awk -F"," '{x+=$6;n++}END{print x/n}' $i ; done >> combo.tab
