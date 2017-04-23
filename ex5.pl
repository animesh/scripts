#!/usr/bin/perl -I../../core

use TAP::Client;    
TAP::Abbrev::LoadNamespaces("namespaces.txt");

my $tap = new TAP::Client("http://tap.stanford.edu/data/");  

my $city = new TAP::Resource("tap:City"); 
my $answer = $tap->GetResourcesNamed("Paris", $city); 

for (my $n = 0; $n < $answer->count; $n++) { 
    print "$n) ".($answer->item)[$n]->value."\n";    
}
# This should print out http://tap.stanford.edu/tap/CityParis,_France and 
# http://tap.stanford.edu/tap/CityParisTX

