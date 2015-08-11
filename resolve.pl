#!/usr/bin/env perl

# Automated tests for "darcs resolve". 

use lib 'lib/perl';
use Test::More qw/no_plan/;
use strict;
use Test::Darcs;
use Shell::Command;

cleanup  'temp1', 'temp2';
mkpath 'temp1';
chdir 'temp1';

like( darcs('init'), qr/^$/i, 'initialized repo');
open(F, ">_darcs/prefs/author") || die;
print F "Tester";
close(F);

open(F, ">child_of_conflict") || die;
print F "Conflict, Base .";
close(F);

darcs("add child_of_conflict");
like( darcs("record -am 'Conflict Base'"), qr/finished/i);
like( darcs("get . ../temp2"), qr/finished/i);

chdir '../';

# Add and record differing lines to both repos
for my $repo (1,2) {
    chdir "temp".$repo;

    open(F, ">child_of_conflict") || die;
    print F "Conflict, Part $repo.";
    close(F);

    like( darcs("record -A author -am 'Conflict Part $repo'"), qr/finished/i);

    chdir '../';
}

chdir './temp1';
my $pull_out = darcs("pull -a ../temp2");
like($pull_out, qr/conflict/i);
like($pull_out, qr/finished/i);

{
    open(F, "<child_of_conflict") || die;
    my $line = <F>;
    close(F);
    like($line, qr/v v/, 'found conflict markers');
}

like( darcs("revert -a"), qr/finished/i, 'conflicts reverted');

{
    open(F, "<child_of_conflict") || die;
    my $line = <F>;
    close(F);
    unlike($line, qr/v v/, 'conflict markers are gone');
}

darcs("resolve");

{
    open(F, "<child_of_conflict") || die;
    my $line = <F>;
    close(F);
    like($line, qr/v v/, 'found conflict markers after revert and resolve');
}







chdir '../';
cleanup 'temp1', 'temp2';




