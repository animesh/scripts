#$c=shift @ARGV;

print rec(10);

sub rec {
    $c=shift;
    chomp $c;
	while($c>=0){
	    $t=recur($c);
	    print "Term $c => $t\n";
	    $c--;}
    sub recur{
	my $n=shift;
	if($n==1){return 1;}
	elsif($n<1){return 0;}
	else{return(recur($n-1)+recur($n-2))};
    }
}

sub ite{
    $c=shift;
    chomp $c;
    iter($c);
    sub iter{
	$x1=0;
	$x2=1;
	for($i=0;$i<$c;$i++){
	    print "$x1\n";
	    ($x1,$x2)=($x1+$x2,$x1);
	}
    }
}
