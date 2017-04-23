system("export CLASSPATH=/usit/titan/u1/ash022");
	print "Processing file # dlfmri.txt.class.ru.arff LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t dlfmri.txt.class.ru.arff  > dlfmri.txt.class.ru.arff.10f.lr.txt ");
	print "Processing file # dlfmri.txt.class.ru.arff SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t dlfmri.txt.class.ru.arff > dlfmri.txt.class.ru.arff.10f.svm.txt ");
