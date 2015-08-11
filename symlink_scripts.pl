#!perl
use strict;

my %symlink_scripts = ('bp_bulk_load_gff.pl' => 'bp_pg_bulk_load_gff.pl');
my $dir = "C:\Perl\bin";
foreach my $target ( keys ( %symlink_scripts ) ) {
    unlink "$dir/".$symlink_scripts{$target} if -e "$dir/".$symlink_scripts{$target};
    # place symlink in eval to catch error on systems that don't allow symlinks
    eval { symlink( "$dir/$target", "$dir/".$symlink_scripts{$target} ); 1} 
        or print STDERR "Cannot create symbolic link named $dir/"
            . $symlink_scripts{$target}
            . " on you system for $dir/$target\n";
}

