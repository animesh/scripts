#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
$file = shift @ARGV;
open(F,$file)||die "no such file $file";
$filcrd=$file.".crd.txt";
open(FC,">$filcrd");
$filpdbmod=$file.".mod.pdb";
open(FCM,">$filpdbmod");
$atnom=0;
while($l=<F>){
	chomp $l;
	if($l=~/^ATOM/){
		@t=split(//,$l);
		$name=@t[17].@t[18].@t[19].@t[12].@t[13].@t[14].@t[15].@t[16];
			$x=@t[30].@t[31].@t[32].@t[33].@t[34].@t[35].@t[36].@t[37]+0;
			$y=@t[38].@t[39].@t[40].@t[41].@t[42].@t[43].@t[44].@t[45]+0;
			$z=@t[46].@t[47].@t[48].@t[49].@t[50].@t[51].@t[52].@t[53]+0;
			$xcor{$atnom}=$x;
			$ycor{$atnom}=$y;
			$zcor{$atnom}=$z;
			$s2=$x."-".$y."-".$z;
			$aac{$atnom}=$name;
			$atname=$aac{$atnom};$atname=~s/\s+//g;
			print FC"$atname\t$x\t$y\t$z\n";
		$atnom++;

	}
	if($l!~/^END|^MASTER|^CONECT/){
		print FCM"$l\n";
	}
	elsif($l=~/^END|^MASTER/){
		push(@endoffile,$l);
	}
}
close F;

$filadm=$file.".adm.txt";
open(FA,">$filadm");


for ($c1=0;$c1<$atnom;$c1++) {
	for ($c2=0;$c2<$atnom;$c2++) {
		#if($c1!=$c2){
			$distmat[$c1][$c2]=ED($xcor{$c1},$ycor{$c1},$zcor{$c1},$xcor{$c2},$ycor{$c2},$zcor{$c2});
		#}
		if($distmat[$c1][$c2]<=5){
			$adjmat[$c1][$c2]=1;
			print FA"$adjmat[$c1][$c2]\t";
			$atm1=$c1+1;$atm2=$c2+1;
			if((abs($atm1-$atm2)>=5)){
				print FCM"CONECT $atm1 $atm2\t\t\t\t\t\t\t\t\n";
			}
		}
		else{
			$adjmat[$c1][$c2]=0;
			#print "$distmat[$c1][$c2]\t";
			print FA"$adjmat[$c1][$c2]\t";
		}
	}
	#print "\n";
	print FA"\n";
}
close FA;
for ($c1=0;$c1<=$#endoffile;$c1++) {
	print FCM"@endoffile[$c1]\n";
}
close FCM;

sub ED{
	my $xval1=shift;
	my $yval1=shift;
	my $zval1=shift;
	my $xval2=shift;
	my $yval2=shift;
	my $zval2=shift;
	$dis=sqrt(($xval1-$xval2)**2+($yval1-$yval2)**2+($zval1-$zval2)**2);
	return $dis;
}

# Version 7 of Coordinate extract written on 11/5/2005 under the guidance of Rajeev Mishra
