#! /bin/sh
eval '(exit $?0)' && eval 'PERL_BADLANG=x;PATH="$PATH:.";export PERL_BADLANG\
;exec perl -x -S -- "$0" ${1+"$@"};#'if 0;eval 'setenv PERL_BADLANG x\
;setenv PATH "$PATH":.;exec perl -x -S -- "$0" $argv:q;#'.q
#!perl -w
+push@INC,'.';$0=~/(.*)/s;do(index($1,"/")<0?"./$1":$1);die$@if$@__END__+if 0
;#Don't touch/remove lines 1--7: http://www.inf.bme.hu/~pts/Magic.Perl.Header
#
# wrfiles.pl -- write single example files
# by pts@fazekas.hu at Mon Mar 15 17:01:41 CET 2004
#
use integer;
use strict;

#** @param $_[0] "config.ps", "config" or "pdftex.cfg" etc.
#** @param $_[1] argument of --progname
#** @param $_[2] argument of --format
#** @return the absoulte version of $_[0] -- or relative if in current dir
sub get_absname($$$) {
  my $confrel=$_[0]; $confrel=~y@\\@/@;
  my $confabs=$confrel;
  if (substr($confrel,0,1)ne'/') {
    if (index($confrel,'/')==-1 and (-f $confrel)) { # in current dir
      return "./$confrel";
    }
    # Dat: need to append $PWD to: 0>index($confrel,'/') and (-f$confrel
    # vvv $confrel and $_[1] are assumed not to contain weird characters
    my $cmd="kpsewhich --must-exist --progname=$_[1] --format=\"$_[2]\" -- \"$confrel\" 2>&1";
    $confabs=qx($cmd);
    chomp $confabs;
  }
  # Dat: $confabs might begin with `./'
  (length($confabs)<length($confrel)-1
    # or substr($confabs,-length($confrel)-1,1) ne "/"
    # or substr($confabs,-length($confrel)) ne $confrel # $confrel may contain `..'
    or !-f $confabs) ? undef : $confabs
}

sub romannumeral($) {
  my $N=$_[0]+0;
  my $ret="";
  if ($N>0) {
    if ($N>=1000) { $ret="m"x($N%1000); $N=$N%1000 }
    if ($N>=900) { $ret.="cm"; $N-=900 }
    if ($N>=500) { $ret.="d"; $N-=500 }
    if ($N>=400) { $ret.="cd"; $N-=400 }
    while ($N>=100) { $ret.="c"; $N-=100 }
    if ($N>=90) { $ret.="xc"; $N-=90 }
    if ($N>=50) { $ret.="l"; $N-=50 }
    if ($N>=40) { $ret.="xl"; $N-=40 }
    while ($N>=10) { $ret.="x"; $N-=10 }
    if ($N>=9) { $ret.="ix"; $N-=9 }
    if ($N>=5) { $ret.="v"; $N-=5 }
    if ($N>=4) { $ret.="iv"; $N-=4 }
    while ($N>=1) { $ret.="i"; $N-=1 }
  }
  $ret
}

my $destdir='CDfiles';
my $default_D="\\documentclass{article}\n\n";
my $default_L="\\usepackage[latin2]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage[magyar]{babel}\n";
my $default_B="\n\\begin{document}\n\n";
my $default_E="\n\\end{document}\n";

my %to_coco=('0 '=>'p ','c '=>'< ','o '=>'> ','2 '=>'  ');
my %to_class=('f '=>'F','v '=>'F','f!'=>'F','v!'=>'F','d '=>'D',
    'l '=>'L','p '=>'P','t '=>'P','b '=>'B','< '=>'C','> '=>'C','x '=>'C',
    '  '=>'C','e '=>'E',"\n\n"=>'Z','w '=>'C','% '=>'C','s '=>'C');

my %cleanup_files;
sub cleanup() { while (my($k,$v)=each%cleanup_files) { unlink $k if $v!=0 } }
$SIG{INT}=$SIG{TERM}=$SIG{HUP}=sub { cleanup; exit 1 };
END { cleanup }

