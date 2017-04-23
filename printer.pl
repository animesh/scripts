#!/usr/bin/env perl

# Some tests for 'darcs printer (the output formating)'

use lib qw(lib/perl);

BEGIN {
    use Test::More;
    if ($] < 5.008) {
        plan( skip_all => "sufficient UTF support may not be present under this Perl version ($])");
    }
    else {
        plan('no_plan')
    }
}


use Test::Darcs;
use Shell::Command;

use strict;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';

touch 'a';
darcs 'add a';
darcs 'rec -a -A a -m add';


# clear all output formating environment variables
for (qw/
        DARCS_DONT_ESCAPE_ISPRINT
        DARCS_USE_ISPRINT
        DARCS_DONT_ESCAPE_8BIT
        DARCS_DONT_ESCAPE_EXTRA
        DARCS_ESCAPE_EXTRA
        DARCS_DONT_ESCAPE_TRAILING_SPACES
        DARCS_DONT_COLOR
        DARCS_ALWAYS_COLOR
        DARCS_ALTERNATIVE_COLOR
        DARCS_DONT_ESCAPE_ANYTHING
    /) {
    delete $ENV{$_};
}

# make sure the locale is c

$ENV{LC_ALL} = "C";


sub test_line {
    my ($test_name, $instr, $outstr) = @_;

    rm_f 'a';
    open(STUPIDFILE, ">:encoding(iso-8859-1)", "a");
    print STUPIDFILE "$instr";
    close(STUPIDFILE);
    like(darcs('whatsnew'), $outstr, $test_name);
}


# First check escaping and coloring.  Use whatsnew, since that is the
# most common use of escapes.

# test the defaults
# - no color to pipe
# - don't escape 7-bit ASCII printables, \n,\t and space (we can't test \n)
# - escape control chars with ^
# - escape other chars with \xXX

test_line('tab, space and ascii printables are not escaped (1/4)',
          " !#%&',-0123456789:;<=>",
          qr/ !#%&',-0123456789:;<=>/
         );
test_line('tab, space and ascii printables are not escaped (2/4)',
          "ABCDEFGHIJKLMNOPQRSTUVWXYZ_",
          qr/ABCDEFGHIJKLMNOPQRSTUVWXYZ_/
         );
