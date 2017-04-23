$file2=shift @ARGV;
open(F2,$file2);
$fout="$file2.csv";
open(FO,">$fout");
while($l=<F2>){
        $l=~s/^\s+//;
        $l=~s/\s+$//;
        @t=split(/\t/,$l);
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
        print FO"$out\n";
        print "$line Class $out\n";
}
close F2;

