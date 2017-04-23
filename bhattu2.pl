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
open(F,"NC_000913.gbk.0");
open(FF,">test");
while($l=<F>)
{

             if($l =~ /CDS/){
                if($l =~ /join/)
                        {unless($l =~ /\)/)
                                {
                                        do{
                                        $linenew=<F>;
                                        chomp ($linenew);
                                        $l = $l.$linenew;
                                                }until ($l =~ /\)/)
                                }
                        }
             $l =~ s/\(/ /;
             $l =~ s/\)/ /;
             $l =~ s/join//;
             $l =~ s/CDS//;
	if($l=~/complement/){$l=~s/[A-Za-z]//g;$l=~s/\/\=\"\"//g;
		@temp=split(/,/,$l);foreach $tr (@temp){
		if($tr ne ""){push(@comcds,$tr);}}}
             else{$l=~s/[A-Za-z]//g;$l=~s/\/\=\"\"//g;
		if($l ne ""){ push(@cds,$l);}  }
             }
	if($l=~/^ORIGIN/)
	{		while($ll=<F>)
			{
			
			$ll=~s/[0-9]//g;
			$ll=~s/\s+//g;
			#$ll=~s/" "//;
			#print $ll;
			chomp $ll;
			$line.=$ll;
			}#$line=~s/\s+//;$line=~s/" "//;
	}
}
#print $line;
#print @cds;
print @comcds;
