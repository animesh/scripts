#104j22.f        7180001536277   4184    4563    r
#209f14.r        7180001536287   394     1100    r
#-bash-3.2$ grep "^[0-9]" Pwgs6dhmovlcod.posmap.frgscf.sorted | wc
while(<>){if($_=~/^[0-9]/){
	chomp;
	@tmp=split(/\s+/);
	$scf{@tmp[0]}=@tmp[1];
	$bp{@tmp[0]}=@tmp[2];
	$ep{@tmp[0]}=@tmp[3];
	$ortn{@tmp[0]}=@tmp[4];
	@n=split(/\./,@tmp[0]);
	$name{@n[0]}++;
}}
foreach (keys %name) {if($name{$_}==2){
	$cnt++;
	$r="$_.r";
	$f="$_.f";
	$dist=abs($bp{$r}-$bp{$f});
	if($scf{$r} eq $scf{$f}){print "$cnt $_ $scf{$r} $scf{$f} $bp{$r} $bp{$f} $ep{$r} $ep{$f} $ortn{$r} $ortn{$f} $dist\n";}
}}


