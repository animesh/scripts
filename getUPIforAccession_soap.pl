#!/usr/bin/perl -w

use lib '/Home/siv11/ash022/home/cbu/2010/picr/SOAP-Lite-0.710.10/lib';
use SOAP::Lite;
#use SOAP::Lite +trace => 'debug';
use Data::Dumper;

my $accession = shift @ARGV;
#my $accession = 'P29375';
my $accession_version = '3';

my $nameSpace="http://www.ebi.ac.uk/picr/AccessionMappingService";

$soap = SOAP::Lite
	-> service('http://www.ebi.ac.uk/Tools/picr/service?wsdl')
	-> proxy('http://www.ebi.ac.uk:80/Tools/picr/service')
	-> readable(1)
	-> on_fault(sub { # SOAP fault handler
		    my $soap = shift;
		    my $res = shift;
		    # Map faults to exceptions
		    if(ref($res) eq '') {
		        die($res);
		    } else {
		        die($res->faultstring);
		    }
		    return new SOAP::SOM;
		}
	);

my $method = SOAP::Data	->name('picr:getUPIForAccession')
						->attr({'xmlns:picr' => $nameSpace});
						
my @params = (  SOAP::Data	->name("picr:accession" => $accession)
							->type("xsd:string"),
				SOAP::Data	->name("picr:ac_version" => $accession_version)
							->type("xsd:string"),
				SOAP::Data	->name("picr:searchDatabases" => 'SWISSPROT')
							->type("xsd:string"),
				SOAP::Data	->name("picr:searchDatabases" => 'TREMBL')
							->type("xsd:string"),
				SOAP::Data	->name("picr:searchDatabases" => 'ENSEMBL_HUMAN')
							->type("xsd:string"),
				SOAP::Data	->name("picr:searchDatabases" => 'EMBL')
							->type("xsd:string"),
				SOAP::Data	->name("picr:taxonId" => '9606')
							->type("xsd:string"),
				SOAP::Data	->name("picr:onlyActive" => 1)
							->type("xsd:boolean"));

# Call method
my $som = $soap->call($method => @params);

#print "\n$som\n";

#print Dumper $som->paramsall;
	
my $upiEntryArrayHash = $som->paramsall;

# UPI Entry
#print Dumper "$soap\n";
print "UniParc Entry:\n";
print "$accession maps to UniParc entry ". $upiEntryArrayHash->{"UPI"}. "\n\n";

sub printIdenticalCrossRef {
	my $myref = shift;
	print "\tIdentical Cross Reference:\n";
	print "\tAccession ". $myref->{"accession"};
	print " from database ". $myref->{"databaseName"} . "\n";
}

sub printLogicalCrossRef {
	my $myref = shift;
	print "\tLogical Cross Reference:\n";
	#print "\tAccession ". $myref->{"accession"};
	#print " from database ". $myref->{"databaseName"} . "\n";
}
__END__
# Identical Cross References
my $identicalCrossRefRef = $upiEntryArrayHash->{"identicalCrossReferences"};
if (ref($identicalCrossRefRef) eq 'ARRAY'){ 
	foreach (@$identicalCrossRefRef){
		&printIdenticalCrossRef($_);
	}
}
else {
	&printIdenticalCrossRef($identicalCrossRefRef);
}

# Logical Cross References
my $logicalCrossRefRef = $upiEntryArrayHash->{"logicalCrossReferences"};
if (ref($logicalCrossRefRef) eq 'ARRAY'){
foreach (@$logicalCrossRefRef){
	&printLogicalCrossRef($_);
}
}
else {
	&printLogicalCrossRef($logicalCrossRefRef);
}


