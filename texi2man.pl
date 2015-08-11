#!/usr/bin/perl -w

# jkb 05/12/95
# Converts our man pages written in TexInfo to troff man format. The texinfo
# versions need to be pretty similar in layout, with the usual NAME,
# DESCRIPTION etc headings. (Further support to be added when and if it's
# required.) Note that it's much easier to convert from texinfo to troff than
# troff to texinfo.
#

$newline=1;
$example=0;
$see_also=0;
$table_mode=0;
$indent="0.5i";
$mansection="1";

sub convert_line {
    if (/^\@c MANSECTION=(.*)/) {
	$mansection="$1";
    }
    # First section (NAME) is parse to find the manual page name. This
    # is needed for the .TH line (which is outputted here).
    if (/^\@(unnumberedsec|section) (.*)/) {
	s/^\@(unnumberedsec|section) (.*)/.SH "$2"\n.PP/;
	if ($2 eq "NAME") {
	    $t="";
	    do {
	        s/^@.*//;
	        s/\@[^ ]*{([^}]*)}/$1/g;
		($_ ne "\n") && ($t .= $_);
	        $_ = <>;
		convert_line();
	    } while (!/ \\- /);
	    /([^ ]*) \\-/;
	    print ".TH \"$1\" $mansection \"\" \"\" \"Staden Package\"\n$t";
	} elsif ($2 eq "SEE ALSO") {
	    $see_also=1;
       	}
    } else {
        s/\\/\\\\/g;
    }
    s/^\@subsection (.*)/.SS "$1"\n.PP/;
    s/^\@unnumberedsubsec (.*)/.SS "$1"\n.PP/;
    s/^\@example/.nf\n.in +$indent/ && ($example=1);
    s/^\@end example/.in -$indent\n.fi/ && ($example=0);

    s/\@strong{([^}]*)}/\\fB$1\\fP/g;
    s/\@code{([^}]*)}/\\fB$1\\fP/g;
    s/\@b{([^}]*)}/\\fB$1\\fP/g;
    s/\@i{([^}]*)}/\\fI$1\\fP/g;
    s/\@var{([^}]*)}/\\fI$1\\fP/g;

    # See also commands, typically as cross references.
    if (/_fxref\(/) {
	if ($see_also) {
	    s/_fxref\([^,]*,[ \t\n]*(([^(]*)([^,]*)),[^)]*\)/\\fB$2\\fR$3/g;
	} else {
	    s/_fxref\([^,]*,[ \t\n]*([^,]*),[^)]*\)/See Section $1./g;
	}
    }

    if ($see_also) {
	s/\@\*//g;
    } else {
        s/\@\*/\n.br\n/g;
    }
    s/ --- / \\- /g;
    s/\@{/{/;
    s/\@}/}/;
    s/\@\@/\@/;

    $example==0 && s/^[ ]*//;

    if (/^\@c TABLE_MODE=(.*)/) {
	$table_mode=$1;
	$_="";
    }

    if (/^\@c INDENT=(.*)/) {
	$indent="$1";
	$_="";
    }

    if (/^\@table/) {
	$_ = <>;
	if ($table_mode == 1) {
	    print ".nf\n";
	} elsif ($table_mode == 2) {
	    print ".PD 0\n";
	}
	do {
	    convert_line();
	
	    if (/^\@item (.*)/) {
		if ($table_mode == 1) {
		    print ".BR $1 ";
		} elsif ($table_mode == 2) {
		    print ".IP $1 13\n";
		} else {
		    print ".TP\n";
		    print "$1\n";
		}
       	    } elsif ($_ eq ".fi") {
		print "$_\n";
	    } elsif ($_ ne "") {
		if ($table_mode == 1) {
		    s/\n//;
		    print "\"  $_\"\n";
	        } else {
		    print;
		}
	    }

	    $_ = <>;
	} while (!/^\@end table/);

	if ($table_mode == 1) {
	    $_ = ".fi"
	} elsif ($table_mode == 2) {
	    $_ = ".sp\n.PD"
	} else {
	    $_ = ".TE";
	}
    }
}

while (<>) {
    # Skip menus
    if (/^\@menu/) {
	while (!/^\@end menu/) {
	    $_ = <>;
	}
    }

    # Skip TeX commands
    next if (/^\\/);

    # Convert tables
#    if (/^\@table/) {
#	print ".TS\ntab(\t);\nl l.\n";
#	$_ = <>;
#	do {
#	    convert_line();
#	
#	    if (/^\@item (.*)/) {
#		print "$1\t";
#	    } else {
#		print "$_";
#	    }
#
#	    $_ = <>;
#	} while (!/^\@end table/);
#
#	$_ = ".TE";
#    }

    # Convert all other line types
    convert_line();

    # Strip out any remaining texinfo commands
    s/^@.*//;
    s/\@[^ ]*{([^}]*)}/$1/g;

    # Output the man commands.
    if (!$example && $_ eq "\n") {
 	$newline++;
    } else {
	$newline=0;
    }

    ($newline < 2) && print;
}
