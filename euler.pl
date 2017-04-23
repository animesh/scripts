#source http://stackoverflow.com/questions/4031325/finding-eulerian-path-in-perl
use strict;
use warnings;
use Data::Dumper;
use Carp;


my %graphs = ( 1 => [2,3], 2 => [1,3,4,5], 3 =>[1,2,4,5], 4 => [2,3,5], 5 => [2,3,4]);
my @path = eulerPath(%graphs);


sub eulerPath {

    my %graph = @_;

    # count the number of vertices with odd degree
    my @odd = ();
    foreach my $vert ( sort keys %graph ) {
        my @edg = @{ $graph{$vert} };

        my $size = scalar(@edg);
        if ( $size % 2 != 0 ) {
            push @odd, $vert;
        }
    }

    push @odd, ( keys %graph )[0];

    if ( scalar(@odd) > 3 ) {
        return "None";

    }

    my @stack = ( $odd[0] );
    my @path  = ();

    while (@stack) {
        my $v = $stack[-1];
	#suggestion http://stackoverflow.com/a/4031608
        if ( @{$graph{$v}} ) {
        	my $u = ( @{ $graph{$v} } )[0];
		push @stack, $u;

            # Find index of vertice v in graph{$u}

            my @graphu = @{ $graph{$u} };  # This is line 54.
            my ($index) = grep $graphu[$_] eq $v, 0 .. $#graphu;
	    #suggestion http://stackoverflow.com/a/4031608
            splice @{ $graph{$u} }, $index, 1;
            splice @{ $graph{$v} }, 0, 1;

        }
        else {

            push @path, pop(@stack);
        }

    }

    print Dumper \@path;

    return @path;
}

