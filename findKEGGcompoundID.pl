use Bio::KEGG::API;

    my $api = Bio::KEGG::API->new();
	print $api->database_info(database => 'hsa');
	
__END__

curl "http://cactus.nci.nih.gov/chemical/structure/(9Z,12Z,15Z)-Octadeca-9,12,15-trienoic%20acid/smiles"	
grep "^C" smiles* | awk -F ':' '{print $2}' > s.txt
