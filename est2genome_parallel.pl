  use strict;
  use warnings;
  use lib '/scratch/misc/parallel/Parallel';
  use LWP::Simple;
  use Parallel::ForkManager;
  system("ls -1 *.fas > list.tmp");
  my $command="est2genome";
  my $genome="NC_010336.fna";
  my @tasks;
  open(F,"list.tmp");
  while(<F>){chomp;push(@tasks,$_);}
  close F;  
  my $tasksize= @tasks;
  print "There are #  $tasksize \n";
  my $pm = new Parallel::ForkManager($tasksize); 
  foreach my $task (@tasks) {
    $pm->start and next; 
    system("$command $task $genome $task.$genome.out");
    $pm->finish; 
  }
  $pm->wait_all_children;


