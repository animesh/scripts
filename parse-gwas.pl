while(<>){
	chomp;
	@t=split(/,/);
	@n=split(/vs/,$t[0]);
	push(@ns1,$n[0]);
	push(@ns2,$n[1]);
	$m{"$n[0]-$n[1]"}="$t[1]-$t[2]-$t[7]";
}
%seen = (); @ns1 = grep { ! $seen{ $_ }++ } @ns1;
%seen = (); @ns2 = grep { ! $seen{ $_ }++ } @ns2;
for($c1=0;$c1<=$#ns1;$c1++){
	if($c1==0){print "GI , ";for($c=0;$c<=$#ns2;$c++){print "$ns2[$c] , ";}print "\n";}
	print "$ns1[$c1] , ";
	for($c2=0;$c2<=$#ns2;$c2++){
		if($m{"$ns1[$c1]-$ns2[$c2]"} ne ""){
			print $m{"$ns1[$c1]-$ns2[$c2]"} ," , ";
		}
		else{print " , ";}
	}
	print "\n";
}

