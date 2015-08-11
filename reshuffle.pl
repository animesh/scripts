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
if(@ARGV!=3){die"USAGE: Input_File Output_File No_of_Feature";}
$file1=shift @ARGV;
$file2=shift @ARGV;
$ftr=shift @ARGV;
open(F2,">$file2");
open(F1,$file1);

	while($l1=<F1>){chomp $l1;$row++;
		@t1=split(/\s+/,$l1);
			for($c3=$ftr;$c3<=$#t1;$c3++){
				$otp[$c1][$c3]=@t1[$c3]+0;
				if($otp[$c1][$c3]==1){$label=$c3-$ftr+1;}
			}
		$labhash{"$l1|$row"}=$label;
	}
	close F1;

foreach(sort {$labhash{$a}<=>$labhash{$b}} keys %labhash){
	@t=split(/\|/,$_);
	print F2"@t[0]\n";
	}
