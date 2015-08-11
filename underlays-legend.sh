#!/bin/sh
annot=${1:?}

echo '%!PS-Adobe-3.0 EPSF-3.0'
echo '%%BoundingBox: 0 0 612 792'

# for color definitions
pmps -procset

cat <<!
DOTPLOT begin
[/PageMode /UseOutlines /DOCVIEW pdfmark
[/Title (underlays legend) /Dest [{ThisPage} /FitB] /OUT pdfmark

/legend_pt 16 def
/legend_sp 18 def
/Helvetica findfont legend_pt scalefont setfont
/legend_x 64 def
/legend_y 700 def
/nl {/legend_y legend_y legend_sp sub def legend_x legend_y moveto}def
nl
!

mkunderlays $annot | 
perl -an \
     -e 'BEGIN { print "Black (Underlays legend) show nl nl\n"; }' \
     -e 'next unless /^%c/; $c = $F[1]; $n = $F[2];' \
     -e 'print "$c (\267\267)show Black ( $n : $c)show nl\n";'

echo end
echo showpage
