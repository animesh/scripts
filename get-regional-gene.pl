use strict;
use lib '/scratch/bac2fish/ensembl/modules';
use lib '/scratch/bac2fish/BioPerl-1.6.1';
use Bio::EnsEMBL::Registry;
my $file=shift @ARGV;
open(F,$file);
open(FO,">$file.genelist.txt");
my $cover=100000;
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
my @namef=split(/\./,$file);
my $genome=shift @ARGV;
if(@namef[0] eq "GA"){$genome="Gasterosteus aculeatus"};
if(@namef[0] eq "OL"){$genome="Oryzias latipes"};
if(@namef[0] eq "MM"){$genome="Mus musculus"};
if(@namef[0] eq "HS"){$genome="Homo sapiens"};
if(@namef[0] eq "RN"){$genome="Rattus norvegicus"};
if(@namef[0] eq "TR"){$genome="Takifugu rubripes"};
if(@namef[0] eq "TN"){$genome="Tetraodon nigroviridis"};
if(@namef[0] eq "DR"){$genome="Danio rerio"};
my $line;
my $gn;
my $tgcnt;
my $ttcnt;
while($line=<F>){
	chomp $line;
	my @tmp=split(/\t/,$line);
	my $chr=@tmp[0];
	my $chr1s=@tmp[4]-$cover/2;
	if($chr1s<1){$chr1s=1;}
	my $chr2e=@tmp[5]+$cover/2;
		$gn++;
		#print "$gn\t$file\t$genome\t$chr\t$chr1s\t$chr2e\n";
		print "$gn\t$chr\t$chr1s\t$chr2e\t";
			($tgcnt,$ttcnt)=GA($chr,$chr1s,$chr2e);
		print "\tG:$tgcnt\tT:$ttcnt\t:HitNo:@tmp[0]\n";
}


sub GA{ my $chr=shift;
	my $chrs=shift;
	my $chre=shift;
	my @db_adaptors = @{ $registry->get_all_DBAdaptors() };
	my $slice_adaptor = $registry->get_adaptor( $genome, 'Core', 'Slice' );
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $chrs,$chre );
	my $gene_adaptor = $registry->get_adaptor( $genome , 'Core', 'Gene' );
	my $transcript_adaptor = $registry->get_adaptor( $genome, 'Core', 'Transcript' );

	my @genes = @{ $slice->get_all_Genes() };
	my $genecount;
	my $tcnall;
	foreach my $gene (@genes) {
		$genecount++;
		my $gname=feature2string($gene);
		print "GENE ($genecount) : ",$gname,"\t";
		print_DBEntries( $gene->get_all_DBEntries() );
		my $transcripts = $gene->get_all_Transcripts();
		my $tcn;
		while ( my $transcript = shift @{$transcripts} ) {
			my $stable_id = $transcript->stable_id();
			$tcn++;
			print "TRANSCRIPT ($tcn) : $stable_id\t"; 
			my $transcript = $transcript_adaptor->fetch_by_stable_id($stable_id);
			my $translation = $transcript->translation();
			if($translation){
				my $pfeatures = $translation->get_all_ProteinFeatures();
				while ( my $pfeature = shift @{$pfeatures} ) {
				    my $logic_name = $pfeature->analysis()->logic_name();
				    #print $pfeature->idesc(),"\t",$logic_name,"\t";
				    printf(
					"%d-%d %s %s %s\t",
					$pfeature->start(), $pfeature->end(), $logic_name,
					$pfeature->interpro_ac(),	
					$pfeature->idesc()
				    );
				}
			}
		}
		$tcnall+=$tcn;
	}
	return($genecount,$tcnall);
}

sub print_DBEntries
	{
	    my $db_entries = shift;

	    foreach my $dbe ( @{$db_entries} ) {
		printf "\tXREF %s (%s)\t", $dbe->display_id(), $dbe->dbname();
	    }
}

sub feature2string
	{
	    my $feature = shift;
	    my $abss = $feature->seq_region_start(),
    	    my $abse = $feature->seq_region_end(),
    	    my $absr = $feature->seq_region_strand() ;
	    my $abscord = $feature->coord_system_name();
	    my $stable_id  = $feature->stable_id();
	    my $seq_region = $feature->slice->seq_region_name();
	    my $start      = $feature->start();
	    my $end        = $feature->end();
	    my $strand     = $feature->strand();

	    return sprintf( "%s %s %s : %d-%d (%+d) %d-%d (%+d)",
		$stable_id, $abscord, $seq_region,  $abss, $abse, $absr, $start, $end, $strand );
}

__END__
foreach my $db_adaptor (@db_adaptors) {
    my $db_connection = $db_adaptor->dbc();

    printf(
        "species/group\t%s/%s\ndatabase\t%s\nhost:port\t%s:%s\n\n",
        $db_adaptor->species(),   $db_adaptor->group(),
        $db_connection->dbname(), $db_connection->host(),
        $db_connection->port()
    );
}

