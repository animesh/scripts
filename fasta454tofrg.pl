#codbac62j4-3p22.rp2_b1.SCF1
$file=shift @ARGV;chomp $file;
$fileo1="$file.p2c.fna";
$fileo2="$file.p2c.lkg";
open(F,$file);
open(F1,">$fileo1");
open(F2,">$fileo2");
while(<F>){
if($_=~/^>/){
	@tmp=split(/\./,$_);
	$name{@tmp[0]}++;
	if(@tmp[1]=~/^r/){print F1"@tmp[0]r\n";}
	if(@tmp[1]=~/^f/){print F1"@tmp[0]f\n";}
}
else{print F1"$_";}
}
foreach $n (keys %name){
if($name{$n}==2){$r=$n."r";$f=$n."f";$f=~s/\>//g;$r=~s/\>//g;print F2"$r $f\n";}
else{print "$n\t$name{$n}\n"}
}
 

