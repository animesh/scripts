#codbac62j4-3p22.rp2_b1.SCF1
$file=shift @ARGV;chomp $file;
$fileo1="$file.f.fna";
$fileo2="$file.r.fna";
$filesing="$file.single.fna";
open(F,$file);
open(FF,">$fileo1");
open(FR,">$fileo2");
open(FS,">$filesing");
while(<F>){
chomp;
if($_=~/^>/){
	@tmp=split(/\./,$_);
	@tmp[0]=~s/\>//g;
	$name{@tmp[0]}++;
	if(@tmp[1]=~/^r/){$seqname=@tmp[0]."r";}
	elsif(@tmp[1]=~/^f/){$seqname=@tmp[0]."f";}
	else{$seqname=@tmp[0]."s";}
}
else{$seq{$seqname}.=$_;}
}
foreach $n (keys %name){
$r=$n."r";$f=$n."f";
if($name{$n}==2){$r=$n."r";$f=$n."f";print FF">$f\n$seq{$f}\n";print FR">$r\n$seq{$r}\n"}
elsif($seq{$r}){print FS">S$r\n$seq{$r}\n"}
elsif($seq{$f}){print FS">S$f\n$seq{$f}\n"}
else{
 $s=$n."s";print FS">S$s\n$seq{$s}\n"
 }
}
 