test_line('space and ascii printables are not escaped (3/4)',
          "`abcdefghijklmnopqrstuvwxyz",
          qr/`abcdefghijklmnopqrstuvwxyz/
         );
test_line('tab, space and ascii printables are not escaped (4/4)',
          "\t\"\$()*+./?\@[\\]^{|}",
          qr/\t"\$\(\)\*\+\.\/\?\@\[\\\]\^\{\|\}/
         );

# skip ^@ and ^Z since they make darcs treat the file as binary
# don't put any space control chars at end of line

test_line('ascii control chars are escaped with ^ (1/3)',
          "\x01\x02\x03\x04\x05\x06\x07\x08\x0B\x0C\x0D\x0E",
          qr/\[_\^A_\]\[_\^B_\]\[_\^C_\]\[_\^D_\]\[_\^E_\]\[_\^F_\]\[_\^G_\]\[_\^H_\]\[_\^K_\]\[_\^L_\]\[_\^M_\]\[_\^N_\]/
         );
test_line('ascii control chars are escaped with ^ (2/3)',
          "\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19",
          qr/\[_\^O_\]\[_\^P_\]\[_\^Q_\]\[_\^R_\]\[_\^S_\]\[_\^T_\]\[_\^U_\]\[_\^V_\]\[_\^W_\]\[_\^X_\]\[_\^Y_\]/
         );

test_line('ascii control chars are escaped with ^ (3/3)',
          "\x1B\x1C\x1D\x1E\x1F\x7F",
          qr/\[_\^\[_\]\[_\^\\_\]\[_\^\]_\]\[_\^\^_\]\[_\^__\]\[_\^\?_\]/
         );

test_line('other chars are escaped with \xXX (1/8)',
          "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F",
          qr/\[_\\80_\]\[_\\81_\]\[_\\82_\]\[_\\83_\]\[_\\84_\]\[_\\85_\]\[_\\86_\]\[_\\87_\]\[_\\88_\]\[_\\89_\]\[_\\8a_\]\[_\\8b_\]\[_\\8c_\]\[_\\8d_\]\[_\\8e_\]\[_\\8f_\]/
         );
test_line('other chars are escaped with \xXX (2/8)',
          "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F",
          qr/\[_\\90_\]\[_\\91_\]\[_\\92_\]\[_\\93_\]\[_\\94_\]\[_\\95_\]\[_\\96_\]\[_\\97_\]\[_\\98_\]\[_\\99_\]\[_\\9a_\]\[_\\9b_\]\[_\\9c_\]\[_\\9d_\]\[_\\9e_\]\[_\\9f_\]/
         );
test_line('other chars are escaped with \xXX (3/8)',
          "\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF",
          qr/\[_\\a0_\]\[_\\a1_\]\[_\\a2_\]\[_\\a3_\]\[_\\a4_\]\[_\\a5_\]\[_\\a6_\]\[_\\a7_\]\[_\\a8_\]\[_\\a9_\]\[_\\aa_\]\[_\\ab_\]\[_\\ac_\]\[_\\ad_\]\[_\\ae_\]\[_\\af_\]/
         );
test_line('other chars are escaped with \xXX (4/8)',
          "\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF",
          qr/\[_\\b0_\]\[_\\b1_\]\[_\\b2_\]\[_\\b3_\]\[_\\b4_\]\[_\\b5_\]\[_\\b6_\]\[_\\b7_\]\[_\\b8_\]\[_\\b9_\]\[_\\ba_\]\[_\\bb_\]\[_\\bc_\]\[_\\bd_\]\[_\\be_\]\[_\\bf_\]/
         );
test_line('other chars are escaped with \xXX (5/8)',
          "\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF",
          qr/\[_\\c0_\]\[_\\c1_\]\[_\\c2_\]\[_\\c3_\]\[_\\c4_\]\[_\\c5_\]\[_\\c6_\]\[_\\c7_\]\[_\\c8_\]\[_\\c9_\]\[_\\ca_\]\[_\\cb_\]\[_\\cc_\]\[_\\cd_\]\[_\\ce_\]\[_\\cf_\]/
         );
test_line('other chars are escaped with \xXX (6/8)',
          "\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF",
          qr/\[_\\d0_\]\[_\\d1_\]\[_\\d2_\]\[_\\d3_\]\[_\\d4_\]\[_\\d5_\]\[_\\d6_\]\[_\\d7_\]\[_\\d8_\]\[_\\d9_\]\[_\\da_\]\[_\\db_\]\[_\\dc_\]\[_\\dd_\]\[_\\de_\]\[_\\df_\]/
         );
test_line('other chars are escaped with \xXX (7/8)',
          "\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF",
          qr/\[_\\e0_\]\[_\\e1_\]\[_\\e2_\]\[_\\e3_\]\[_\\e4_\]\[_\\e5_\]\[_\\e6_\]\[_\\e7_\]\[_\\e8_\]\[_\\e9_\]\[_\\ea_\]\[_\\eb_\]\[_\\ec_\]\[_\\ed_\]\[_\\ee_\]\[_\\ef_\]/
         );
test_line('other chars are escaped with \xXX (8/8)',
          "\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF",
          qr/\[_\\f0_\]\[_\\f1_\]\[_\\f2_\]\[_\\f3_\]\[_\\f4_\]\[_\\f5_\]\[_\\f6_\]\[_\\f7_\]\[_\\f8_\]\[_\\f9_\]\[_\\fa_\]\[_\\fb_\]\[_\\fc_\]\[_\\fd_\]\[_\\fe_\]\[_\\ff_\]/
         );


chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
