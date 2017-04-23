use warnings;
use strict;
$|=1;
use Data::Dumper;
my $file=shift @ARGV;
open(F,$file);

my $perc=0.10;
my $pia;
my $ala;
my $eva;
my $bsa;
my $cnt;
my $cntseq;
my $totalbs;
my %us;
my $pit=0;
my $alt=0;
my $evt=1000;
my $bst=0;
my %hitpos;
my %hitname;
my $max=0;
my $min=100000000000000;
my %hitscore;
my %compname;
my %evalhitscore;
my $seqcntthresh=200;

while(<F>){
    $cntseq++;
    my @tmp=split(/\s+/,$_);
    my $Query_id=$tmp[0];       
    my $Subj_id=$tmp[1];       
    my $per_iden=$tmp[2];       
    my $aln_length=$tmp[3];     
    my $mismatches=$tmp[4];     
    my $gap_open=$tmp[5];       
    my $q_start=$tmp[6];
    my $q_end=$tmp[7];  
    my $s_start=$tmp[8];
    my $s_end=$tmp[9];  
    my $e_value=$tmp[10];
    my $bit_score=$tmp[11];
    if($max<$bit_score){$max=$bit_score};
    if($min>$bit_score){$min=$bit_score};
    if($hitscore{$Query_id}<$bit_score){$hitscore{$Query_id}=$bit_score};
    $totalbs+=$bit_score;
}

close F;

my $fileflow=shift @ARGV;
open(F,$fileflow);
my $l;
my $c;
my @temp;
my @temp2;
my $length;
my $c2;
my $p0;
my $p1;
my $c3;
my $name;
my %flowval;
while($l=<F>){
        chomp $l;
	my $flowstr;
	if($l=~/^>/){$c++;$name=$l;$name=~s/\>//;}
        if($l=~/^Flowgram/){
                @temp=split(/\:/,$l);
                @temp2=split(/\s+/,$temp[1]);
                $length=(@temp2);
                $length-=1;
                for($c2=0;$c2<$#temp2;$c2++){
                        $c3=$c2+1;
                        $p0=int($temp2[$c3]);
                        $p1=$temp2[$c3]-$p0;
                        if($p1>0.5){
                                $p1=1-$p1;
                        }
                        $p1=sprintf("%.2f", $p1);
			$flowstr.="$p1,";
                }
		$flowval{$name}=$flowstr;
        }
}
	my $upr=$max-($max-$min)*$perc;
	my $lowr=$min+($max-$min)*$perc;
my $ucnt;
my $lcnt;
my $of1=$fileflow.$file.".new.train.csv";
open(FO1,">$of1");
my $of2=$fileflow.$file.".new.trainname.csv";
open(FO2,">$of2");
my $of3=$fileflow.$file.".new.test.csv";
open(FO3,">$of3");
my $of4=$fileflow.$file.".new.testname.csv";
open(FO4,">$of4");
	
foreach (keys %hitscore) {
	$cnt++;
	#print "$cnt\t$_\t$hitscore{$_}\n";
	if($cnt==1){
		@temp=split(/\,/,$flowval{$_});
		#print "SeqName,";
                for($c2=0;$c2<$#temp;$c2++){
			my $fv=$c2+1;
                        print FO1"Flow-$fv,";
                        print FO3"Flow-$fv,";
                }
		my $fv=$c2+1;
		print FO1"Flow-$fv,HitScore\n";
		print FO3"Flow-$fv,HitScore\n";
	}
#	if($hitscore{$_}>=$upr && $ucnt<$seqcntthresh){print FO1"$flowval{$_}T\n";$ucnt++;}
#	if($hitscore{$_}<=$lowr && $lcnt<$seqcntthresh){print FO1"$flowval{$_}B\n";$lcnt++;}
	if($hitscore{$_}>=$upr && $ucnt<$seqcntthresh){print FO1"$flowval{$_}T\n";$ucnt++;print FO2"$_\n"}
	if($hitscore{$_}<=$lowr && $lcnt<$seqcntthresh){print FO1"$flowval{$_}B\n";$lcnt++;print FO2"$_\n"}
	elsif($hitscore{$_}>(($max-$min)/2)&&($ucnt>=$seqcntthresh)){print FO3"$flowval{$_}T\n";print FO4"$_\n"}
	elsif($hitscore{$_}<=(($max-$min)/2)&&($lcnt>=$seqcntthresh)){print FO3"$flowval{$_}B\n";print FO4"$_\n"}
	#elsif($hitscore{$_}>(($max-$min)/2)){print FO3"$flowval{$_}T\n";print FO4"$_\n"}
	#elsif($hitscore{$_}<=(($max-$min)/2)){print FO3"$flowval{$_}B\n";print FO4"$_\n"}
}

__END__

export CLASSPATH=/home/ash022/weka
java weka.core.converters.CSVLoader t3.csv > t3.arff
java weka.classifiers.functions.MultilayerPerceptron -t t3.arff -x 10

weka.sh (END) 