my %had_files; # $had_files{$filename}++
sub do_code($$$) {
  my($texfn,$lineno,$destfn)=@_;
  die if $lineno<1;
  my $texabs=get_absname($texfn,"latex","tex"); # adds .tex extension (but not needed)
  die "$0: .tex file not found: $texfn\n" if !defined $texabs;
  die unless open F, "< $texabs";
  if (exists $had_files{$destfn}) {
    if ($destfn=~s@^((?:(?:\d+|[a-zA-Z])_)?(?:\d+|[a-zA-Z]{1,5}))([_.])@$2@) {
      # vvv change `1_2_foo.tex' to `1_2ii_foo.tex'. It won't conflict with
      #     test (1)
      $destfn=$1.romannumeral(++$had_files{$1.$destfn}).$destfn;
      die if exists $had_files{$destfn};
    } else {
      die "$0: multiple target file: $destfn ($texfn:$.)\n";
    }
  } else {
    $had_files{$destfn}=1
  }
  $cleanup_files{"$destdir/$destfn"}++;
  die unless open KI, "> $destdir/$destfn";
  my $S;
  my $L=$lineno;
  while ($L-->0) { die "$0: file too short\n" if !defined($S=<F>) }
  # Dat: now $S is the line of the original $lineno
  chomp $S;
  die "$0: not a code environment ($S) at $texfn:$lineno.\nMaybe wrong \\input{} or \\include{}?\n"
    if $S!~m@\\begin{(pelda|peldak|kod|code)}(.*)@;
  my $currenvir=$1;
  $S=$2; $S=~s@[ \t\r\n]+\Z(?!\n)@@; # Dat: LaTeX also ignores this
  my $going_p=1;
  my %had_from_class;
  print "Dumping env $currenvir from $texfn:$lineno to $destdir/$destfn\n";
  if ($currenvir eq 'kod' or $currenvir eq 'pelda') {
    # Dat: kod, pelda and peldak are legacy environments from lakk
    die if !print KI $default_D.$default_L.$default_B;
    while ($going_p) {
      if (0==length$S) {
        die "$0: unexpected EOF\n" if !defined($S=<F>);
        $going_p=$currenvir eq 'kod' ? $S!~s@\\end\{kod\}.*@@s : $S!~s@\\end\{pelda\}.*@@s;
	last if !$going_p and 0==length($S);
        chomp $S;
      }
      die if !print KI "$S\n";
      $S="";
    }
    die if !print KI $default_E;
  } elsif ($currenvir eq 'code') {
    my $oldclass='F';
    while (1) {
      if (0==length$S) {
        die "$0: unexpected EOF\n" if !defined($S=<F>);
        chomp $S;
        $going_p=$S!~s@\\end\{code\}.*@@s;
	$S="\n\n" if !$going_p and 0==length($S);
      }
      if (length($S)==0) { $S="  " }
      elsif (length($S)==1) { $S.=" " }
     do_end:
      my $coco=substr($S,0,2); # code command
      $S=substr($S,2);
      ## print"[$coco][$S]\n";
      $coco=$to_coco{$coco} if exists $to_coco{$coco};
      my $curclass;
      die "$0: unknown code command `$coco'\n" if !defined($curclass=$to_class{$coco});
      my $oldclass0=$oldclass;
      while ($oldclass ne $curclass) {
        if ($oldclass eq 'F') {
	  $oldclass='G';
	} elsif ($oldclass eq 'G') {
	  $oldclass='D';
	} elsif ($oldclass eq 'D') {
	  die if !exists $had_from_class{'D'} and !print KI $default_D;
	  $oldclass='L';
	} elsif ($oldclass eq 'L') {
	  die if !exists $had_from_class{'L'} and !print KI $default_L;
	  $oldclass='P';
	} elsif ($oldclass eq 'P') {
	  $oldclass='B';
	} elsif ($oldclass eq 'B') {
	  die if !exists $had_from_class{'B'} and !print KI $default_B;
	  $oldclass='C';
	} elsif ($oldclass eq 'C') {
	  $oldclass='E';
	} elsif ($oldclass eq 'E') {
	  die if !exists $had_from_class{'E'} and !print KI $default_E;
	  $oldclass='Z';
	} elsif ($oldclass eq 'Z') {
	  die "cannot move from class $oldclass0 to $curclass\n";
	}
      }
      ## print "($curclass)($coco)($S)\n";
      if ($curclass eq 'F') {
        die "$0: inconsistent filename: $destfn\n" if length($destfn)<length($S)
	  or substr($destfn,length($destfn)-length$S) ne $S; # test (1)
        if ($coco eq 'v!' or $coco eq 'v ') { $oldclass='C'; $had_from_class{'E'}=1 }
      } elsif ($coco eq '> ' or $coco eq '% ' or $coco eq 's ') {
      } elsif ($curclass eq 'D' or $curclass eq 'L' or $curclass eq 'P'
            or $curclass eq 'B' or $curclass eq 'E' or $curclass eq 'C') {
        die if !print KI "$S\n";
	$had_from_class{$curclass}=1;
      } elsif ($curclass eq 'Z') {
        last
      } else { die }
      if (!$going_p) { $S="\n\n"; goto do_end }
      $S="";
    }
  } elsif ($currenvir eq 'peldak') {
    die if !print KI $default_D.$default_L.$default_B;
    if (!length$S) { $S="" if !defined($S=<F>) } 
    die "$0: opening brace expected, got: $S ($.)\n" if substr($S,0,1) ne '{';
    $S=substr($S,1);
    my $depth=1;
    while (1) {
      ##print "A$depth($S)\n";
      if ($depth!=0) { # skip to-document-Sample part
	$S="" if substr($S,0,1)eq'%';
	my $T=$S; $S="";
	my $C;
	while ($T=~m@\G(\\.?|[%{}]|[^\\%{}]+)@sg) {
	  if ($depth==0) { $S.=$1 }
	  elsif ('%'eq($C=substr$1,0,1)) { last }
	  elsif ($C eq '{') { $depth++ }
	  elsif ($C eq '}') { $depth-- }
	}
	if ($depth==0 and 0!=length$S) {
          die if !print KI "$S\n";
	}
      } else {
	die if !print KI "$S\n";
      }
      last if !$going_p;
      die "$0: unexpected EOF\n" if !defined($S=<F>);
      chomp $S;
      $going_p=$S!~s@\\end\{peldak\}.*@@s;
      last if !$going_p and 0==length($S);
    }
    die if !print KI $default_E;
  } else { die }
  die unless close KI;
  die unless close F;
  $cleanup_files{"$destdir/$destfn"}--;
}

