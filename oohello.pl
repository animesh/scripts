#!/usr/local/bin/perl

use CGI;

$query = new CGI;
print $query->header;
print $query->start_html;
print "<H1>hello to the bic class</H1>\n";
print $query->end_html;