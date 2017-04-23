$file2=shift @ARGV;
open(F2,$file2);
$fout=$file2."_weka.csv";
open(FO,">$fout");
while($l=<F2>){
        $l=~s/\s+//;
        @t=split(/\,/,$l);
        $line++;
        if($line==1){
                        for($c=0;$c<$#t;$c++){
                                $cp=$c+1;
                                print FO "V",$cp,",";
                        }
                        print FO"NESS\n";
        }
        for($c=0;$c<$#t;$c++){
                $out=@t[$c]+0;
                print FO"$out,";
        }
        $out=@t[$c]+0;
        print FO"$out\n";
        print "$line Ness $out\n";
}
close F2;

