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

open(F,@ARGV[0]);
open(FO,">@ARGV[0].csv");
$ftr=3;
$otp=2;

print FO"F1,F2,F3,Output\n";

while($l=<F>){
	@t=split(/\s+/,$l);
	for($c=0;$c<$ftr;$c++){
		$out=@t[$c]+0;
		#if($c!=25){
			print FO"$out,";
		#}
	}
	for($c=$ftr;$c<$ftr+$otp;$c++){
		$out=@t[$c]+0;
		if($out==1){
			$fout=$c-$ftr;
			print FO"O$fout\n";
			#print FO"$fout\n";
		}
	}
}

system("java weka.core.converters.CSVLoader @ARGV[0].csv > @ARGV[0].arff");
#system("java weka.classifiers.functions.LinearRegression -t @ARGV[0].arff -x 5");
system("java weka.classifiers.meta.ClassificationViaRegression -t @ARGV[0].arff -W weka.classifiers.trees.M5P -- -M 4.0");
