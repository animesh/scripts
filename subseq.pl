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

#!/perl/user/bin/perl


print "Enter the sequence filename\n";
$name = <>;
chomp ($name);
open(F1,"$name") ||
              die "can't open $name: $!";

print "enter the file containing coding regions\n";
$cod = <>;
chomp($cod);
open(FILEHANDLE,"$cod") ||
              die "can't open $name: $!";
while ($line=<FILEHANDLE>)
	{
    	chomp($line);
    	push(@table,$line) ;
    	}
    #print "$line \n";

foreach $a(@table)
	{
	$a =~ s/\s/\t/g;
	@b=split(/\t/,$a);
	push(@start,$b[0]);
	push(@stop,$b[1]);
	#print "$b[0] $b[1] \n";
	}


	$seq = "";
while ($s = <F1>)
	{
	if ($s =~ /^>/)
		{
		push(@seqname, $s);
		}
	else    {
		$seq= $seq.$s;
		}
	}



 $x = $seq->subseq($b[0]-300,$b[1]+300);
 #print "$x \n";
  print "> SEQUENCE \n";
  print "$x \n";
              # print "$subseq \n\n";
               # $j++;
	#$subseq=""; $newseq="";
  }



