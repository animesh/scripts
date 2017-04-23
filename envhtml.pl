#!/usr/bin/perl -w
use strict;
use diagnostics;

print "Content-type:text/html\n\n";

print "<html><head><title>ENV Variables</title></head>
<body bgcolor=\"#ffffff\" text=\"#000000\">
<h1>ENV Variables</h1><hr>
Environment Variables [ENV]<P>\n";

foreach my $ele (keys (%ENV)) {
	print "[$ele]\t$ENV{$ele}<BR>\n";
}

print "</body></html>";
exit;

