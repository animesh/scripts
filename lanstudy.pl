@files = <svm_mat_lex.csv.study.csv.arff>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t $file -x 176 > $file.class.arff.176fold.lr.txt ");
	system("java  weka.classifiers.meta.ClassificationViaRegression -t $file  > $file.class.arff.10fold.lr.txt ");
	print "Processing file # $c $file SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t $file -x 176 > $file.class.arff.176fold.svm.txt ");
        system("java  weka.classifiers.functions.SMO -t $file  > $file.class.arff.10fold.svm.txt ");
	print "Processing file # $c $file EM\n"; 
        system("java  weka.clusterers.EM -c 8638 -t $file  > $file.em.txt ");
	print "Processing file # $c $file s-K-means\n"; 
        system("java  weka.clusterers.SimpleKMeans  -A \"weka.core.EuclideanDistance -R first-last\" -c 8638 -t $file  > $file.kmeans.txt ");
	print "Processing file # $c $file MLP\n"; 
        system("java  weka.classifiers.functions.MultilayerPerceptron -t $file > $file.nn.10f.txt ");
	}

__END__
