#!/usr/bin/perl
#>625E1AAXX100810:1:100:10000:10271/1
#>SOLEXA16:0008:2:1:1138:15204#0/1
while ($line = <>) {
                chomp ($line);
                @tmp=split(/\:|\#|\//,$line);
                if ($line =~ /^>/){
                   $libstring="@tmp[1]";
                   $template=$libstring."_@tmp[4]_@tmp[5]";
                   if($line=~/1$/){$dir="F";$name="F".$template}
                   else{$dir="R";$name="R".$template}
                   print ">$name\ttemplate=$template\tdir=$dir\tlibrary=$libstring\n";
                 }
                 else {print "$line\n";}
}


