$file2=shift @ARGV;
open(F2,$file2);
$fout="$file2.class.csv";
open(FO,">$fout");
while($l=<F2>){
	chomp $l;
	$l=~s/^\s+//;
	$l=~s/\s+$//;
	@t=split(/\s+/,$l);
	$line++;
	if($line==1){
			for($c=0;$c<$#t;$c++){
				$cp=$c+1;
				print FO"V$cp,";
			}
			print FO"CLASS\n";
	}
	for($c=0;$c<$#t;$c++){
		$out=@t[$c]+0;
		print FO"$out,";
	}
	$out=@t[$c]+0;
	print FO"C$out\n";
	print "$line Class $out $c\n";
}
close FO;
close F2;

__END__
@files = <dlfmri_fl*.csv>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file CSV2ARFF\n"; 
	system("java weka.core.converters.CSVLoader $file > $file.arff");
	print "Processing file # $c $file RemoveUseless\n"; 
	system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.arff -o $file.ru.arff");
	print "Processing file # $c $file LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t $file.ru.arff > $file.ru.arff.10fold.lr.txt ");
	print "Processing file # $c $file SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t $file.ru.arff  > $file.ru.arff.10fold.svm.txt ");
}


system("export CLASSPATH=/usit/titan/u1/ash022");
	print "Processing file # dlfmri.txt.class.ru.arff LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t dlfmri.txt.class.ru.arff  > dlfmri.txt.class.ru.arff.10f.lr.txt ");
	print "Processing file # dlfmri.txt.class.ru.arff SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t dlfmri.txt.class.ru.arff > dlfmri.txt.class.ru.arff.10f.svm.txt ");

		
		