#!/usr/bin/perl
system("export CLASSPATH=/usit/titan/u1/ash022");
$file1="label.txt";
open(F1,$file1);
while($l1=<F1>){
        $l1line++;
        chomp $l1;
        @t=split(//,$l1);
        $len=$#t;
        print "$len\t@t[0]\n";
        if($len!=0||$l1line>66){die"label file incorrect or more labels"}
        else{push(@lab,@t[0])};
}
close F1;

@files=<IC_*.csv>;
foreach (@files){
$line=0;
$file2=$_;
open(F2,$file2);
$ica=$file2;
$ica=~s/\.csv/\_/g;
print "$ica\n";
$fout=$ica."class.csv";
open(FO,">$fout");
while($l=<F2>){
        $l=~s/^\s+//;
        $l=~s/\s+$//;
        @t=split(/\,/,$l);
        $line++;
        if($line==1){
                        for($c=0;$c<=$#t;$c++){
                                $cp=$c+1;
                                print FO"$ica","V$cp,";
                        }
                        print FO"CLASS\n";
        }
        for($c=0;$c<=$#t;$c++){
                $out=@t[$c]+0;
                print FO"$out,";
        }
        $out=@lab[$line-1]+0;
        print FO"C$out\n";
        print "$line Class $out\n";
}
close F2;
        print "Processing file # $ica $fout CSV2ARFF\n";
        system("java weka.core.converters.CSVLoader $fout > $fout.arff");
        print "Processing file # $cf $fout RemoveUseless\n";
        system("java weka.filters.unsupervised.attribute.RemoveUseless -i $fout.arff -o $fout.ru.arff");
        print "Processing file # $ica $fout LR\n";
        system("java  weka.classifiers.meta.ClassificationViaRegression -t $fout.ru.arff > $fout.ru.arff.10fold.lr.txt ");
        print "Processing file # $ica $fout SVM\n";
        system("java  weka.classifiers.functions.SMO -t $fout.ru.arff  > $fout.ru.arff.10fold.svm.txt ");
}

