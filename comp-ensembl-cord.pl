# An example script demonstrating the use of BioMart API.
# This perl API representation is only available for configuration versions >=  0.5 
use strict;
use lib '/home/ash022/Desktop/bac2fish/biomart-perl/lib';
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;

my $confFile="/home/ash022/Desktop/bac2fish/biomart-perl/biomart.conf";
#
# NB: change action to 'clean' if you wish to start a fresh configuration  
# and to 'cached' if you want to skip configuration step on subsequent runs from the same registry
#

my $action='cached';
my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
my $registry = $initializer->getRegistry;

my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');

		
	$query->setDataset("drerio_gene_ensembl");
#	$query->addAttribute("ensembl_transcript_id");
	#$query->setDataset("hsapiens_gene_ensembl");
	$query->addFilter("ensembl_gene_id", ["ENSDARG00000042995","ENSDARG00000079210"]);
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("fugu_ensembl_gene");


$query->formatter("CSV");

my $query_runner = BioMart::QueryRunner->new();
############################## GET COUNT ############################
# $query->count(1);
# $query_runner->execute($query);
# print $query_runner->getCount();
#####################################################################


############################## GET RESULTS ##########################
# to obtain unique rows only
# $query_runner->uniqueRowsOnly(1);

$query_runner->execute($query);
$query_runner->printHeader();
$query_runner->printResults();
$query_runner->printFooter();
#####################################################################

