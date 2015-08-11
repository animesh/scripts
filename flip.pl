#!/usr/local/bin/perl
# recursive flip to unix, pc, or mac EOL's
# codes:             1    2      3

$outmode = 1;
$dirsok = 0;
@modestring = ("","\012","\015\012","\015");

if ($#ARGV < 0) {print STDERR "Usage: flip.pl [ -u | -p | -m ] file [, file...]
    Flips the EOL convention of a text file to
    UNIX (-u), PC (-p), or Mac (-m)
    Routine will query if OK to recurse when a directory
    is first found in the argument list.
    File access and modification times are preserved.\n";
  exit;}

while ($rg = shift(@ARGV)) {
  if ($rg =~ m/^-u/i) {$outmode = 1;}
  elsif ($rg =~ m/^-p/i) {$outmode = 2;}
  elsif ($rg =~ m/^-m/i) {$outmode = 3;}
  elsif (-f $rg) {&flipme($rg,$outmode);}
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
print STDERR "\n";

sub dodir {
  local ($dirin,$outmode) = @_;
  local ($file,$glob);
  print STDERR "/";
  $glob = "$dirin/*";
  foreach $file (<${glob}>) {
    if (-d $file) {&dodir($file,$outmode);}
    if (-f $file) {&flipme($file,$outmode);}
  }
}

sub flipme {
  local ($filename,$outmode) = @_;
  print STDERR ".";
  undef($/);
  open(IN,"<$filename") || die "Can't open $filename for reading\n";
  binmode(IN);
  $contents = <IN>;
  close(IN);
  $cntm = ($contents =~ tr/\015/\015/);
  $cntj = ($contents =~ tr/\012/\012/);
  $cntx = ($contents =~ tr/\030/\030/);
  if ($cntx > 0) {
    print STDERR "\nSkipping $filename: binary file (contains \\030 chars)";
    return 0;
  }
  if ($cntm > 0 && $cntj == 0) {$inmode = 3;}
  elsif ($cntj > 0 && $cntm == 0) {$inmode = 1;}
  elsif ($cntj > 0 && $cntm == $cntj) {$inmode = 2;}
  else {
    print STDERR "\nSkipping $filename: binary file (not pure text EOLs)";
    return 0;
  }
  if ($inmode == $outmode) {return 0;}
  $contents =~ s/$modestring[$inmode]/$modestring[$outmode]/g;
  ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,
      $ctime,$blksize,$blocks) = stat($filename);
  open(OUT, ">$filename") || die "Can't open $filename for writing\n";
  binmode(OUT);
  print OUT "$contents";
  close(OUT);
  utime($atime, $mtime, $filename);
}
