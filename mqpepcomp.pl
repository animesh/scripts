use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $fpat = shift @ARGV;
my $i1 = shift @ARGV;

my @files=<$path/*$pat>;
my %mrna;
my %nc;
my %ir;
my %hp;
my %pepc;
my %pepcna;
my %pepc0;

print "FileColumn$i1\t";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    $fn=~s/$path|$pat|\///g;
    print "$fn-";
    open (F1, "$f1/$fpat") || die "can't open \"$f1/$fpat\": $!";
    while (my $line = <F1>) {
    chomp $line;
    $line =~ s/\r//g;
	$lcnt++;
	if($fpat=~/csv/){@tmp=parse_line(',',0,$line);}
	if($fpat=~/txt/){@tmp=parse_line('\t',0,$line);}
        if ($lcnt>1){
	    	my $key=$tmp[0].$f1;
		if($tmp[$i1]=~/[0-9]/){
			$mrna{$key}.="$tmp[$i1] ";
			$hp{$f1}+=$tmp[$i1]/(1+$tmp[$i1]);
			$ir{$f1}+=$tmp[$i1];
			$pepc{$f1}++;
		}
		elsif($tmp[$i1]==0){$mrna{$key}.="0";$pepc0{$f1}++;}
		else{$mrna{$key}.=$tmp[$i1];$pepcna{$f1}++;} 		
		$nc{$tmp[0]}++;
        }
    }
    if($pepc{$f1}&&$ir{$f1}){print 1-$pepc{$f1}/$ir{$f1},"-", $ir{$f1}/$pepc{$f1}/($ir{$f1}/$pepc{$f1}+1),"-",($hp{$f1}/$pepc{$f1}),"-";}
    print "$pepc{$f1}-$pepcna{$f1}-$pepc0{$f1}\t";
    close F1;
}
print "\n";

foreach my $g  (keys %nc){
    my $ocg;
    print "$g\t";
    foreach  my $f (@files){
	my $key=$g.$f;
	print "$mrna{$key}\t";
	if($mrna{$key}){$ocg++;}
    }
    print "$ocg\n";
}


__END__ 
/
perl mqpepcomp.pl /cygdrive/m/RAW/SS RES peptides.txt 36

perl mqpepcomp.pl /cygdrive/m/RAW/SS RES evidence.txt 49
