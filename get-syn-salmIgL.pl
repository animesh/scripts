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
	$query->addFilter("chromosome_name", ["19"]);
	$query->addFilter("end", ["6300000"]);
	$query->addFilter("start", ["6100000"]);
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("ensembl_transcript_id");
	$query->addAttribute("tetraodon_ensembl_gene");
	$query->addAttribute("homolog_tnig__dm_stable_id_4016_r1");
	$query->addAttribute("tetraodon_homolog_ensembl_peptide");
	$query->addAttribute("tetraodon_chromosome");
	$query->addAttribute("tetraodon_chrom_start");
	$query->addAttribute("tetraodon_chrom_end");
	$query->addAttribute("tetraodon_orthology_type");
	$query->addAttribute("tetraodon_homolog_subtype");
	$query->addAttribute("tetraodon_homolog_dn");
	$query->addAttribute("tetraodon_homolog_ds");
	$query->addAttribute("tetraodon_homolog_perc_id");
	$query->addAttribute("tetraodon_homolog_perc_id_r1");
	$query->addAttribute("gaculeatus_ensembl_gene");
	$query->addAttribute("homolog_gacu__dm_stable_id_4016_r1");
	$query->addAttribute("gaculeatus_homolog_ensembl_peptide");
	$query->addAttribute("gaculeatus_chromosome");
	$query->addAttribute("gaculeatus_chrom_start");
	$query->addAttribute("gaculeatus_chrom_end");
	$query->addAttribute("gaculeatus_orthology_type");
	$query->addAttribute("gaculeatus_homolog_subtype");
	$query->addAttribute("gaculeatus_homolog_dn");
	$query->addAttribute("gaculeatus_homolog_ds");
	$query->addAttribute("gaculeatus_homolog_perc_id");
	$query->addAttribute("gaculeatus_homolog_perc_id_r1");
	$query->addAttribute("medaka_ensembl_gene");
	$query->addAttribute("homolog_olat__dm_stable_id_4016_r1");
	$query->addAttribute("medaka_homolog_ensembl_peptide");
	$query->addAttribute("medaka_chromosome");
	$query->addAttribute("medaka_chrom_start");
	$query->addAttribute("medaka_chrom_end");
	$query->addAttribute("medaka_orthology_type");
	$query->addAttribute("medaka_homolog_subtype");
	$query->addAttribute("medaka_homolog_dn");
	$query->addAttribute("medaka_homolog_ds");
	$query->addAttribute("medaka_homolog_perc_id");
	$query->addAttribute("medaka_homolog_perc_id_r1");

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


