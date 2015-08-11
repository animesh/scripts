use strict;
use warnings;
my $file=shift @ARGV;
open F, "$file" or die "Can't open $file : $!";

while(my $l=<F>){
	chomp $l;
        $l=~s/\r//g;
        my @t=split(/,/,$l);
        print $t[0];
}


__END__

perl genloc.pl testmod.csv

email: sharma.animesh@gmail.com


perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412Selected.csv /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv > /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412SelectedChromoPos.csv
perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412Selected.csv /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv > /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412SelectedChromoPos.csv
perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.csv /cygdrive/x/Elite/Aida/SSwCLREP/Uniprot2Entrez.csv > /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv
perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412Selected.csv /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv > /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412SelectedChromoPos.csv
perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412Selected.csv /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv > /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412SelectedChromoPos.csv
perl matchlist.pl /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412Selected.csv /cygdrive/x/Elite/Aida/SSwCLREP/CCDS.20131024GI.UP2E.csv > /cygdrive/x/Elite/Aida/SSwCLREP/MQv1412SelectedChromoPos.csv
