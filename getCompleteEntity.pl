#!/usr/bin/perl -w
# ChEBI webservices version 1.1
# SOAP::Lite version 0.67
# Please note: ChEBI webservices uses document/literal binding

use SOAP::Lite + trace => qw(debug);
#use SOAP::Lite;

# Setup service
my $WSDL = 'http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl';
my $nameSpace = 'http://www.ebi.ac.uk/webservices/chebi';
my $soap = SOAP::Lite
   -> uri($nameSpace)
   -> proxy($WSDL);

# Setup method and parameters
my $method = SOAP::Data->name('getCompleteEntity')
                       ->attr({xmlns => $nameSpace});
my @params = ( SOAP::Data->name(chebiId => 'CHEBI:15377'));

# Call method
my $som = $soap->call($method => @params);

# Retrieve for example all ChEBI identifiers for the ontology parents
@stuff = $som->valueof('//OntologyParents//chebiId');
print @stuff;
