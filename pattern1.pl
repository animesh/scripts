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
@aa=qw/a c d e f g h i k l m n p q r s t v w y x b z/;
print "\nenter the seq. containing fasta file name\t:";
$file=<>;
chomp $file;
open(F,$file)||die "can't open";
print "\nenter the output filename\t:";
$out=<>;
chomp $out;
open (FO,">$out");
print "enter the Prosite Pattern\n";
$ppp=<>;
chomp $ppp;
$motif=$ppp;
$ppp=lc($ppp);
$seq = "";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
		$line=~s/\>//g;
             @seqno=split(/ /,$line);
             push(@seqname,@seqno[0]);
              if ($seq ne ""){$seq=lc($seq);
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
$seq=lc($seq);
push(@seq,$seq);
close $file;
$ppp =~ s/{/[^/g;
$ppp =~ tr/cx}()<>\-\./C.]{}^$/d;
$ppp =~ s/\[G\$\]/(G|\$)/;
#@pp=split(/-/,$patt);
#for($cc=0;$cc<=$#pp;$cc++)
#{
#print "@pp[$cc]\n";
#$ppp=@pp[$cc];
#	if($ppp=~/^[/)
#	{
#	$ppp=~s/[//g;$ppp=~s/]//g;
##		{
#		$l=
##	}
#	elsif($ppp=~/^{/)
#	{
#}
#	else{$l=$l.$ppp;}
#}
for($c=0;$c<=$#seq;$c++)
{
$sequ=@seq[$c];
$seqn=@seqname[$c];
print FO"In sequence\t$seqn\nFound MOTIF \"$motif\"\nAt =>\n";
  while ($sequ =~ /$ppp/g) {
    $posi= (pos $sequ) - length($&) +1;
    $moti = substr($sequ,$posi,length($&));
    print FO"position $posi\tas\t$&\n";
    }
#print "$seqn=>$sequ\n";
}
