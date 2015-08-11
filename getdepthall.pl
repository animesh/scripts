$f=shift @ARGV;
open(F1,$f);
while(<F1>){
        @t=split(/\t/);
                $ctgmin{@t[1]}=Inf;
                $ctgmax{@t[1]}=-Inf;
}
open(F2,$f);
while(<F2>){
	chomp;
	@t=split(/\t/);
	 $start=@t[2];
	 $end=@t[3];
	 if($start>$end){
		$tmp=$start;
		$start=$end;
		$end=$start;
	 }
               if($ctgmin{@t[1]}>$start){$ctgmin{@t[1]}=$start;}
               if($ctgmax{@t[1]}<$end){$ctgmax{@t[1]}=$end;}
	  for($c=$start;$c<=$end;$c++){
	 	$ctgdepth{@t[1]}++;
	  }
}
foreach (keys %ctgdepth) {
	$len=$ctgmax{$_}-$ctgmin{$_};
	$avg=$ctgdepth{$_}/$len;
	if($len>500){print "$_\t$ctgdepth{$_}\t$len\tMax[$ctgmax{$_}]\tMin[$ctgmin{$_}]\t$avg\n";}
}


