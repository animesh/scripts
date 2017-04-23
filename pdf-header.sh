#!/bin/sh
cat <<'end-of-file'

%%BeginProcSet: pdf-support 1.0 0.0
/languagelevel where {pop languagelevel} {1} ifelse
2 lt {
  userdict (<<) cvn ([) cvn load put
  userdict (>>) cvn (]) cvn load put
} if

/pdfmark where
{pop}
{userdict /pdfmark /cleartomark load put}
ifelse

/currentdistillerparams where
{pop}
{userdict /currentdistillerparams {1 dict} put}
ifelse

/setdistillerparams where
{pop}
{userdict /setdistillerparams {pop} put}
ifelse

% << /CompressPages false /CompatibilityLevel 1.3 >> setdistillerparams

[ /_objdef {afields} /type /array /OBJ pdfmark
[ /_objdef {aform} /type /dict /OBJ pdfmark
[ {aform} <<
  /Fields {afields}
  /DR << /Font << >> >>
  /DA (/Helv 12 Tf 0 g)
  /NeedAppearances true
  >>
/PUT pdfmark

[ {Catalog} << /AcroForm {aform} >> /PUT pdfmark

%%EndProcSet

