use strict;
use warnings;
use XML::Simple;

my $f = shift @ARGV;
my $par1 = shift @ARGV;
my $par2 = shift @ARGV;
my $par3 = shift @ARGV;
my $par4 = shift @ARGV;
my $par5 = shift @ARGV;
my $d = XMLin($f);
#print $f,$d;
#use Data::Dumper;
#print Dumper($d);
my %maxrtr;
foreach my $p (keys %{$d->{$par1}}) {
	if(ref($d->{$par1}->{$p}->{$par2}->{$par3}) eq 'HASH'){
		my $len=length($d->{$par1}->{$p}->{$par2}->{$par3}->{$par5});
		if($len){
			my $sname='>'.'L'.$len.'N'.$p . '_'.  $d->{$par1}->{$p}->{$par2}->{$par3}->{$par4};
			print "$sname\t";
			my $seq=$d->{$par1}->{$p}->{$par2}->{$par3}->{$par5};
			print "$seq\t";
			my ($max,$lgt)=FT($sname,uc($seq));
			print "$max\t$maxrtr{$max}\t$lgt\t$len\n";
		}
	}
}

#my $sname="Test";
#my $seq="ATGGCCCTGTGGATGCGCCTCCTGCCCCTGCTGGCGCTGCTGGCCCTCTGGGGACCTGACCCAGCCGCAGCCTTTGTGAACCAACACCTGTGCGGCTCACACCTGGTGGAAGCTCTCTACCTAGTGTGCGGGGAACGAGGCTTCTTCTACACACCCAAGACCCGCCGGGAGGCAGAGGACCTGCAGGTGGGGCAGGTGGAGCTGGGCGGGGGCCCTGGTGCAGGCAGCCTGCAGCCCTTGGCCCTGGAGGGGTCCCTGCAGAAGCGTGGCATTGTGGAACAATGCTGTACCAGCATCTGCTCCCTCTACCAGCTGGAGAACTACTGCAACTAG";
#my %maxrtr;
#my $max=FT($sname,uc($seq));
#print "Max $max $maxrtr{$max}\n";

sub FT {
	use Math::Complex;
	my $pi=pi;
	my $i=sqrt(-1);
	my @base=qw/A T G C/;
	my $subseqname=shift;
	my $subseq=shift;
	open(F,">$subseqname.ft.txt");
	my $ws=length($subseq);
    my @wssplit=split(//,$subseq);
	my $c=$subseq=~s/C/C/g;
	my $a=$subseq=~s/A/A/g;
	my $g=$subseq=~s/G/G/g;
	my $t=$subseq=~s/T/T/g;
	my $sum;
	my $max;
	my $sumtotal;
		for(my $k=2;$k<$ws/2;$k++){
			my $f=1/$k;
			for(my $c3=0;$c3<=$#base;$c3++){
                my $bvar=$base[$c3];
                for(my $c4=0;$c4<=$#wssplit;$c4++){
					my $wsvar=$wssplit[$c4];
                    if ($bvar eq $wsvar){
                                $sum+=exp(2*$pi*$i*$f*($c4+1));
                    }
                    else{$sum+=0;}
                }
                $sumtotal+=(((1/$ws)**2)*(abs($sum)**2));$sum=0;
            }
			my $atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
			my $sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);
			my $ptnr=$sumtotal/$sbar;
			print F"$k\t$ptnr\t$f\t$ws\t",$a+$t+$g+$c,"\n";
			$sumtotal=0;
			$atgcsq=0;
			if($maxrtr{$max}<$ptnr){$max=$k;$maxrtr{$k}=$ptnr}
		}
	return ($max,$ws);
}

__END__
http://perlmeme.org/tutorials/parsing_xml.html
perl -MCPAN -e 'install XML::Simple'
wget http://lncrnadb.com/rest/all/sequence
perl xmlsimple.pl sequence Results sequence SequenceRecord record FastaSequence
