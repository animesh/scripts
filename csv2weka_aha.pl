system("export CLASSPATH=/home/animesh/export/weka");
$file=shift @ARGV;
chomp $file;
system("wc $file | awk '{print \$1}' > $file.tmp");
open(TMP,"$file.tmp");
$wc=<TMP>;
$wc+=0;
close TMP;
#for($wcp=2;$wcp<$wc;$wcp++){
for($wcp=3;$wcp<$wc-1;$wcp++){
system("head -n $wcp $file > train.csv");
system("head -n 1 $file > test.csv");
$tailv=$wcp+1;
print "$wcp\t$tailv\n";
system("head -n $tailv $file | tail -n 2 >> test.csv");
system("java  -Xmx16000m weka.classifiers.functions.SMOreg -t  train.csv  -T test.csv 2>t2 > $file.n.$wcp.txt");
system("grep \"Correlation\" $file.n.$wcp.txt "); 

#}
system("head -n 1 $file > test.csv");
$tailv=$wc-$wcp;
print "$wcp\t$tailv\n";
system("tail -n $tailv $file >> test.csv");
system("java  -Xmx16000m weka.classifiers.functions.SMOreg -t  train.csv  -T test.csv 2>t2 > $file.a.$wcp.txt");
system("grep \"Correlation\" $file.a.$wcp.txt ");
}

