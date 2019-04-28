use warnings;
use strict;
$|=1;
use Data::Dumper;

my $fileflow=shift @ARGV;
open(F,$fileflow);

my $fo1=$fileflow.".actual.val";
open(FO1,">$fo1");

my $fo2=$fileflow.".mod.val";
open(FO2,">$fo2");

my $fo4=$fileflow.".csv";
open(FO4,">$fo4");


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
			print FO1"$temp2[$c3]\n";
			print FO2"$p1\n";
                }
		$flowval{$name}=$flowstr;
        }
}


my $cnt;	
foreach (keys %flowval) {
	$cnt++;
	#print "$cnt\t$_\t$hitscore{$_}\n";
	if($cnt==1){
		@temp=split(/\,/,$flowval{$_});
		#print "SeqName,";
                for($c2=0;$c2<$#temp;$c2++){
			my $fv=$c2+1;
                        print FO4"Flow-$fv,";
                }
		my $fv=$c2+1;
		print FO4"Flow-$fv,HitScore\n";
	}
	print FO4"$flowval{$_}T\n";
}

__END__

export CLASSPATH=/home/ash022/weka
java weka.core.converters.CSVLoader t3.csv > t3.arff
java weka.classifiers.functions.MultilayerPerceptron -t t3.arff -x 10

weka.sh (END) 



