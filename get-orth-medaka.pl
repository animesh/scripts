# An example script demonstrating the use of BioMart API.
# This perl API representation is only available for configuration versions >=  0.5 
use lib '/scratch/bac2fish/biomart-perl/lib';
use lib '/scratch/bac2fish/XML-Simple-2.18/lib';
use lib '/scratch/bac2fish/Log-Log4perl-1.23/lib';
use lib  '/scratch/bac2fish/Exception-Class-1.29/lib';
use lib  '/scratch/bac2fish/Class-Data-Inheritable-0.08/lib';
# An example script demonstrating the use of BioMart API.
# This perl API representation is only available for configuration versions >=  0.5 
use strict;
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;

my $confFile = "PATH TO YOUR REGISTRY FILE UNDER biomart-perl/conf/. For Biomart Central Registry navigate to
						http://www.biomart.org/biomart/martservice?type=registry";
#
# NB: change action to 'clean' if you wish to start a fresh configuration  
# and to 'cached' if you want to skip configuration step on subsequent runs from the same registry
#

my $action='cached';
my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
my $registry = $initializer->getRegistry;

my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');

		
	$query->setDataset("olatipes_gene_ensembl");
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("fugu_ensembl_gene");
	$query->addAttribute("gaculeatus_ensembl_gene");
	$query->addAttribute("tetraodon_ensembl_gene");
	$query->addAttribute("zebrafish_ensembl_gene");

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
use lib  '/Home/siv11/ash022/bin//lib/perl5/5.10.0/i386-linux-thread-multi/';
use lib  '/scratch/bac2fish/Devel-StackTrace-1.20/lib';
use lib  '/scratch/bac2fish/Readonly-1.03';

use strict;
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;
        my $confFile="/scratch/bac2fish/biomart-perl/biomart.conf";
#
# NB: change action to 'clean' if you wish to start a fresh configuration  
# and to 'cached' if you want to skip configuration step on subsequent runs from the same registry
#

my $action='cached';
my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
my $registry = $initializer->getRegistry;

my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');

		
	$query->setDataset("trubripes_gene_ensembl");
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("medaka_ensembl_gene");
	$query->addAttribute("zebrafish_ensembl_gene");
	$query->addAttribute("tetraodon_ensembl_gene");
	$query->addAttribute("gaculeatus_ensembl_gene");

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

