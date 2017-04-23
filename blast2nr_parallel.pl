  use strict;
  use warnings;
  use lib '/scratch/misc/parallel';
  use LWP::Simple;
  use Parallel::ForkManager;
  system("ls -1 *.fas > list.tmp");
  my $command="blastcl3";
#  my $genome="NC_010336.fna";
  my @tasks;
  open(F,"list.tmp");
  while(<F>){chomp;push(@tasks,$_);}
  close F;  
  my $tasksize= @tasks;
  print "There are #  $tasksize \n";
  my $pm = new Parallel::ForkManager($tasksize); 
  my $cnter=0;
  foreach my $task (@tasks) {
    $cnter++;
    print "Running $command -p blastn -d nr -i $task -o $task.$command.out  #  $cnter \n";
    $pm->start and next; 
    system("$command -p blastn -d nr -i $task -o $task.$command.out");
    $pm->finish; 
  }
  $pm->wait_all_children;


