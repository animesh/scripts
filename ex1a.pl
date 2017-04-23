#!/usr/bin/perl -I../../core

use TAP::Client;   

my $tap = new TAP::Client("http://tap.stanford.edu/data/"); 
my $answer = $tap->GetData("http://tap.stanford.edu/data/CitySanFranciscoCA",
                           "http://tap.stanford.edu/data/hasAirportCode");
print $answer->value."\n";  # This should print out "SFO"

