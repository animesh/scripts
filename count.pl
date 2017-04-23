          use CGI;

          open (OUT,">>test.out") || die;
          $records = 5;
          foreach (0..$records) {
              my $q = new CGI;
              $q->param(-name=>'counter',-value=>$_);
              $q->save(OUT);
          }
          close OUT;

          # reopen for reading
          open (IN,"test.out") || die;
          while (!eof(IN)) {
              my $q = new CGI(IN);
              print $q->param('counter'),"\n";
          }