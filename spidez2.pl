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

system ("ls -1 > t");
open F,"t";
$date=time();
#$fsd=$fs.".down.".$date;
#system("mkdir $fsd");
while($l = <F>){
	chomp $l;
	if($l =~ /html$/){
	open FF,$l;#print $l;
		while($ll=<FF>){
			if ($ll =~ /http\:\/\//)
			{
			@temp=split(/\s+/,$ll);
			#print "$l\t$ll\t$_\n";
			foreach (@temp) { $_ =~ s/\s+//g;
					if ($_ =~ /^href\=/)
					{$_ =~ s/href\=//g;
					
					}
					$_ =~ s/href\=//g;$_ =~ s/HREF\=//g;$_ =~ s/src\=//g;
					print "$_\n";
					if ($_ =~ /^http\:\//) {
						#print "$l\t$ll\t$_\n";
						}
					}
		
			}
		}
	}
}
close F;
