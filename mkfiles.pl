#!/usr/bin/perl
############################################################################
#
# Creates make.files - a list of all source files
#
############################################################################

#
# main - top level code
#

if ( @ARGV ) {				# parse command line args
    print "usage: perl mkfiles.pl\n\n";
    exit 1;
}

$tolower = 0;
@files = &find_files(".","\.*",1);

@codefiles = sort grep(/\.(c|cpp|cc|s|h|hpp|icc|ia)$/i,@files);

print STDERR scalar @codefiles . " files found.\n";

if ( -r "make.exclude" ) {
    open EXCLUDE, "make.exclude" or
        die "make.exclude: $!";
    @exclude = <EXCLUDE>;
    close EXCLUDE;

    for ( @exclude ) {
        chop;
        $ex{lc $_} = 1;
    }

    $excluded = 0;
    for ( @codefiles ) {
        if ( !defined $ex{lc $_} ) {
            push @leftfiles, $_;
        }
        else {
            $excluded++;
        }
    }
    *codefiles = *leftfiles;

    print STDERR $excluded . " files excluded";
    if ( $excluded ne scalar @exclude ) {
        print STDERR " (of ".scalar @exclude." files in make.exclude)";
    }
    print STDERR ".\n";
}
    
open FILES, ">make.files" or
    die("make.files: $!");
print FILES join("\n",sort @codefiles) . "\n";
close FILES;

exit 0;



#
# Finds files.
#
# Examples:
#   find_files("/usr","\.cpp$",1)   - finds .cpp files in /usr and below
#   find_files("/tmp","^#",0)	    - finds #* files in /tmp
#

sub find_files {
    my($dir,$match,$descend) = @_;
    my($file,$p,@files);
    local(*D);
    $dir =~ s=\\=/=g;
    ($dir eq "") && ($dir = ".");

    if ( opendir(D,$dir) ) {
        if ( $dir eq "." ) {
            $dir = "";
        } else {
            ($dir =~ /\/$/) || ($dir .= "/");
        }
        foreach $file ( readdir(D) ) {
            
            next if ( $file  =~ /^\.\.?$/ );
            $p = $dir . $file;
            ($file =~ /$match/i) && (push @files, ($tolower==0 ? $p : lc($p)));
            if ( $descend && -d $p && ! -l $p ) {
                push @files, &find_files($p,$match,$descend);
            }
        }
        closedir(D);
    }
    return @files;
}
