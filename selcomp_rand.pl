#!/usr/bin/perl
@all=qw/11 13 15 16 17 1 20 21 25 29 2 31 32 33 34 35 37 38 39 3 41 42 43 44 46 47 48 49 4 50 51 52 54 55 56 58 5 60 61 62 65 67 68 6 7 9/;
$file="resall_conc.csv.trp.csv";
for($st=0;$st<1000;$st++){
	undef @remove;
	for($s=0;$s<10;$s++){
		push(@remove,@all[int(rand(46))]);
	}
	$appendi=join("-",@remove);
	print "Iter-$st\tSelcomp - $appendi\t";
	$retval=selcomp($st,$file,$appendi);
	print "finished - $retval\n";
	
}
runml("resall_conc.csv.trp.csv.13-49-51-54-58-3-4-33-60-46.remcomp.csv");
res();

sub res{
$c=0;
$filetemplr="$file.100.10.2";
system("grep -E \"a = C0\|b = C1\" resall_conc.csv.trp.csv.*-*-*-*-*-*-*-*-*-*.remcomp.csv.class.arff.10fold.svm.txt > $filetemplr ");
open(F,$filetemplr);
$filetemplrout=$filetemplr.".out";
open(FO,">$filetemplrout");
while(<F>){
        chomp;
        $c++;
        print "\n Processing results $c\n";
        @t1=split(/\s+/);
        if($c%4==1){
                @t2=split(/\./,@t1[0]);
                print FO"@t2[0]_@t2[4],";
        }
        print FO"@t1[1],@t1[2],";
        if($c%4==0){print FO"\n";}
}
}

sub selcomp{
my $num=shift;
my $file=shift;
my $appendi=shift;
open(F,$file);
$fo="$file.$appendi.remcomp.csv";
open(FO,">$fo");
$row=0;
undef %colmark;
	while($line=<F>){
		$row++;
		if($row==1){
			for($c=0;$c<=$#remove;$c++){
				$cnt=$c+1;
				@tmp1=split(/\,/,$line);
				for($cc=0;$cc<$#tmp1;$cc++){
					@tmp2=split(/\_/,@tmp1[$cc]);
					@tmp2[0]=~s/IC//g;
					if((@tmp2[0]+0)==(@remove[$c]+0)){
						$colmark{$cc}++;
						print "@tmp2[0]\t";
					}
				}
			}
		}
				@tmp1=split(/\,/,$line);
				for($cc=0;$cc<$#tmp1;$cc++){
					if($colmark{$cc} > 0){
						print FO"@tmp1[$cc]\,";
					}
				}
				print FO"@tmp1[$cc]\n";
	}
close FO;
close F;
$fi=runml($fo);
return $row-$fi;
}

sub runml{
	system("export CLASSPATH=/work/ash022");
	my $file=shift;
        print "Processing file $file\t";
        system("java weka.core.converters.CSVLoader $file > $file.class.arff");
        system("java -Xmx3000m  weka.classifiers.meta.ClassificationViaRegression -t $file.class.arff -x 10 > $file.class.arff.10fold.lr.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.SMO -t $file.class.arff -x 10 > $file.class.arff.10fold.svm.txt ");
	return($file);
}

