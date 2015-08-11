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
#!/usr/bin/perl
#read gbk file and the Markov Model level
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName GBK-SeqFile(file name)\n\n\n";}
$file = shift @ARGV;
	use Math::Complex;
	$pi=pi;
	$i=sqrt(-1);
	@base=qw/G T A C/;
	$window=90;

#open GBK file
opengbk($file);
$line=~s/[0-9]//g;$line=~s/\s+//g;$line=~s/\/\///g;$length=length($line);
for($cp=0;$cp<$length;$cp=$cp+$window){
	$signal=FT($cp,$window);
}


sub opengbk{
    $file=shift;
    open(F,$file)||die "can\'t open \"$file\": $!";
    $part=shift;
    #print "Reading file $file";
    while($l=<F>)
    {
        if($l=~/^ORIGIN/)
        {        while($ll=<F>)
                {
                chomp $ll;$line.=$ll;
                }
        }
    }
close F;


sub FT {
$st=shift;
$le=shift;
$subs=substr($line,($st),$le);
until ($subs !~ /^G/){$subs =~s/^G//;}
$ws=$sp;$subfftseq=$subs;
$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
@subssplit=split(//,$subs);
	for($k=1;$k<=($sp/2);$k++)
	{
		if ($le/$k == 3){
			for($c6=0;$c6<=$#base;$c6++){
			$bvar=@base[$c6];
				for($c7=0;$c7<=$#subssplit;$c7++){
				$wsvar=@subssplit[$c7];
					if ($bvar eq $wsvar){
						$subsum+=exp(2*$pi*$i*($k/$le)*($c7+1));
					}
					else{
						$subsum+=0;
					}
				}
			$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
			$subsum=0;
			}
			$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
			$sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
			$substss=$sbar;
			$subptnr1=$subsumtotal/$substss;
			$subsumtotal=0;
			$subptnr2=$subptnr1/($sp*$substss);
			$subptnr3=$subptnr2*2;
			$pp=($k)/$le;
			$sp3=$subptnr3;$sp3=sprintf (1,$subptnr3,2);$sp3=substr($subptnr3,0,3);
			$sname=$sname."\tPtNR - $sp3";
				if($subptnr3 >= 4){
					print "Coding\t$sp3\tLength\t$N\n";
					print FP">$sname\t$sp3\tLength\t$N\n$subs\n";
				}
				else{
					print "Non Coding\t$sp3\tLength\t$N\n";
					print FN">$sname\t$sp3\tLength\t$N\n$subs\n";

				}			
		}
	}
	return();
}
