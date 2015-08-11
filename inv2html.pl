########################################################################
# SGMLSPL script produced automatically by the script sgmlspl.pl
#
# Document Type: inv2html.pl (for HTML/CSS formatting)
# Edited by: mg (25 Aug 1998)
########################################################################

use SGMLS;                      # Use the SGMLS package.
use SGMLS::Output;              # Use stack-based output.

#
# Document Handlers.
#
sgml('start', sub {
    output "<HTML>\n<HEAD>\n";
    output "<TITLE> Invitation (sgmlpl/CSS formatting) </TITLE>\n";
    output "<LINK href=\"invit.css\" rel=\"style-sheet\" type=\"text/css\">\n";
    output "<!-- 24 August 1998 mg -->\n";
    output "</HEAD>\n";
});
sgml('end', "</HTML>");

#
# Element Handlers.
#

# Element: invitation
sgml('<invitation>', sub { 
   my ($element,$event) = @_;
   # First save the information for further use 
   #  Local variables
   my $date  = $element->attribute('date')->value;
   my $to    = $element->attribute('to')->value;
   my $where = $element->attribute('where')->value;
   my $why   = $element->attribute('why')->value;
   #  Global variable (saved for end of document)
   $main::GLsig   = $element->attribute('signature')->value;
   # Output the HTML commands needed for the front matter
   output "<BODY>\n<H1>INVITATION</H1>\n";
   output "<P><TABLE>\n<TBODY>\n";
   output "<TR><TD class=\"front\">To: </TD>\n<TD>$to</TD></TR>\n";
   output "<TR><TD class=\"front\">When: </TD>\n<TD>$date</TD></TR>\n";
   output "<TR><TD class=\"front\">Venue: </TD>\n<TD>$where</TD></TR>\n";
   output "<TR><TD class=\"front\">Occasion: </TD>\n<TD>$why</TD></TR>\n";
   output "</TBODY>\n</TABLE>\n";
});

sgml('</invitation>', sub{ # signature and end of document
     output "<P CLASS=\"signature\">$main::GLsig</P>\n";
     output "</BODY>\n";
});

# Elements: par and emph
sgml('<par>', "<P>");
sgml('</par>', "</P>\n");

sgml('<emph>', "<EM>");
sgml('</emph>', "</EM>");

sgml('cdata',sub { output $_[0]; });
1;
