use strict;
use lib '/home/ash022/Desktop/bac2fish/ensembl/modules';
use Bio::EnsEMBL::Registry;
my $genome=shift @ARGV;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);

my $line;
my $gn;
my $tgcnt;
my $ttcnt;
my $slice_adaptor = $registry->get_adaptor( $genome , 'Core', 'Slice' );

my @slices = @{ $slice_adaptor->fetch_all('scaffold') };
foreach my $slice (@slices){
	my $coord_sys  = $slice->coord_system()->name();
	my $seq_region = $slice->seq_region_name();
	my $start      = $slice->start();	
	my $end        = $slice->end();
	my $strand     = $slice->strand();
	print ">$coord_sys $seq_region $start-$end ($strand)\n";
	my $sequence = $slice->seq();
	print $sequence, "\n";
}

