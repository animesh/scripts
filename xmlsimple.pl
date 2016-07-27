use strict;
use warnings;
use XML::Simple;
use Data::Dumper;

my $f = shift @ARGV;
my $d = XMLin($f);
print $f,$d;
print Dumper($d);

foreach my $p (keys %{$d->{P}}) {
	print $p . ' is ' . $d->{P}->{$p}->{A} . "\n";
}

__END__
http://perlmeme.org/tutorials/parsing_xml.html
 perl -MCPAN -e 'install XML::Simple'
 wget http://lncrnadb.com/rest/all/sequence
 perl xmlsimple.pl sequence
 