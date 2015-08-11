use strict;
use lib '/media/DATA/tariku/ensembl';
#use lib '/scratch/bac2fish/BioPerl-1.6.1';
use Bio::EnsEMBL::Registry;
my $file=shift @ARGV;
open(F,$file);
open(FO,">$file.seq.fna");
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
#        my $chr1s=@tmp[4]-$cover/2;
#        if($chr1s<1){$chr1s=1;}
#        my $chr2e=@tmp[5]+$cover/2;
	my $chr1s=@tmp[4]+0;
	my $chr2e=@tmp[5]+0;
		$gn++;
		my ($sn,$seq)=GA($chr,$chr1s,$chr2e);
		print "$file\t$gn\t$chr\t$chr1s\t$chr2e\n";
		print FO">$chr\t$file\t$chr1s\t$chr2e\t$gn\t$sn\n$seq\n";
}


sub GA{ 
	my $chr=shift;
	my $chrs=shift;
	my $chre=shift;
	my @db_adaptors = @{ $registry->get_all_DBAdaptors() };
	my $slice_adaptor = $registry->get_adaptor( $genome, 'Core', 'Slice' );
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $chrs,$chre );
	my $gene_adaptor = $registry->get_adaptor( $genome , 'Core', 'Gene' );
	my $transcript_adaptor = $registry->get_adaptor( $genome, 'Core', 'Transcript' );

	my @genes = @{ $slice->get_all_Genes() };
	my $genecount=length(@genes);
        my $coord_sys  = $slice->coord_system()->name();
        my $seq_region = $slice->seq_region_name();
        my $start      = $slice->start();
        my $end        = $slice->end();
        my $strand     = $slice->strand();
        my $seqname="Gene$genecount-Sys$coord_sys\tR:$seq_region-$start-$end($strand)";
        my $sequence = $slice->seq();
	return($seqname,$sequence);
}
