@th=qw/0 0 0/;
@ta=qw/0 1 0/;
@ts=qw/1 0 0/;

	$a=sqrt((@th[0]-@ta[0])**2 + (@th[1]-@ta[1])**2 + (@th[2]-@ta[2])**2);
	$b=sqrt((@ts[0]-@ta[0])**2 + (@ts[1]-@ta[1])**2 + (@ts[2]-@ta[2])**2);
	$c=sqrt((@th[0]-@ts[0])**2 + (@th[1]-@ts[1])**2 + (@th[2]-@ts[2])**2);
	$s=(1/2)*($a+$b+$c);
	$area=sqrt($s*($s-$a)*($s-$b)*($s-$c));
	print "AREA - $area\t$s\t$a\t$b\t$c\n";	

