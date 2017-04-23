

print platform($ARGV[0]), "\n";

sub platform {
  my $config_guess = shift;
  unless (defined $::_platform_) {
    if ($^O=~/^MSWin(32|64)$/i) {
      $::_platform_="win32";
    } else {
      if (!defined($config_guess)) {
        printf STDERR "first argument must be path to config.guess\n";
        exit 1;
      }
      my @OSs = qw(aix cygwin darwin freebsd hpux irix linux netbsd
                   openbsd solaris);

      # We cannot rely on #! in config.guess but have to call /bin/sh
      # explicitly because sometimes the 'noexec' flag is set in
      # /etc/fstab for ISO9660 file systems.
      chomp (my $guessed_platform = `/bin/sh $config_guess`);
      
      # For example, if the disc or reader has hardware problems.
      die "$0: could not run $config_guess, cannot proceed, sorry"
        if ! $guessed_platform;
      
      $guessed_platform =~ s/^x86_64-(.*)-freebsd/amd64-$1-freebsd/;
      my $CPU; # CPU type as reported by config.guess.
      my $OS;  # O/S type as reported by config.guess.
      ($CPU = $guessed_platform) =~ s/(.*?)-.*/$1/;
      $CPU =~ s/^alpha(.*)/alpha/;   # alphaev56 or whatever
      $CPU =~ s/powerpc64/powerpc/;  # we don't distinguish on ppc64
      for my $os (@OSs) {
        $OS = $os if $guessed_platform =~ /$os/;
      }
      if ($OS eq "darwin") {
        $CPU = "universal"; # TL provides universal binaries
      } elsif ($CPU =~ /^i.86$/) {
        $CPU =~ s/i.86/i386/;
      }
      unless (defined $OS) {
        ($OS = $guessed_platform) =~ s/.*-(.*)/$1/;
      }
      $::_platform_ = "$CPU-$OS";
    }
  }
  return $::_platform_;
}

