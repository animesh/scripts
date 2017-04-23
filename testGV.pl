use lib '/usit/titan/u1/ash022/IPC-Run-0.90/lib';;
use lib '/usit/titan/u1/ash022/GraphViz-2.04/lib'; 
      use GraphViz;

      my $g = GraphViz->new();

      $g->add_node('London');
      $g->add_node('Paris', label => 'City of\nlurve');
      $g->add_node('New York');

      $g->add_edge('London' => 'Paris');
      $g->add_edge('London' => 'New York', label => 'Far');
      $g->add_edge('Paris' => 'London');

      print $g->as_png;

