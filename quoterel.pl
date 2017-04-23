#!/usr/local/bin/perl
# recursive flip to unix, pc, or mac EOL's
# codes:             1    2      3

$outmode = 1;
$dirsok = 1;
undef %abbrev;
$abbrevfile="../shabbquote.dat";

open(IN,"<$abbrevfile") || die "no abbrev file";
while (<IN>) {
  chop;
  ($key,$abbrev)=split(':',$_);
  $abbrev{$key}=$abbrev;
#  print STDOUT "$key:$abbrev{$key}\n";
}
close(IN);

while ($rg = shift(@ARGV)) {
  if (-f $rg) {&flipme($rg,$outmode);}
  elsif (-d $rg) {
    if ($dirsok == 0) {
      print STDERR "\nOK to recurse into directories (e.g., $rg)? [y/n] ";
      $lin = <STDIN>;
      $lin =~ tr/A-Z/a-z/;
      if ($lin =~ m/^y/) {$dirsok = 1;}
    }
    if ($dirsok == 1) {&dodir($rg,$outmode);}
  }
  else {print STDERR "\nUnknown argument $rg";}
}

sub dodir {
  local ($dirin,$outmode) = @_;
  local ($file,$glob);
  print STDOUT "directory ::$dirin::\n";
  $glob = "$dirin/*";
  foreach $file (<${glob}>) {
    if (-d $file) {&dodir($file,$outmode);}
    if (-f $file) {&flipme($file,$outmode);}
  }
}

sub flipme {
  local ($filename,$outmode) = @_;
  @felms = split('/',$filename);
  $nlev = $#felms - 1 ;
  $dots = "../" x $nlev;
  print STDOUT "  file ::$filename::...";
  if ($filename =~ m/\.gif/) {
    print STDOUT "SKIPPING\n";
    return 0;
  }
#  print STDOUT "\n";
#  return 0;
  open(IN,"<$filename") || die "Can't open $filename for reading\n";
#  binmode(IN);
  ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,
      $ctime,$blksize,$blocks) = stat($filename);
  unlink("/tmp/shakerelink.tmp");
  open(OUT, ">/tmp/shakerelink.tmp") ||
     die "Can't open /tmp/shakerelink.tmp for writing\n";
#  binmode(OUT);
  while (<IN>) {
    s/HREF=/HREFF=/gi;
#    if ((m/href=/) || (m/HREFF=\"/)) {
#      print STDOUT $_
#    }
    chop;
    while (m/^(.*)HREFF=\"([^"#]+)(["#].*)$/) {
      $front=$1; $ref=$2; $back=$3;
# here is where we convert $ref
# get rid of cgi-bin garbage
     $ref =~ s/cgi-bin\/redirect\/shaksper\///;
     $ref =~ s/\.html/\.htm/;
     $ref =~ s/\/\.([0-9]+)/#$1/;
     foreach $kkey (keys(%abbrev)) {
        $lley = $abbrev{$kkey};
        $ref =~ s/$kkey\/$kkey/$lley\/$lley/;
     }
     if ($ref =~ m/http:/) { } else {
      @felds = split('/',$ref);
      $bare=pop(felds);
      $geld="";
      foreach $feld (@felds) {
        $sad = $feld;
        $feld =~ m/([a-z]+)([0-9]*)/;
        $feldkey = $1; $feldrest=$2;
        if (defined($abbrev{$feldkey})) {$sad=$abbrev{$feldkey}.$feldrest;}
        $geld .= "$sad/";
      }
      @felss = split('\.',$bare);
      $ending=pop(felss);
      $gels="";
      foreach $fels (@felss) {
        $sad = $fels;
        if (defined($abbrev{$fels})) {$sad=$abbrev{$fels};}
        $gels .= "$sad";
      }
      if (defined($abbrev{$ending})) {$ending=$abbrev{$ending};}
      $newname="$geld$gels.$ending";
      $newname =~ tr/A-Z/a-z/;
      $newname =~ s/\/shaksper\//$dots/;
      $ref=$newname;
     }
# end conversion of $ref
      $_ = $front . 'HREF="' . $ref . $back;
      print STDOUT "    $ref\n";
    }
#  if (m/HREF=/) {print STDOUT "$_\n"};
  s/HREFF=/HREF=/;
  print OUT "$_\n";
  }
  close(IN);
  close(OUT);
  unlink $filename;
  system("mv /tmp/shakerelink.tmp $filename");
  utime($atime, $mtime, $filename);
  print STDOUT "done\n";
}
