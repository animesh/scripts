#!/usr/bin/env perl

# A test for a missed resolution, inspired by bug #10 in RT

use lib 'lib/perl';
use Test::More qw/no_plan/;
use strict;
use Test::Darcs;
use Shell::Command;

for my $dir (qw/tmp1 tmp2/) {
    cleanup($dir);
    mkpath("$dir/") || die "couldn't mkpath: $!";
    chdir $dir || die;
    darcs 'init';
    chdir '../';
}

sub writeLines {
    my $content = shift;
    open(A,">A");
    print A $content;
    close A;
} 

chdir 'tmp1';
writeLines ("i\n\nm\nb\nv\n");

darcs "add A";
darcs "record -A x -m 'add' --all";

chdir '../tmp2';

darcs "pull --all ../tmp1";
writeLines ("J\ni\n\nC2\n\nm\nD\nb\nv\n");
darcs "record -A me -m 'change2' --all";

chdir '../tmp1';

writeLines ("I\ni\n\nC1\n\nm\nb\n");

darcs "record -A x -m 'change1' --all";

darcs "pull --all ../tmp2";

# we should have a marked conflict now.
# we resolve it simply by removing conflict markers.

# I'm too lazy to translate this to Perl right now. 
`grep -v '\(\^ \^\|\*\*\|v v\)' A > tmp`;
mv('tmp','A');

darcs "record -A x -m 'resolve' --all";

# now resolve shouldn't find any unresolved conflicts
like( darcs('resolve'), qr/No conflicts to resolve/, 'darcs finds no conflicts to resolve');

chdir '../';
for my $dir (qw/tmp1 tmp2/) {
    ok(-d $dir, "$dir exists here");
    cleanup($dir);
    ok((!-d $dir), "$dir directory was deleted");
}





