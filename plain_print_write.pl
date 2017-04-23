#!/usr/bin/perl -w

use strict;

require "files/camelid_links.pl";
my %camelid_links = get_camelid_data();

print qq|<?xml version="1.0">\n<html>\n<body>\n|;
foreach my $item ( keys (%camelid_links) ) {
    print qq|<a href="$camelid_links{$item}->{url}">$camelid_links{$item}->{description}</a>\n|;
}
print qq|</body>\n</html>\n|;
