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

$file_result="s1.txt";
$no_of_feature=20;
$no_of_class=2;

$file_result_out=$file_result.".out";

$file_train="brc_ratio_train_trp.txt";
$file_test="brc_ratio_test_trp.txt";
$file_train_trp=$file_train.".trp.txt";
$file_test_trp=$file_test.".trp.txt";
$file_train_trp_choose=$file_train_trp.".choose.txt";
$file_test_trp_choose=$file_test_trp.".choose.txt";


#system("perl parseOFS1.pl $file_result");
#print "Parsed OFS output $file_result\n";
#system("perl trp.pl $file_train > $file_train_trp");
#print "Transposed training file $file_train > $file_train_trp\n";
#system("perl trp.pl $file_test > $file_test_trp");
#print "Transposed test file $file_test > $file_test_trp\n";
#system("perl choose_row.pl $file_train_trp $file_result_out > $file_train_trp_choose");
#print "Rows picked and written to $file_train_trp_choose\n";
#system("perl choose_row.pl $file_test_trp $file_result_out > $file_test_trp_choose");
#print "Rows picked and written to $file_test_trp_choose\n";

$file_train_trp_choose_no=$file_train_trp_choose.".$no_of_feature.txt";
open(FO,">$file_train_trp_choose_no");
undef @filearr;

open(F,$file_train_trp_choose);
while($line=<F>){
	chomp $line;
	if($line ne ""){
		push(@filearr,$line);
	}
}
for($c=0;$c<$no_of_feature;$c++){
	print FO"@filearr[$c]\n";
}
undef @filearr;
close F;

open(F,$file_train_trp);
while($line=<F>){
	chomp $line;
	if($line ne ""){
		push(@filearr,$line);
	}
}

for($c=(@filearr-1);$c>(@filearr-$no_of_class-1);$c--){
	print FO"@filearr[$c]\n";
}
undef @filearr;
close F;
close FO;
print "Written top $no_of_feature feature to $file_train_trp_choose_no\n";

$file_test_trp_choose_no=$file_test_trp_choose.".$no_of_feature.txt";
open(FO,">$file_test_trp_choose_no");

open(F,$file_test_trp_choose);
while($line=<F>){
	chomp $line;
	if($line ne ""){
		push(@filearr,$line);
	}
}
for($c=0;$c<$no_of_feature;$c++){
	print FO"@filearr[$c]\n";
}
undef @filearr;
close F;

open(F,$file_test_trp);
while($line=<F>){
	chomp $line;
	if($line ne ""){
		push(@filearr,$line);
	}
}

for($c=(@filearr-1);$c>(@filearr-$no_of_class-1);$c--){
	print FO"@filearr[$c]\n";
}
undef @filearr;
close F;
close FO;
print "Written top $no_of_feature feature to $file_test_trp_choose_no\n";

$file_train_trp_choose_no_trp=$file_train_trp_choose_no.".trp.txt";
$file_test_trp_choose_no_trp=$file_test_trp_choose_no.".trp.txt";

system("perl trp.pl $file_train_trp_choose_no > $file_train_trp_choose_no_trp");
print "Transposed file $file_train_trp_choose_no > $file_train_trp_choose_no_trp\n";
system("perl trp.pl $file_test_trp_choose_no > $file_test_trp_choose_no_trp");
print "Transposed file $file_test_trp_choose_no > $file_test_trp_choose_no_trp\n";

