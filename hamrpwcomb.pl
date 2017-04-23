use warnings;
use strict;
my $f1=shift;
my $f2=shift;
open(F1,$f1);
open(F2,$f2);
my $mc1=0;
my $mc2=1;
my $mc3=2;
my $mc4=14;
my @list=<F1>;
my @gop=<F2>;
@list = sort { uc($a) cmp uc($b) } @list;
@gop = sort { uc($a) cmp uc($b) } @gop;
my $cnt=0;
my %match;
my %mf;
my %mf1;
my %mf2;
my $title;
for(my $c1=0;$c1<=$#list;$c1++){
	$list[$c1]=~s/\n|\r//g;
	if($c1==0){$title=$list[$c1];}
	my @tmp1=split(/\t/,$list[$c1]);
	for(my $c2=$cnt;$c2<=$#gop;$c2++){
		$gop[$c2]=~s/\n|\r//g;;
		my @tmp2=split(/\t/,$gop[$c2]);
		my $v1="$tmp1[$mc1]-$tmp1[$mc2]-$tmp1[$mc3]";
		my $v2="$tmp2[$mc1]-$tmp2[$mc2]-$tmp2[$mc3]";
		if($tmp1[$mc4] eq "TRUE" and $tmp2[$mc4] eq "TRUE"){
			if(uc($v1) eq uc($v2)){
				$match{$v1}="$list[$c1]\t$gop[$c2]";
				delete $list[$c1]; # saves a sec
				delete $gop[$c2];
				$cnt=$c2+1;
				$mf{$v1}++;
				last;
			}
			else{$mf1{$v1}="$list[$c1]";$mf2{$v2}="$gop[$c2]";$mf{$v1}++;$mf{$v2}++;}
		}
 	}
}
print "Condition\tSeq-Pos-Strand\t$title\t$title\tCount\tFile\n";
foreach (keys %mf){
	if($match{$_}){
		print "B\t$_\t$match{$_}\t$mf{$_}\t$f1-$f2\n";
	}
	elsif($mf1{$_}){
		print "M\t$_\t$mf1{$_}\t$gop[-1]\t$mf{$_}\t$f1\n";
	}
	elsif($mf2{$_}){
		print "C\t$_\t$list[-1]\t$mf2{$_}\t$mf{$_}\t$f2\n";
	}
	else{
		print "NA\t$_\t$list[-1]\t$gop[-1]\t$mf{$_}\tNA\n";
	}
}

__END__

 perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22567.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22568.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2256768.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
 
 
 
  387  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  388  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  389  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  392  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  393  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  394  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  395  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  396  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  397  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254848.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  398  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254848.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  399  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  400  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32538.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32551.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253851.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  401  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32538.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32551.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253851.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  402  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  403  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  404  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  405  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  406  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32548.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32542.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254842.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  407  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32538.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32551.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253851.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  408  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32539.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32552.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253952.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  409  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32540.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32553.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254053.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  410  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32530.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32534.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253034.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  411  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32529.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32533.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3252933.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  412  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32532.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32541.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253241.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  413  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32531.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32545.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253145.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  414  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32531.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32535.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3253135.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  415  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32546.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32549.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254649.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  416  perl hamrcomb.pl /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32547.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL32550.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt > /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL3254750.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt
  419  ls /cygdrive/l/Elite/gaute/Brede_052313_Raw_Fastq/inirestRNA/hamr/SL325????.fastq.gz.ca.fastq.sam.so.bam.hamr_mods.txt | sed 's/\./ /g'
   539  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22565.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22566.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2256566.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   540  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22567.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22568.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2256768.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   541  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22569.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22570.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2256970.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   542  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL225671.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22572.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257172.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   543  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL225673.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22574.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257374.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   544  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22571.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22572.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257172.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   545  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22573.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22574.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257374.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   546  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22736.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22737.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2273637.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   547  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22738.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22739.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2273839.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   548  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22740.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22741.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2274041.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   549  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22742.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22743.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2274243.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   550  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22744.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22745.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2274445.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   551  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22746.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22747.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2274647.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   552  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22748.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22749.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2274849.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   553  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22750.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22751.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2275051.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   554  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22775.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22776.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2277576.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   555  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22777.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22778.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2277879.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   556* perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL227.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22776.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2277576.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   557  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22575.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22576.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257576.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   558  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22577.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22578.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257879.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   559  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22577.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22578.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257778.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   560  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22579.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22580.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2257980.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   561  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22581.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22582.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2258182.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
   562  perl /cygdrive/c/Users/animeshs/misccb/hamrpwcomb.pl SL22583.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt SL22584.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt > SL2258384.fastq.gz.ca.fastq.tRNA.sam.bam.so.bam.bam.hamr_mods.txt
