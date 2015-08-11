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

open(F,"Table.txt");
open(FOA,">Table.ath.txt");
open(FOG,">Table.ghi.txt");
my %t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
    );

while($l=<F>){
	$line++;
	if($line<=2){next;}
	chomp $l;
	@t=split(/ /,$l);
	$aac{@t[0]}.="\t@t[1]";
	@t2=split(/\(|\)/,@t[2]);
	$aauath{@t[0]}.="\t@t2[0]";
	$aaughi{@t[0]}.="\t@t[7]";
	$aauaths{@t[0]}+="\t@t2[0]";
	$aaughis{@t[0]}+="\t@t[7]";
}

foreach $aa (keys %aac) {
	$val=$aauath{$aa};
	$val=~s/^\s+|\s+$//g;
	@t=split(/\t/,$val);
	for($c=0;$c<=$#t;$c++){
		$normval=@t[$c]/$aauaths{$aa};
		$aauathsn{$aa}.="\t$normval";
	}
	$val=$aaughi{$aa};
	$val=~s/^\s+|\s+$//g;
	@t=split(/\t/,$val);
	for($c=0;$c<=$#t;$c++){
		$normval=@t[$c]/$aaughis{$aa};
		$aaughisn{$aa}.="\t$normval";
	}
}

foreach $aa (keys %aac) {
	$codath=$aac{$aa};
	$codath=~s/^\s+|\s+$//g;
	$codghi=$aac{$aa};
	$codghi=~s/^\s+|\s+$//g;
	$valath=$aauathsn{$aa};
	$valath=~s/^\s+|\s+$//g;
	$valghi=$aaughisn{$aa};
	$valghi=~s/^\s+|\s+$//g;
	@tath=split(/\t/,$valath);
	@tghi=split(/\t/,$valghi);
	@tcath=split(/\t/,$codath);
	@tcghi=split(/\t/,$codghi);
	for($c=0;$c<=$#tath;$c++){
		$perath=sprintf("%.3f", (@tath[$c]));
		$normath=sprintf("%d", (100*@tath[$c]));
		$perghi=sprintf("%.3f", (@tghi[$c]));
		$normghi=sprintf("%d", (100*@tghi[$c]));
		$olcaa=$t2o{uc($aa)};
		if($aa ne ""){
			print FOA"@tcath[$c]\t$olcaa\t$perath\t$perath\t$normath\n";
			print FOG"@tcghi[$c]\t$olcaa\t$perghi\t$perghi\t$normghi\n";
		}
	}
}

