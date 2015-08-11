use strict;
use Text::ParseWords;
#use bigint;
use Math::BigInt;
use Math::BigFloat;
my %vh;
my %nh;
my $cntt;
my $chkcnt;
my $f1 = shift @ARGV;
my $id = shift @ARGV;
my $cat = shift @ARGV;
my $check = shift @ARGV;
if(!$cat){die "can't open \"$f1\": $! usage:perl category-counting.pl file-name id-column-number category--column-number";}
open(F1,$f1);
while (my $line = <F1>) {
	$line =~ s/\r//g;
	chomp $line;
		my @tmp=parse_line('\t',0,$line);
		$tmp[$cat]=~s/\s+//g;
		$tmp[$id]=~s/\s+//g;
		if($tmp[$check] eq "+"){
			$chkcnt++;
		}
		if($tmp[$check] ne "+"){
					$nh{"NA"}++;
					$vh{"NA"}.="$tmp[$id];";
		}
		else{
			my @tmpp=split(/\;/,$tmp[$cat]);
			for($cntt=0;$cntt<=$#tmpp;$cntt++){
					my ($name)=uc($tmpp[$cntt]);
					#$name=substr($name,0,4);
					$nh{$name}++;
					$vh{$name}.="$tmp[$id];";
			}
		}
	#print "@tmp[0],@tmp[9],@tmpp[0]\n";
}
close F1;

print "Categories\t$chkcnt\n";
foreach my $k1 (sort { $nh{$b} <=> $nh{$a} } keys %nh){
		print "$k1\t$nh{$k1}\n";
}


__END__
my $val1=((Math::BigInt->bfac(112))*(Math::BigInt->bfac(3170))*(Math::BigInt->bfac(3125))*(Math::BigInt->bfac(157)));
my $val2=((Math::BigInt->bfac(146))*(Math::BigInt->bfac(11))*(Math::BigInt->bfac(3024))*(Math::BigInt->bfac(3282))*(Math::BigInt->bfac(101)));
my $val=Math::BigFloat->new($val1);
$val/=$val2;
print "$val\n";
(112!*3170!*3125!*157!)/(11!*146!*3024!*3282!*101!)
perl category-counting.pl /cygdrive/l/Qexactive/Linda/uniprot-tw283.txt 0 9 > t.txt
 
 