my $gendepth=0;
#** @param #_[1] bool: must exist?
sub do_aux($$);
sub do_aux($$) {
  no strict 'refs';
  my $auxfn=$_[0];
  my $auxabs=get_absname($auxfn,"latex","tex");
  if (!defined $auxabs) {
    die "$0: .aux file not found: $auxfn\n" if $_[1];
    return
  }
  my $F=\*{'FILE'.$gendepth++};
  die unless open $F, "< $auxfn";
  print "Processing $auxfn\n";
  while (<$F>) {
    if (/^\\\@gobble\{code:.*\}/) {
      die "$0: syntax error ($.)\n" if !/^\\\@gobble\{code:([^:\}]+):(\d+):([^:\}]+)\}$/;
      do_code($1,$2+0,$3);
    } elsif (/^\\\@gobble\{(cd[dlbe]):(.*)\}/) {
      my $ftype=uc($1);
      die "$0: cannot open $ftype file: $2: $!\n" unless open CDL, "< $2";
      print "Using $ftype file: $2\n";
      my $S=join('',<CDL>);
      $S=~s@\A[\n\r]+@@;
      $S=~s@\s+\Z(?!\n)@\n@;
      ## die $S;
      if ($ftype eq 'CDD') { $default_D="$S\n" }
      elsif ($ftype eq 'CDL') { $default_L=$S }
      elsif ($ftype eq 'CDB') { $default_B="$S\n" }
      elsif ($ftype eq 'CDE') { $default_E=$S }
      else { die }
      die unless close CDL;
    } elsif (/^\\\@input\{/) {
      die "$0: syntax error ($.)\n" if !/^\\\@input\{([^}]+)\}$/;
      do_aux($1,0);
    }
  }
  die unless close $F;
  $gendepth--;
}

die "Usage: $0 <jobname>[.tex|.aux]\n" if @ARGV!=1;
my $fn=$ARGV[0];
$fn=~s@[.](tex|aux)\Z(?!\n)@@; # Imp: foo.bar.log?

select STDERR; $|=1; select STDOUT; $|=1;
if (-e $destdir) {
  print STDERR "warning: destination dir exists: $destdir\n"
}
mkdir $destdir;
die unless -d $destdir;
do_aux "$ARGV[0].aux", 1;

__END__
