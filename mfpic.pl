#
#  mfpic.pl [-r <res>] [-m <mode>] <file>
#
use Getopt::Long;

GetOptions("r=i", \$res, "m=s", \$mode);
$file = shift;
$res = 600 unless ($res>0);
$mode = "ljfour" unless ($mode);

system("mf \\mode=$mode; input $file");
system("gftopk $file.${res}gf $file.pk");
system("copy $file.pk ".
  "c:\\texmf\\fonts\\pk\\$mode".
  "\\public\\misc\\dpi$res");
