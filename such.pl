# such.pl <lst-file> <dateiname>
# liefert liste aller INCLUDE/INPUT-texfiles und
# durchsucht diese ebenfalls nach
# - listinginput, includegraphics

$out = ">" . shift;
open(OUT,$out) || die "cannot open $out: $!";
while (<>)
{ if (eof) { print OUT "$ARGV\n"; }
  # \include{file}
  if (m/^\\include\{(\w+)\}/)
    { print "$1 included as TeX in $ARGV\n";
      unshift(ARGV, $1.".tex");
    }
  # \input file
  if (m/^\\input (\w+)/)
    { print "$1 included via \input in $ARGV\n";
      unshift(ARGV, $1.".tex");
    }
  # \listininput{n}{file}
  if (m/^\\listinginput\{\d+\}\{([\w\.]+)\}/)
    { print OUT "$1\n";
      print "$1 included in $ARGV\n";
    }
  # \includegraphics[opt]{file}
  if (m/^\\.*\\includegraphics(\[.+\])*\{([\w\.]+)\}/)
    { print "$2 included as graphics\n";
      print OUT "$2\n";
    }
  # \showpage{file}
  if (m/\\showpage\{([\w\.]+)\}/)
    { print "$1 included as graphics in showpage\n";
      print OUT "$1\n";
    }
  # \requirefile{file}
  if (m/^%\\requirefile\{([\w\.]+)\}/)
    { print OUT "$1\n";
      print "$1 included in $ARGV (aux file)\n";
    }
}
close(OUT);
