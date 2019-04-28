  use strict;
  use warnings;
  use lib '/usit/titan/u1/ash022/';
  use lib '/xanadu/home/ash022/libwww-perl-5.832/lib';
  use lib '/xanadu/home/ash022/URI-1.40';
  use LWP::Simple;
  use Parallel::ForkManager;
  #system("ls -1 *.fas > list.tmp");
  #my $command="est2genome";
  #my $genome="NC_010336.fna";
  my @tasks;
  my $tasksize= 16;
  #open(F,"list.tmp");
  #while(<F>){chomp;push(@tasks,$_);}
  #close F;  
 for(my $c=1;$c<=720;$c+=$tasksize){
  print "There are #  $tasksize from $c \n";
  my $pm = new Parallel::ForkManager($tasksize); 
   for(my $task=$c;$task<$c+$tasksize;$task++) {
    $pm->start and next; 
    system("/work/1341743.d/Dwgs6dhmcod/1-overlapper/overlap.sh $task");
    $pm->finish; 
  }
  $pm->wait_all_children;
}

