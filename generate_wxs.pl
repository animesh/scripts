#!/usr/local/bin/perl

use strict;
use Cwd;
use Win32;

my %shortcuts = ('trev.exe' => 'Trev',
		 'pregap4.exe' => 'Pregap4',
		 'gap.exe' => 'Gap4',
		 'spin.exe' => 'Spin',
		 'sprun.exe' => 'Console'
		);

my %extensions = ('trev.exe'    => {'ztr'   => ['ZTR trace file',
						'&quot;%1&quot;',
						'application/octet-stream'],
				    'ab1'   => ['AB1 trace file',
						'&quot;%1&quot;',
						'application/octet-stream'],
				    'exp'   => ['Gap4 Experiment file',
						'&quot;%1&quot;',
						'application/octet-stream'],
				    'ctf'   => ['CTF trace file',
						'&quot;%1&quot;',
						'application/octet-stream']
				   },
		  'gap.exe'     => {'aux'   => ['Gap4 Database',
						'&quot;%1&quot;',
						'application/octet-stream'],
				   },
		  'spin.exe'    => {'fasta' => ['Fasta sequence file',
						'&quot;%1&quot;',
						'text/plain'],
				    'embl'  => ['EMBL sequence file',
						'&quot;%1&quot;',
						'text/plain'],
				    'seq'   => ['Sequence file',
						'&quot;%1&quot;',
						'text/plain'],
				   },
		  'pregap4.exe' => {'pg4'   => ['Pregap4 configuration file',
						'-config &quot;%1&quot;',
						'text/plain']
				   }
		 );

# Component IDs that we need to turn into features.
my @components;

{
    my $globalid=0;
    sub nextid {
        my ($name) = @_;
        $globalid++;
	$name =~ tr/a-zA-Z0-9_/_/c;
        return "ID${name}_$globalid";
   }
}

{
    my $subtime = 0;
    sub guidgen {
        my $time_low = time();
        my $time_mid = $subtime & 0xff;
        my $time_hi_and_version = ($subtime >> 16);
        $time_hi_and_version = ($time_hi_and_version & 0xfff) | 0x4000;
        my $clock_seq_hi_and_reserved = int(rand(0x10000));
        $clock_seq_hi_and_reserved = ($clock_seq_hi_and_reserved & 0x3fff) | 0x8000;
        my $clock_seq_low = int(rand(0x10000));

	$subtime++;

	return sprintf("%08X-%04X-%04X-%04X-0008028F89FB",
	    $time_low, $time_mid, $time_hi_and_version, $clock_seq_hi_and_reserved,
	    $clock_seq_low);
    }
}

sub printheader {
    print "<?xml version=\"1.0\"?>\n";
    print "<Include>\n";
}

sub printdir {
    my ($indent) = @_;
    my $firstfile=1;
    my $sp = "  " x $indent;
    my $cwd = getcwd();

    opendir(my $fh, ".");
    # Add files (in <Component><File/></Component> block
    my @files = readdir($fh);
    foreach (@files) {
	next if /^\.(\.)?$/;
	if (-f "$_") {
	    if ($firstfile) {
		my $id = nextid("dir");
		print "$sp<Component Guid=\"", guidgen(), "\" Id=\"$id\">\n";
		push(@components, $id);
	    }
	    my $id = nextid($_);
  	    my $long = "$_";
	    my $short = Win32::GetShortPathName($long);

	    # File associations must be done in their own Components
	    if (exists($extensions{$long})) {
 	        if (!$firstfile) {
		    print "$sp</Component>\n";
 	        }
		my $id = nextid("dir");
		print "$sp<Component Guid=\"", guidgen(), "\" Id=\"$id\">\n";
		push(@components, $id);
	    }
	    $firstfile = 0;

	    if (exists($shortcuts{$long})) {
		if ($long ne $short) {
	            print "$sp  <File Id=\"$id\" Name=\"$short\" LongName=\"$long\" DiskId=\"1\" src=\"$cwd/$long\">\n";
		} else {
	            print "$sp  <File Id=\"$id\" Name=\"$short\" DiskId=\"1\" src=\"$cwd/$long\">\n";
		}
		if ($shortcuts{$long} eq 'Console') {
		    print "$sp    <Shortcut Id=\"Shortcut_$long\" Directory=\"StadenMenuFolder\" Name=\"$shortcuts{$long}\" Target=\"[#$id]\" Show=\"minimized\" Arguments=\"-console\"/>\n";
		} else {
		    print "$sp    <Shortcut Id=\"Shortcut_$long\" Directory=\"StadenMenuFolder\" Name=\"$shortcuts{$long}\" Target=\"[#$id]\" Show=\"minimized\"/>\n";
		}
	        print "$sp  </File>\n";
	    } else {
		if ($long ne $short) {
		    print "$sp  <File Id=\"$id\" Name=\"$short\" LongName=\"$long\" DiskId=\"1\" src=\"$cwd/$long\"/>\n";
		} else {
		    print "$sp  <File Id=\"$id\" Name=\"$short\" DiskId=\"1\" src=\"$cwd/$long\"/>\n";
		}
	    }

	    # Add ProgId blocks for file associations
	    if (exists($extensions{$long})) {
		foreach my $ext (keys %{$extensions{$long}}) {
		    my @a = @{$extensions{$long}{$ext}};
		    print "$sp  <ProgId Id=\"${ext}file\" Description=\"$a[0]\" Advertise=\"yes\">\n";
		    print "$sp    <Extension Id=\"$ext\" ContentType=\"$a[2]\">\n";
		    print "$sp      <Verb Id=\"Open\" Command=\"Open\" Argument=\"$a[1]\"/>\n";
		    print "$sp    </Extension>\n";
		    print "$sp  </ProgId>\n";
		}

		print "$sp</Component>\n";
		$firstfile = 1;
	    }
	}
    }
    if (!$firstfile) {
 	print "$sp  <CreateFolder/>\n";
	print "$sp</Component>\n";
    }

    # Recurse down directories.
    foreach (@files) {
	next if /^\.(\.)?$/;
	if (-d "$_") {
	    my $id = nextid($_);
  	    my $long = "$_";
	    my $short = Win32::GetShortPathName($long);
	    if ($long ne $short) {
		print "$sp<Directory Id=\"$id\" Name=\"$short\" LongName=\"$long\">\n";
	    } else {
		print "$sp<Directory Id=\"$id\" Name=\"$short\">\n";
	    }
	    my $lastdir = getcwd();
	    chdir($_);
	    printdir($indent+1);
	    chdir($lastdir);
	    print "$sp</Directory>\n";
	}
    }
    closedir($fh);
}

sub printcomponents {
    print "    <Feature Id=\"main\" Title=\"Staden Package\" Level=\"1\">\n";
    foreach (@components) {
	print "      <ComponentRef Id=\"$_\"/>\n";
    }
    print "    </Feature>\n";
}

sub printfooter {
    print "</Include>\n";
}

printheader();
chdir($ARGV[0]);
print "    <Directory Id=\"TARGETDIR\" Name=\"SourceDir\">\n";
print "      <Directory Id=\"ProgramMenuFolder\" Name=\"PMFolder\">\n";
print "        <Directory Id=\"StadenMenuFolder\" Name=\"Staden~1\" LongName=\"Staden Package\"/>\n";
print "      </Directory>\n";
printdir(2);
print "    </Directory>\n";
printcomponents();
printfooter();
