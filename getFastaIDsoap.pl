#!/usr/bin/perl -w
use lib '/Home/siv11/ash022/home/cbu/2010/picr/SOAP-Lite-0.710.10/lib';
use SOAP::Lite +trace => 'debug';
use Data::Dumper;
my $ff= shift @ARGV;
open FASTA, $ff or die "Cannot open fasta file.";

my $fasta;

while (<FASTA>){
	$fasta .= $_;
}

close FASTA;

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

my $method = SOAP::Data	->name('picr:getUPIForSequence')
						->attr({'xmlns:picr' => $nameSpace});
						
my @params = (  SOAP::Data->name("picr:sequence" => $fasta)->type("xsd:string"),
				SOAP::Data->name("picr:searchDatabases" => 'SWISSPROT')->type("xsd:string"),
				SOAP::Data->name("picr:searchDatabases" => 'TREMBL')->type("xsd:string"),
				SOAP::Data->name("picr:searchDatabases" => 'ENSEMBL_HUMAN')->type("xsd:string"),
				SOAP::Data->name("picr:taxonId" => '9606')->type("xsd:string"),
				SOAP::Data->name("picr:onlyActive" => 1)->type("xsd:boolean"));

# Call method
my $som = $soap->call($method => @params);

print Dumper $som->paramsall;
	
my $upiEntryArrayHash = $som->paramsall;

# UPI Entry
#print "UniParc Entry:\n";
#print "The sequence maps to UniParc entry ". $upiEntryArrayHash->{"UPI"}. "\n\n";

sub printIdenticalCrossRef {
	my $myref = shift;
	print "\tIdentical Cross Reference:\n";
	print "\tAccession ". $myref->{"accession"};
	print " from database ". $myref->{"databaseName"} . "\n";
}

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



