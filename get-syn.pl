# An example script demonstrating the use of BioMart API.
# This perl API representation is only available for configuration versions >=  0.5 
use strict;
use lib '/media/DATA/tariku/biomart/lib';
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;

my $confFile =  '/media/DATA/tariku/biomart/biomart.conf';
#my $confFile = "PATH TO YOUR REGISTRY FILE UNDER biomart-perl/conf/. For Biomart Central Registry navigate to 				http://www.biomart.org/biomart/martservice?type=registry";

#
# NB: change action to 'clean' if you wish to start a fresh configuration  
# and to 'cached' if you want to skip configuration step on subsequent runs from the same registry
#

my $action='cached';
#my $action='clean';
my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
my $registry = $initializer->getRegistry;

my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');

		
	$query->setDataset("drerio_gene_ensembl");
	$query->addFilter("chromosome_name", ["2"]);
	$query->addFilter("end", ["51889996"]);
	$query->addFilter("start", ["51689996"]);
#	$query->addFilter("chromosome_name", ["1"]);
#	$query->addFilter("marker_end", ["51689996"]);
#	$query->addFilter("marker_start", ["1"]);
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("ensembl_transcript_id");
	$query->addAttribute("medaka_ensembl_gene");
	$query->addAttribute("medaka_homolog_ensembl_peptide");
	$query->addAttribute("medaka_orthology_type");
	$query->addAttribute("gaculeatus_ensembl_gene");
	$query->addAttribute("gaculeatus_homolog_ensembl_peptide");
	$query->addAttribute("gaculeatus_orthology_type");
	$query->addAttribute("human_ensembl_gene");
	$query->addAttribute("human_homolog_ensembl_peptide");
	$query->addAttribute("human_orthology_type");
	$query->addAttribute("chromosome_name");

$query->formatter("TSV");

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

