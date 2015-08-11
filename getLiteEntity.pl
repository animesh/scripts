#!/usr/bin/perl -w
# ChEBI webservices version 1.1
# SOAP::Lite version 0.67
# Please note: ChEBI webservices uses document/literal binding
use lib '/Home/siv11/ash022/home/cbu/2010/soap/SOAP-Lite-0.710.10/lib';
use SOAP::Lite + trace => qw(debug);

# Setup service
my $WSDL = 'http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl';
my $nameSpace = 'http://www.ebi.ac.uk/webservices/chebi';
my $soap = SOAP::Lite
   -> uri($nameSpace)
   -> proxy($WSDL);

# Setup method and parameters
my $method = SOAP::Data->name('getLiteEntity')
                         ->attr({xmlns => $nameSpace});
my @params = ( SOAP::Data->name(search => 'alpha*'),
               SOAP::Data->name(searchCategory => 'CHEBI NAME'),
               SOAP::Data->name(maximumResults => '200'),
               SOAP::Data->name(stars => 'ALL'));

# Call method
my $som = $soap->call($method => @params);

# Retrieve all the ChEBI names
@stuff = $som->valueof('//ListElement//chebiAsciiName');
print @stuff;
