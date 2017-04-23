#!/usr/bin/env perl

# Some tests for 'darcs changes'

use lib 'lib/perl';
use Test::Darcs;
use Test::More qw/no_plan/;
use strict;
use vars qw/$DARCS/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";

cleanup 'temp1';
`mkdir temp1`;
chdir 'temp1';
`$DARCS init`;

###

my $test_name = 'record something';

`date >> date.t`;
`$DARCS add date.t`;

like(`$DARCS record -A 'Mark Stosberg <a\@b.com>' -a -m foo date.t 2>&1`, qr/finished recording/i, $test_name);

####

like(`$DARCS changes date.t`,qr/foo/,'changes file.txt: trivial case works');
like(`$DARCS changes --last=1 date.t`,qr/foo/,'changes --last=1 file.txt');
like(`$DARCS changes --last=1 --summary date.t`,qr/foo/,'changes --last=1 --summary file.txt');

like(`$DARCS changes --last=1 --xml `,qr/&lt;a\@b.com&gt;/,'changes --last=1 --xml encodes < and >');

###

# Add 50 records and try again 
for (my $i = 0; $i <= 49; $i++) {
    `date >> date.t`;
    `$DARCS record -A x -a -m "foo record num $i" date.t 2>&1`;
}

like(`$DARCS changes date.t`,qr/foo/,'after 50 records: changes file.txt: trivial case works');
like(`$DARCS changes --last=1 date.t`,qr/foo/,'after 50 records: changes --last=1 file.txt');
like(`$DARCS changes --last=1 --summary date.t`,qr/foo/,'after 50 records: changes --last=1 --summary file.txt');

### 

like(`$DARCS changes --context --from-patch="num 1\$" --to-patch="num 4\$"`,
     qr/^\n.*\n\n.*num 4\n.*\n\n.*num 3\n.*\n\n.*num 2\n.*\n\n.*num 1\n.*\n$/,
     'changes --context --from-patch="num 1$" --to-patch="num 4$"');

###

`date >>second_file.t`;
`darcs add second_file.t`;
like(`darcs record -A x -a -m adding_second_file second_file.t 2>&1`, qr/finished recording/i, 'recorded second file');

TODO: {
    local $TODO = 'still a future feature.';
    my $test_name = '--last should mean "last N affecting this file"';
    like(`darcs changes --last=1 date.t`,qr/foo/,$test_name);
}


chdir '../';
`rm -rf temp1`;
ok((!-d 'temp1'), 'temp1 directory was deleted');




