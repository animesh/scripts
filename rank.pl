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
#if((@ARGV)!=2){die "USAGE: progname_name feature_file_with_OUTPUT_vector no_of_feature\n";}
$ftr=shift @ARGV;
$f=$ftr;
	print "$f\t$ftr\n";

		open(F,$f);
		$c1=0;$rowno=0;
		while($l1=<F>){
			chomp $l1;
			@t1=split(/\t/,$l1);
			undef %rank;
			for($c2=0;$c2<=$#t1;$c2++){
				$rank{$c2+1}=@t1[$c2]+0;
			}
		}
		close F;

		$foo=$f.".out";
		open(FO,">$foo");

foreach  (sort {$rank{$b}<=>$rank{$a}} keys %rank) {
	print FO"$_\t$rank{$_}\n";
}
		close FO;
