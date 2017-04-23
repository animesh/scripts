use strict;
use Text::ParseWords;
open(F1,$ARGV[0]);
my %id;
my $lv=1;
my $lc=0;
my $pro=4;
my $mod=5;
my $pep=0;
my $tf=21;
my $nf=23;
my $rf=25;
my $conf="High";
my %pepos;
my %nmt;
my %mdt;
my %nmn;
my %mdn;
my %nmr;
my %mdr;

my %seqh;
my $seqc;
open(F2,$ARGV[1]);
while(my $l1=<F2>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){my @st=split(/\|/,$l1);$seqc=$st[1];}
        else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}
close F2;


while(my $l=<F1>){
	$lc++;
	if($lc>$lv){
		$l =~ s/\r|\n|\'//g;
		my @tmp=parse_line(',',0,$l);
		my @tmp1=split(/\;/,$tmp[$pro]);
		my @tmp2=split(/\;/,$tmp[$mod]);
		for(my $c1=0;$c1<=$#tmp1;$c1++){
			for(my $c2=0;$c2<=$#tmp2;$c2++){
				if($tmp2[$c2] =~ /GlyGly/){
					$id{$tmp1[$c1]}++;
					my $psq=$tmp2[$c2];
					$psq=~s/[A-Z]|[a-z]|\(|\)//g;
					if ($seqh{$tmp1[$c1]}=~ /$tmp[$pep]/){
						$psq+=$-[0];
						$pepos{$tmp1[$c1]}.="$-[0]-$+[0];";
					}				
					if($tmp[$tf] eq $conf){
						$nmt{$tmp1[$c1]}.="$tmp[$pep]\t";
						$mdt{$tmp1[$c1]}+=$psq;
					}
					if($tmp[$nf] eq $conf){
						$nmn{$tmp1[$c1]}.="$tmp[$pep]\t";
						$mdn{$tmp1[$c1]}+=$psq;
					}
					if($tmp[$rf] eq $conf){
						$nmr{$tmp1[$c1]}.="$tmp[$pep]\t";
						$mdr{$tmp1[$c1]}+=$psq;
					}
				}
			}
		}
	}
	#else{$hdr{$lc}=$l}
}
close F1;


foreach (keys %id){
        my $seq=$seqh{$_};
        print "$_,$nmt{$_},$nmn{$_},$nmr{$_},$mdt{$_},$mdn{$_},$mdr{$_},$seq,$pepos{$_},$id{$_}\n";
}


__END__


perl pepcomp.pl /cygdrive/x/Elite/LARS/2013/oktober/TNRpeps.csv /cygdrive/x/Elite/LARS/2013/oktober/201311012AIFYRMN06.fasta > /cygdrive/x/Elite/LARS/2013/oktober/pepcomp.csv