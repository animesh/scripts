#!/usr/bin/env perl
# ======================================================================
# Example ENFIN client using SOAP::Lite
#
# See:
# http://www.enfin.org/encore/wsdl/enfin-picr.wsdl
# ======================================================================
# Enable Perl warnings
use strict;
use warnings;
use lib '/Home/siv11/ash022/home/cbu/2010/soap/SOAP-Lite-0.710.10/lib';
 
# SOAP::Lite module
use SOAP::Lite;
 
# Debugging (optional)
#SOAP::Lite->import(+trace => qw(debug));
 
# Services location
my $picrHost = 'http://www.ebi.ac.uk/enfin-srv/encore/picr/service';
 
# Namespaces
my $picrNameSpace = 'http://ebi.ac.uk/enfin/core/web/services/picr';
 
# Input message
my $message = '
<entries>
    <entry>
        <molecule id="ID1">
            <xrefs>
                <primaryRef refTypeAc="MI:0358" refType="primary-reference" id="ENSP00000376345" dbAc="MI:0476" db="Ensembl"/>
            </xrefs>
            <moleculeType termAc="MI:0326" term="Protein"/>
        </molecule>
        <set id="ID2">
            <participant moleculeRef="ID1"/>
        </set>
        <experiment id="ID3">
            <result>ID2</result>
        </experiment>
        <parameter term="IdCounter" factor="4"/>
    </entry>
</entries>
';
 
############################################################
# "enfi-picr" service
############################################################
 
# Prepare the input message
$message =~ s/\t|\r|\n//g; # Merge the xml in one line
$message =~ s/<entries/<entries xmlns=\"http:\/\/ebi.ac.uk\/enfin\/core\/model\"/; # Add the model namespace
my $query = SOAP::Data->type('xml' => $message); #Format the message as SOAP XML
 
# Create the service proxy and define a fault handler
my $soap = SOAP::Lite
    ->uri($picrNameSpace)
    ->proxy($picrHost)
    ->outputxml('true')
;
 
# Perform a query. Look for the methods available inside the WSDL file, in portType operations.
my $soapEnvelope = $soap->map2UniProt($query);
 
# Display the envelope with the result
#print $soapEnvelope;
 
# Get result
my $startEntries = "<entries";
my $endEntries = "</entries>";
 
my @entries = split(/$startEntries/, $soapEnvelope);
@entries = split(/$endEntries/, $entries[1]);
 
my $result = $startEntries . $entries[0] . $endEntries;
 
# Print the result
print $result;

