#!/usr/bin/perl
use strict;

use lib '/home/ash022/Desktop/bac2fish/biomart-perl/lib';
my $fugufile="bacfugu.int.txt";
my $medakafile="bacmedaka.int.txt";
my $sticklefile="bacstickle.int.txt";
my $tetrafile="bactetraodon.int.txt";
my $zffile="baczf.int.txt";

#my $fugufile="t1";
#my $medakafile="t2";
#my $sticklefile="t3";
#my $tetrafile="t4";
#my $zffile="t5";
openfile($fugufile,"trubripes_gene_ensembl");
openfile($medakafile,"olatipes_gene_ensembl");
openfile($sticklefile,"gaculeatus_gene_ensembl");
openfile($tetrafile,"tnigroviridis_gene_ensembl");
openfile($zffile,"drerio_gene_ensembl");
my %bactag;
my %baccont;
my %transcont;
my %bacavgsep;


sub openfile {
	my $file=shift;
	my $data_set=shift;
	#my $afile="a".$file;
	my %genecont;
	my $line;
	open(F,$file);
	#my @{$file};
	while($line=<F>){
		my %uniqgene;
		my %uniqtrans;
		chomp $line;
		my @afile=split(/\s+/,$line);
		my @dist=split(/\-/,$afile[5]);
		my $len=abs($dist[1]-$dist[0]);
		if($len<150000){
		$bactag{$afile[1]}++;
		$bacavgsep{$afile[1]}+=$len;
		my $c;
		for ($c=0;$c<=$#afile;$c++) {
			if($afile[$c] eq "GENE" and $afile[$c+3] ne ""){
				$genecont{$afile[1]}.="$afile[$c+3],";
				$uniqgene{$afile[$c+1]}++;
			}
			if($afile[$c]=~/[a-z|A-Z|0-9]*\_[a-z|A-Z|0-9]*/){
				$transcont{$afile[1]}.="$afile[$c],";
				$uniqtrans{$afile[$c]}++;
			}
		}
		$baccont{$afile[1]}.="$file-$len-$afile[6]-$afile[2]-$afile[4]-$afile[-3]-$afile[-2]-";
		#foreach(keys %uniqgene){$baccont{$afile[1]}.="$_:$uniqgene{$_}-";}
		#foreach(keys %uniqtrans){$baccont{$afile[1]}.="$_:$uniqtrans{$_}-";}
		$baccont{$afile[1]}.="$genecont{$afile[1]}\t";
		#print "$file\t$afile[1]\n";
		}
	}
}

foreach (sort {$bactag{$b}<=>$bactag{$a}} keys %bactag){
	print "$_\t$bactag{$_}\t$baccont{$_}\t$bacavgsep{$_}\t",$bacavgsep{$_}/5,"\n";#\t$genecont{$_}\t$transcont{$_}\n";
}

__END__
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
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("fugu_ensembl_gene");
	$query->addAttribute("ensembl_transcript_id");
	$query->addAttribute("medaka_ensembl_gene");
	$query->addAttribute("gaculeatus_ensembl_gene");
	$query->addAttribute("tetraodon_ensembl_gene");


############################## GET RESULTS ##########################
# to obtain unique rows only
# $query_runner->uniqueRowsOnly(1);

$query_runner->execute($query);
$query_runner->printHeader();
$query_runner->printResults();
$query_runner->printFooter();
#####################################################################

