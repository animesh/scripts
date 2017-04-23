#!/usr/bin/perl

use strict;



my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;

open(F,$main_file_pattern)||die "can't open";

my ($line,$snames,@seqname,@seq,$fresall,$seq,$seqname);



while ($line = <F>) {

        chomp ($line);

        if ($line =~ /^>/){

		$snames=$line;

		chomp $snames;
		$snames=~s/>//g;
             push(@seqname,$snames);

                if ($seq ne ""){

              push(@seq,uc($seq));

              $seq = "";

            }

      } else {$seq=$seq.$line;

      }

}push(@seq,uc($seq));

$seq="";

close F;

my $w;my %m;my $fot;my $t;

my $fresx=$main_file_pattern.".xyz.fasta";
my $fresy=$main_file_pattern.".y.fasta";
my $fresz=$main_file_pattern.".z.fasta";
my $fresxq=$main_file_pattern.".x.qual";
my $fresyq=$main_file_pattern.".y.qual";
my $freszq=$main_file_pattern.".z.qual";
my $fresplc=$main_file_pattern.".plc.frg";

open(FRX,">$fresx");
#open(FRY,">$fresy");
#open(FRZ,">$fresz");

#open(FRXQ,">$fresxq");
#open(FRYQ,">$fresyq");
#open(FRZQ,">$freszq");

open(FRPLC,">$fresplc");

my $fot;

for($fot=0;$fot<=$#seq;$fot++){

my $l=length(@seq[$fot]);

@seqname[$fot]=~s/\s+/\_/g;

my $snx="@seqname[$fot].$l.x";
my $sny="@seqname[$fot].$l.y";
my $snz="@seqname[$fot].$l.z";

my $seqx=substr(@seq[$fot],100,$l-200);
my $seqy=substr(@seq[$fot],0,100);
my $seqz=substr(@seq[$fot],$l-100,100);

my $rcseqx=reverse($seqx);
my $rcseqy=reverse($seqy);
my $rcseqz=reverse($seqz);

$rcseqx =~ tr/ACGTacgt/TGCAtgca/;
$rcseqy =~ tr/ACGTacgt/TGCAtgca/;
$rcseqz =~ tr/ACGTacgt/TGCAtgca/;

print FRX">$snx template=xy$fot dir=F library=l$fot \n$seqx\n";
print FRX">RC$sny template=xy$fot dir=R library=l$fot \n$rcseqy\n";
print FRX">$snx template=xz$fot dir=F library=l$fot \n$seqx\n";
print FRX">RC$snz template=xz$fot dir=R library=l$fot \n$rcseqz\n";
print FRX">$snz template=zy$fot dir=F library=l$fot \n$seqz\n";
print FRX">RC$sny template=zy$fot dir=R library=l$fot \n$rcseqy\n";

#>codbac-190o01.fb140_b1.SCF template=codbac-190o01 dir=F library=codbac-140 trim

$seqx=~s/[A-Z]/ 40 /g;
$seqy=~s/[A-Z]/ 40 /g;
$seqz=~s/[A-Z]/ 40 /g;


#print FRXQ">$snx\n$seqx\n";
#print FRYQ">$sny\n$seqy\n";
#print FRZQ">$snz\n$seqz\n";

#print FRPLC"{PLC\nact:A\nfrg:$snx\nfrg:$sny\nfrg:$snz\n}\n";

}

close FRA;

