use Graph;
	my $g0 = Graph->new;             # A directed graph.

	use Graph::Directed;
	my $g1 = Graph::Directed->new;   # A directed graph.

	use Graph::Undirected;
	my $g2 = Graph::Undirected->new; # An undirected graph.

	$u1="U1";
	$v1="V1";
	$u2="U2";
	$v2="V2";


        $g1->add_vertex($u1);
        $g1->add_vertex($v1);
        $g1->add_edge($u1,$v1);
        $g1->add_vertex($u2);
        $g1->add_vertex($v2);
        $g1->add_edge($u2,$v1);
        $g1->add_edge($u2,$u1);
        $g1->add_edge($u1,$u2);

        #$g1->vertices();
        #$g1->edges();

	print "The graph is $g1	\n"



