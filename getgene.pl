use strict;
use lib '/home/ash022/Desktop/bac2fish/ensembl/modules';
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);

my @db_adaptors = @{ $registry->get_all_DBAdaptors() };
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', '20', 1e6, 2e6 );
my $gene_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Gene' );
#my $gene = $gene_adaptor->fetch_by_display_label('COG6');
#print "GENE ", $gene->stable_id(), "\n";
#print_DBEntries( $gene->get_all_DBEntries() );

my @genes = @{ $slice->get_all_Genes() };
foreach my $gene (@genes) {
	my $gname=feature2string($gene);
	print $gname,"\t";
	print_DBEntries( $gene->get_all_DBEntries() );
	print $gene->get_all_DBEntries(),"\n";
}

sub print_DBEntries
{
    my $db_entries = shift;

    foreach my $dbe ( @{$db_entries} ) {
        printf "\tXREF %s (%s)\n", $dbe->display_id(), $dbe->dbname();
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
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', 'X', 1e6, 10e6 );

my $genes = $slice->get_all_Genes();
while ( my $gene = shift @{$genes} ) {
    my $gstring = feature2string($gene);
    print "$gstring\n";

    my $transcripts = $gene->get_all_Transcripts();
    while ( my $transcript = shift @{$transcripts} ) {
        my $tstring = feature2string($transcript);
        print "\t$tstring\n";

        foreach my $exon ( @{ $transcript->get_all_Exons() } ) {
            my $estring = feature2string($exon);
            print "\t\t$estring\n";
        }
    }
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

