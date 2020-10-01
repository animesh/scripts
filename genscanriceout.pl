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
open FILE1,"genscanrice.txt" || die;
while ($line = <FILE1>) {
        chomp ($line);
        if ($line =~ /^>gi|GENSCAN_predicted_CDS_/){
                                              do{
                                        $l=<FILE1>;
                                        chomp ($l);
                                        $line =~ s/\>///g;
                                        $line = $line.$l;
                                               }   until ($line =~ 
/\>gi|GENSCAN_predicted_peptide_//);

                                             $line =~ s/[0-9]//g;
                                             $line =~ s/ORIGIN//g;
                                             $line =~ s/\/\///g;
                                             $line =~ s/ //g;
                                             $linen=$linen.$line;

                                         }
                }



      }
}
push(@seq,$seq);
$l1=@seqname;
for($c1=0;$c1<$l1;$c1++){print "@seqname[$c1]\n";}
