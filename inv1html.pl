########################################################################
# SGMLSPL script produced automatically by the script sgmlspl.pl
#
# Document Type: inv1html.pl (for HTML/CSS formatting)
# Edited by: mg (24 Aug 98)
########################################################################

use SGMLS;                      # Use the SGMLS package.
use SGMLS::Output;              # Use stack-based output.

#
# Document Handlers.
#
sgml('start', "<HTML>\n<HEAD>\n" .
              "<TITLE> Invitation (sgmlpl/CSS formatting) </TITLE>\n" .
              "<LINK href=\"invit.css\" rel=\"style-sheet\" type=\"text/css\">\n" .
              "<!-- 24 August 1998 mg -->\n" .
              "</HEAD>\n");
sgml('end', "</HTML>");

#
# Element Handlers.
#

sgml('<invitation>', "<BODY>\n<H1>INVITATION</H1>\n");
sgml('</invitation>', "</BODY>\n");

sgml('<front>', "<P><TABLE>\n<TBODY>\n");
sgml('</front>', "</TBODY>\n</TABLE>\n");

sgml('<to>', "<TR><TD class=\"front\">To: </TD>\n<TD>");
sgml('</to>', "</TD></TR>\n");
 
sgml('<date>', "<TR><TD class=\"front\">When: </TD>\n<TD>");
sgml('</date>', "</TD></TR>\n");

sgml('<where>', "<TR><TD class=\"front\">Venue: </TD>\n<TD>");
sgml('</where>', "</TD></TR>\n");

sgml('<why>', "<TR><TD class=\"front\">Occasion: </TD>\n<TD>");
sgml('</why>', "</TD></TR>\n");

sgml('<body>', "");
sgml('</body>', "");

sgml('<par>', "<P>");
sgml('</par>', "</P>\n");

sgml('<emph>', "<EM>");
sgml('</emph>', "</EM>");

sgml('<back>', "");
sgml('</back>', "");

sgml('<signature>', "<P CLASS=\"signature\">");
sgml('</signature>', "</P>\n");

sgml('start_element',sub { die "Unknown element: " . $_[0]->name; });
sgml('cdata',sub { output $_[0]; });

1;
