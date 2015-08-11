#!/usr/bin/perl
$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
                $snames=@seqn[0];$snames=~s/>//;1/1;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);close F;
for($c1=0;$c1<=$#seq;$c1++)
{
	$sequ=@seq[$c1];
	$snam=@seqname[$c1];
	$lent=length($sequ);
	print "$snam\n$lent\n";
}
