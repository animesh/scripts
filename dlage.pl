@files = <dl1602bdage.arff>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
        system("java -Xmx15000m  weka.clusterers.EM -I 100 -N -1 -M 1.0E-6 -S 100 -c 7 -t $file  > $file.em.txt ");
        system("java -Xmx15000m  weka.clusterers.SimpleKMeans -N 6 -A \"weka.core.EuclideanDistance -R first-last\" -I 500 -S 10 -c 7 -t $file  > $file.kmeans.txt ");
}

__END__
