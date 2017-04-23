#!/usr/bin/env perl
# ======================================================================
# Example ChEBI client using XML::Compile::SOAP
#
# See:
# http://www.ebi.ac.uk/chebi/webServices.do
# http://www.ebi.ac.uk/Tools/webservices/tutorials/perl
# ======================================================================

# Enable Perl warnings
use strict;
use warnings;

# XML::Compile::SOAP modules
use XML::Compile::WSDL11;
use XML::Compile::Transport::SOAPHTTP;
# Dumper for Perl objects
use Data::Dumper;

# ChEBI WSDL
my $WSDL = 'http://www.ebi.ac.uk/webservices/chebi/2.0/webservice?wsdl';
# Trace flag. Values >1 enable printing of SOAP messages
my $traceFlag = 0;

# Process command-line options
if (scalar(@ARGV)<1) {
    &printUsage;
    exit(0);
}
my $action = $ARGV[0];
my $query = $ARGV[1];
my $category = 'ALL';

# Create service proxy for web service
my $wsdlXml = XML::LibXML->new->parse_file($WSDL);
my $soapSrv = XML::Compile::WSDL11->new($wsdlXml);
# Compile all service methods
my (%soapOps);
foreach my $soapOp ($soapSrv->operations) {
    $soapOps{$soapOp->{operation}} = $soapSrv->compileClient($soapOp->{operation});
}

# Define variables for the responses.
my ($response, $trace);

# Perform a serach and get a result summary
if($action eq 'getLiteEntity') {
	($response, $trace) = $soapOps{'getLiteEntity'}->(
		parameters => {
			'search' => $query,
			'searchCategory' => $category
		}
	);
	if($traceFlag > 0) {&printTrace($trace);} # SOAP message trace
	if($response->{'Fault'}) { # Check for server/SOAP fault
    	die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	my $resultList = $response->{'result'}->{'return'}->{'ListElement'};
	foreach my $result (@$resultList) {
		print $result->{'chebiId'}, "\t", $result->{'chebiAsciiName'}, "\n";
	}
}
# Get a ChEBI entry
elsif($action eq 'getCompleteEntity') {
	($response, $trace) = $soapOps{'getCompleteEntity'}->(
		parameters => {
			'chebiId' => $query,
		}
	);
	if($traceFlag > 0) {&printTrace($trace);} # SOAP message trace
	if($response->{'Fault'}) { # Check for server/SOAP fault
    	die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	print Dumper($response->{'result'}->{'return'});
}
# Get the parents of a ChEBI term
elsif($action eq 'getOntologyParents') {
	($response, $trace) = $soapOps{'getOntologyParents'}->(
		parameters => {
			'chebiId' => $query,
		}
	);
	if($traceFlag > 0) {&printTrace($trace);} # SOAP message trace
	if($response->{'Fault'}) { # Check for server/SOAP fault
    	die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	print Dumper($response->{'result'}->{'return'});
}
# Get the children of a ChEBI term
elsif($action eq 'getOntologyChildren') {
	($response, $trace) = $soapOps{'getOntologyChildren'}->(
		parameters => {
			'chebiId' => $query,
		}
	);
	if($traceFlag > 0) {&printTrace($trace);} # SOAP message trace
	if($response->{'Fault'}) { # Check for server/SOAP fault
    	die "Server fault: " . $response->{'Fault'}->{'faultstring'};
	}
	print Dumper($response->{'result'}->{'return'});
}
# Unknown action
else {
	die "Error: unknown action $action";
}

# Print request/response trace
sub printTrace($) {
    $trace->printTimings;
    $trace->printRequest;
    $trace->printResponse;
}

# Usage message
sub printUsage() {
    print <<EOF
Usage: $0 <action> <query>

Examples:
  $0 getLiteEntity water
  $0 getCompleteEntity CHEBI:15377
  $0 getOntologyParents CHEBI:15377
  $0 getOntologyChildren CHEBI:15377

For more information see:
http://www.ebi.ac.uk/chebi/webServices.do
http://www.ebi.ac.uk/Tool/webservices/tutorials/perl

EOF
;
}
