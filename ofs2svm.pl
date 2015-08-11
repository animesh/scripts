#!/usr/bin/perl
# ofs2svm.pl     sharma.animesh@gmail.com

use warnings;
use strict;
$|=1;
use Data::Dumper;


my $file=shift;
my $ftr=shift;
my $fo=$file.".svm.out";

open(F,$file);
open(FO,">$fo");


while(my $l=<F>){
    my @t=split(/\s+/,$l);
    for(my $c=1;$c<=$ftr;$c++){
	print @t[-$c]," ";
        if($t[-$c]==1){
	    print "Class:",$c," ";
	    print FO"$c\t";
	}
    }
    print "\n";
    for(my $c=0;$c<=($#t-$ftr);$c++){
	print FO$c+1,":",$t[$c],"\t";
    }
    print FO"\n";
    
}


__END__

=head1 NAME

ofs2svm.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for ofs2svm.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

, E<lt>animesh<gt>

=head1 COPYRIGHT AND LICENSE


This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
