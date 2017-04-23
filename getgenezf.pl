use strict;
use lib '/home/ash022/Desktop/bac2fish/ensembl/modules';
use Bio::EnsEMBL::Registry;
my $file=shift @ARGV;
open(F,$file);
my $genome=shift @ARGV;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
my $line;
while($line=<F>){
	chomp $line;
	my @tmp=split(/\s+/,$line);
	if(@tmp[14]==@tmp[16]){
		print "@tmp[0]\t@tmp[8]-@tmp[13]\t";
		if(@tmp[8]<@tmp[13]){
			GA(@tmp[14],@tmp[8],@tmp[13]);
		}
		else {
			GA(@tmp[14],@tmp[13],@tmp[8]);
		}
	}
}


sub GA{ my $chr=shift;
	my $chrs=shift;
	my $chre=shift;
	my @db_adaptors = @{ $registry->get_all_DBAdaptors() };
	my $slice_adaptor = $registry->get_adaptor( $genome, 'Core', 'Slice' );
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $chrs,$chre );
	my $gene_adaptor = $registry->get_adaptor( $genome , 'Core', 'Gene' );
	my $transcript_adaptor = $registry->get_adaptor( $genome, 'Core', 'Transcript' );
	#my $gene = $gene_adaptor->fetch_by_display_label('COG6');
	#print "GENE ", $gene->stable_id(), "\n";
	#print_DBEntries( $gene->get_all_DBEntries() );

	my @genes = @{ $slice->get_all_Genes() };
	foreach my $gene (@genes) {
		my $gname=feature2string($gene);
		print $gname,"\t";
		print_DBEntries( $gene->get_all_DBEntries() );
		my $transcripts = $gene->get_all_Transcripts();
		while ( my $transcript = shift @{$transcripts} ) {
			my $stable_id = $transcript->stable_id();
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
		print $gene->get_all_DBEntries(),"\n";
	}
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

	    my $stable_id  = $feature->stable_id();
	    my $seq_region = $feature->slice->seq_region_name();
	    my $start      = $feature->start();
	    my $end        = $feature->end();
	    my $strand     = $feature->strand();

	    return sprintf( "%s: %s:%d-%d (%+d)",
		$stable_id, $seq_region, $start, $end, $strand );
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

