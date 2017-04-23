print "Initial probabilities:\n";
foreach $state (sort keys %pi) {
  print "P($state)=$pi{$state}\n";
}

print "\n\nEmission probabilities:\n";
foreach $state (sort keys %b) {
  foreach $sym (sort keys %{$b{$state}}) {
    print "P($sym|$state)=$b{$state}{$sym}\n";
  }
}

print "\n\nTransition probabilities:\n";
foreach $oldstate (sort keys %a) {
  foreach $newstate (sort keys %{$a{$oldstate}}) {
    print "P($newstate|$oldstate)=$a{$oldstate}{$newstate}\n";
  }
}