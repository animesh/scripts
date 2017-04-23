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
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName SeparatedSeqFile\t AnnotationFile\n\n\n";}
$filess = shift @ARGV;$cp=0;$cnp=0;
$fileas = shift @ARGV;$cp=0;$cnp=0;
open (F1, $filess) || die "can't open \"$filess\": $!";
open (F2, $fileas) || die "can't open \"$fileas\": $!";
while ($line = <F1>) 	{
			chomp ($line);
             		push(@name1,$line);
            		}
while ($line = <F2>)    {
                        chomp ($line);
                        push(@name2,$line);
                        }

open (F,">$filess.".".$fileas");
foreach $n1 (@name1){
	@temp1=split(/\s+/,$n1);
	$t1=@temp1[1];
	foreach $n2 (@name2){
	        @temp2=split(/\s+/,$n2);
	        $t2=@temp2[0];
		if($t1 eq $t2)
			{
			print F"$n1\t$n2\n";
			}
		}
	}
close F;close FS1,close FS2;
