#!/usr/bin/perl -w
use strict;
use XML::Simple qw(:strict);
use LWP::UserAgent;
use Data::Dumper;

# Create a user agent
my $ua = LWP::UserAgent->new();
# Construct URL for entry
my $url = 'http://www.ebi.ac.uk/Tools/picr/rest/getMappedDatabaseNames';



# Perform the request
my $response = $ua->get($url);
# Check for HTTP error codes
if($response->code < 200 || $response->code > 399) {
    die 'http status: ' . $response->code . ' ' . $response->message;
}

# Parse the entry 
# Note: ForceArray is set to true so that single nested elements are still placed in arrays.

my $xmlRef = XMLin($response->content(), ForceArray => 1, KeyAttr => []);

#print Dumper $xmlRef;

my $databaseNameArrayRef = $xmlRef->{mappedDatabases};
foreach (@$databaseNameArrayRef){
	print "$_\n";
}


