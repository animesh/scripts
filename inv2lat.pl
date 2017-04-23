########################################################################
# SGMLSPL script produced automatically by the script sgmlspl.pl
#
# Document Type: invitation --> customization for LaTeX
# Edited by: mg (August 14th 1998)
########################################################################

use SGMLS;                      # Use the SGMLS package.
use SGMLS::Output;              # Use stack-based output.

#
# Document Handlers.
#
sgml('start', sub {});
sgml('end', sub {});

#
# Element Handlers.
#

# Element: invitation
sgml('<invitation>', "\\documentclass[]{article}\n" .
                     "\\usepackage{invitation}\n" .
                     "\\begin{document}\n");
sgml('</invitation>', "\\end{document}\n");

# Element: front
sgml('<front>', "\\begin{Front}\n");
sgml('</front>', "\\end{Front}\n");

# Element: to
sgml('<to>', "\\To{");
sgml('</to>', "}\n");
 
# Element: date
sgml('<date>', "\\Date{");
sgml('</date>', "}\n");

# Element: where
sgml('<where>', "\\Where{");
sgml('</where>', "}\n");

# Element: why
sgml('<why>', "\\Why{");
sgml('</why>', "}\n");

# Element: body
sgml('<body>', "\\begin{Body}\n");
sgml('</body>', "\\end{Body}\n");

# Element: par
sgml('<par>', "\\par ");
sgml('</par>', "\n");

# Element: emph
sgml('<emph>', "\\emph{");
sgml('</emph>', "}");

# Element: back
sgml('<back>', "\\begin{Back}\n");
sgml('</back>', "\\end{Back}\n");

# Element: signature
sgml('<signature>', "\\Signature{");
sgml('</signature>', "}\n");
#
# Default handlers 
#
sgml('start_element',sub { die "Unknown element: " . $_[0]->name; });
sgml('cdata',sub { output $_[0]; });
sgml('re'," ");
sgml('pi',sub { die "Unknown processing instruction: " . $_[0]; });
sgml('entity',sub { die "Unknown external entity: " . $_[0]->name; });
sgml('conforming','');

1;
