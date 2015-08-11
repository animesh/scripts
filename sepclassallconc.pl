@files = <svm_mat_lex.csv.class.csv.inddisvox.txt.uniq.extftr.csv>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file CSV2ARFF\n"; 
	system("java weka.core.converters.CSVLoader $file > $file.class.arff");
	print "Processing file # $c $file LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t $file.class.arff -x 176 > $file.class.arff.176fold.lr.txt ");
	print "Processing file # $c $file SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t $file.class.arff -x 176 > $file.class.arff.176fold.svm.txt ");
	print "Processing file # $c $file NN\n"; 
        system("java weka.classifiers.functions.MultilayerPerceptron  -t $file.class.arff -x 176 > $file.class.arff.176fold.nn.txt ");
}


__END__
