#! perl -w

#
# Builds an HTML file and a bunch of GIF files from a Metapost file
# Also creates a PS file
#
# (c) Vincent Zoonekynd <zoonek@math.jussieu.fr>
# August 1999
# modified in august 2001
# distributed under the GPL
#

$main = $ARGV[0] || "examples";
$main =~ s/\.mp$//i;

# On crée les images GIF
# BUG : à chaque fois qu'il y a des fontes, ça plante.
# C'est normal pour deux raisons :
#  - si j'utilisais prologuse:=2, il ne trouverait pas les fontes.
#  - Comme j'utilise prologues:=0, c'est encore pire...
# L'idéal serait de créer un fichier LaTeX pour chaque fichier postscript,
# de lancer later puis dvips dessus et de récupérer le fichier postscript.

# 1. Compile the examples

system "TEX=latex mpost --interaction=nonstopmode $main";

# 2. Create a LaTeX file encompassing the examples and compile it

open(LATEX,'>', "$main.tex") || die "Cannot open examples.tex for writing: $!";
print LATEX '\documentclass[a4paper]{article}' ."\n";
print LATEX '\usepackage{graphicx}' ."\n";
print LATEX '\begin{document}' ."\n";
print LATEX '\begin{verbatim}' ."\n";
open(MP, "<", "$main.mp") || die "cannot open $main.mp for reading: $!";
while(<MP>){
  if (m/^\s*beginfig\s*\((.*)\)/) {
    print LATEX '\end{verbatim}' . "\n";
    print LATEX "\\includegraphics{${main}_$1.mps}\n";
    print LATEX '\begin{verbatim}' . "\n";
    print LATEX $_;
  } elsif (m/^\s*endfig/) {
    print LATEX $_;
    print LATEX '\end{verbatim}' ."\n";
    print LATEX '\hrulefill' . "\n";
    print LATEX '\begin{verbatim}' . "\n";
  } else {
    print LATEX $_;
  }
}
print LATEX '\end{verbatim}' . "\n";
print LATEX '\end{document}' ."\n";
close MP;
close LATEX;

opendir(DIR,"./") || die "Cannot open ./ directory for reading : $!";
foreach $file (readdir DIR) {
  if ($file =~ m/^$main.[0-9]+$/) {
    my $new = $file;
    $new =~ s/\./_/g;
    $new .= ".mps";
    symlink $file, $new;
  }
}
closedir(DIR);

system "latex    --interaction=nonstopmode $main.tex";
system "dvips -o $main.ps $main.dvi";
#system "pdflatex --interaction=nonstopmode $main.tex";

# 3. Create the GIF pictures

opendir(DIR,"./") || die "Cannot open ./ directory for reading : $!";
foreach $file (readdir DIR) {
  if ($file =~ m/^$main.[0-9]+$/) {
    
    ## Création du fichier PS
    symlink "$file", "$file.eps";
    open(TEX,">$file.tex") || die "cannot open $file.tex for writing : $!";
    print TEX '\nonstopmode'                                          ."\n" ;
    print TEX '\documentclass[a4paper,10pt]{article}'                 ."\n" ;
    print TEX '\usepackage[T1]{fontenc}\usepackage[latin1]{inputenc}' ."\n" ;
    print TEX '\usepackage{graphicx,amsmath,amssymb}'                 ."\n" ;
    print TEX '\pagestyle{empty}'                                     ."\n" ;    
    print TEX '\begin{document}'                                      ."\n" ;
    print TEX '\includegraphics{'. "$file.eps" .'}'                   ."\n" ;
    print TEX '\end{document}'                                        ."\n" ;
    close TEX;
    system "latex $file.tex";
    system "dvips -E -f $file.dvi -o $file.ps";
    
    ## Transformation en GIF
    my ($bbx,$bby,$bbw,$bbh);
    open(PS,"$file.ps");
    while (<PS>) {
      if (/^%%BoundingBox:\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)/) {
        $bbx = 0-$1;    $bby = 0-$2;
        $bbw = $3+$bbx;    $bbh = $4+$bby;
#	print "*** Seen BBOX\n";
      }
      last if /^%%EndComments/;
    }
    close(PS);

    my $scale = 3;
    my $density = 72*$scale;
    $bbw = $scale * $bbw;
    $bbh = $scale * $bbh;
#    print "*** gs -q -dNOPAUSE -dNO_PAUSE -sDEVICE=ppmraw -g${bbw}x${bbh} -r$density -sOutputFile=$file.ppm\n";
    open(GS, "|gs -q -dNOPAUSE -dNO_PAUSE -sDEVICE=ppmraw -g${bbw}x${bbh} -r$density -sOutputFile=$file.ppm");
    print GS "$bbx $bby translate\n";
    print GS "($file.ps) run\n";
    print GS "showpage\n";
    print GS "quit\n";
    close(GS);

    system("pnmcrop $file.ppm | ppmquant 256 | ppmtogif > $file.gif");

    unlink "$file.ppm";
  }
}


# 4. Create the HTML file
open(MP,"$main.mp") || die "cannot open $main.mp for reading: $!";
open(HTML,">$main.html") || die "cannot open $main.html for writing: $!";
select HTML;
print "<HTML><HEAD><TITLE>Metapost : exemples</TITLE></HEAD><BODY>\n";
print "<H1> Métapost : exemples </H1>\n";
print "<HR><PRE>\n";
while(<MP>){
  if (m/^\s*beginfig\s*\((.*)\)/) {
    print "</PRE><IMG SRC=\"$main.$1.gif\"><PRE>\n";
    print ;
  } elsif (m/^\s*endfig/) {
    print;
    print "</PRE><HR><PRE>\n";
  } else {
    print;
  }
}
print "</PRE>\n";
print "</BODY></HTML>\n";
close HTML;  
close MP;  

# 5. Remove unnecessary files

opendir(DIR,"./") || die "Cannot open ./ directory for reading : $!";
foreach $file (readdir DIR) {
  if ($file =~ m/^$main.[0-9]+$/) {
    unlink $file;
    unlink "$file.tex";
    unlink "$file.dvi";
    unlink "$file.aux";
    unlink "$file.log";
    unlink "$file.eps";
    unlink "$file.ps";
    my $new = $file;
    $new =~ s/\./_/g;
    $new .= ".mps";
    unlink $new;
  } elsif( $file =~ m/\.mpx$/ ) {
    unlink $file;
  }
}
closedir DIR;
unlink "$main.aux";
unlink "$main.log";

