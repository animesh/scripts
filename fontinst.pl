# fontinst.pl
foreach $file (<*.pl>)
{ ($filename) = $file =~ /(\w+)\.pl/;
  system("pltotf $file $filename.tfm");
}
foreach $file (<*.vpl>)
{ ($filename) = $file =~ /(\w+)\.vpl/;
  system("vptovf $file $filename.vf $filename.tfm");
}
