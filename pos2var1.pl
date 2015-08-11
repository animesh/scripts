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
$th=0.6;
$fposmut=shift @ARGV;
open(FPM,"$fposmut");
$fcovmat=shift @ARGV;
open(FCM,"$fcovmat");
while($l=<FPM>){
	chomp $l;
	push(@fpm,$l);
}
close FPM;
while($l=<FCM>){
	chomp $l;
	push(@fcm,$l);
}
close FCM;
$fo=$fposmut.$fcovmat.".out";
open(FO,">$fo");
for($c1=0;$c1<=$#fpm;$c1++){
	print FO"@fpm[$c1]\t";
	@t=split(/\t/,@fcm[$c1]);
	for($c2=0;$c2<=$#t;$c2++){
		if((@t[$c2]<-($th)||@t[$c2]>($th))&&@t[$c2]!=-1&&@t[$c2]!=1&&@t[$c2] ne "NA"){
		#if((@t[$c2]<-($th)||@t[$c2]>($th))&&@t[$c2] ne "NA"){
			print FO $c2+1 , "~@t[$c2]\t";
		}
	}
	print FO"\n";
}
