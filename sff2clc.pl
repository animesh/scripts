@files=<*>;
foreach $f (@files){
        if(-d $f){
                @sff=<$f/*.sff>;
                foreach $sf (@sff){
                @tmp=split(/\//,$sf);
                print "converting $sf\t$f\n";
#                system("/usit/titan/u1/ash022/clc-assembly-cell-3.2.0-linux_64/tofasta -o @tmp[1].$f.fastq $sf");
                if($f ne "shotgun"){
#                        system("/usit/titan/u1/ash022/clc-assembly-cell-3.2.0-linux_64/split_sequences  -i @tmp[1].$f.fastq -p @tmp[1].$f.pair.fastq -d ti -s @tmp[1].$f.single.fastq");
#                        system("rm @tmp[1].$f.fastq");
                }
		else{
			system("/usit/titan/u1/ash022/clc-assembly-cell-3.2.0-linux_64/tofasta -o @tmp[1].$f.fastq $sf");

		}
                }
        }
}

