use strict;
use warnings;
use Bio::DB::Taxonomy;  
my $db = Bio::DB::Taxonomy->new(  -source => 'flatfile',
				  -directory => 'taxdmp/',
				  -nodesfile => 'taxdmp/nodes.dmp',
                                  -namesfile => 'taxdmp/names.dmp');
my $name=shift @ARGV;
open(F,$name);
while(<F>) {
my @tmp=split(/\t/);
print "$tmp[0]\t";
my $taxonid = $db->get_taxonid($tmp[0]);
#my $taxon = $db->get_taxon(-taxonid => $taxonid);
#print $taxon->id, "\t";
#print $taxon->scientific_name, "\t";
if (defined $taxonid) {
    my $node = $db->get_Taxonomy_Node(-taxonid => $taxonid);
    my $kingdom = $node;
    for (my $lev=0;$lev<10;$lev++) {
        if(defined  $kingdom->parent_id){
	$kingdom = $db->get_Taxonomy_Node(-taxonid => $kingdom->parent_id);
    	print $kingdom->scientific_name,"\t";}
	else{print "\t";}
    }
}
print "\n";
}
__END__
https://www.biostars.org/p/62911/#62951
