use strict;
use warnings;
use Text::ParseWords;

my $f=shift @ARGV; #Mapped Uniprot File
my $c1=shift @ARGV; #Protein Sequence
my $c2=shift @ARGV; #Peptide Sequence
my $c3=shift @ARGV; #Modification column
my $c4=shift @ARGV; #Modification position

open(F,$f);
my $ln=0;
while(my $l=<F>){
	chomp $l;$l=~s/\r//g;
	$ln++;
	my @t=parse_line('\t',0,$l);
	my $prot=uc($t[$c1]);
	$prot=~s/\s+//g;
	my $pep=uc($t[$c2]);
	$pep=~s/I/L/gi;
	$prot=~s/I/L/gi;
	my @tpep=parse_line(';',0,$pep);
	my $mod=$t[$c3];
	my @tmod=parse_line(';',0,$mod);
	for(my $cnt1;$cnt1<=$#tpep;$cnt1++){
		for(my $cnt2;$cnt2<=$#tmod;$cnt2++){
			$tpep[$cnt1]=~s/ //g;
			my $start = index($prot, $tpep[$cnt1], 0)+1; # single match
			my $end = $start+length($tpep[$cnt1])-1;
			$tmod[$cnt2]=~s/^\s+//g;
			my @tmodpos=parse_line(' ',0,$tmod[$cnt2]);
			#while ( $prot =~ m/($tpep[$cnt1])/g){ #overlapping matches
			#	my $peptide=$1;
			#	my $start=pos($prot)-length($1)+1;
			#	my $end=pos($prot);
				if($start>0&&$tmodpos[$c4-1]=="MOD_RES"&&$tmodpos[$c4]<=$end&&$tmodpos[$c4]>=$start){
					print "$ln\t$cnt1\t$cnt2\t$start\t$end\t$tpep[$cnt1]\t$tmod[$cnt2]\n";
				}
			#}
		}
	}
}
close F;

__END__

perl pep2prot.pl /cygdrive/l/Animesh/Lymphoma/PTMseqList20.txt 1 67 12 1  2>t | less

