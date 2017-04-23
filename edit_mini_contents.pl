#!/usr/bin/perl -w

#
# 14/03/00 jkb
#
# Adds the Home, Up, etc to the mini manual contents pages.
#
$os=shift;

while (<>) {
  if (/^<H1>/) {
    print <<EOH
<a href="../staden_home.html"><img src="i/nav_home.gif" alt="home"></a>
<a href="../documentation.html"><img src="i/nav_up.gif" alt="up"></a>
<a href="master_${os}_contents.html"><img src="i/nav_full.gif" alt="full"></a>
<hr size=4>
EOH
  } elsif (/<H2>Last update on/) {
    next;
  } elsif (/^<HR>$/) {
    print <<EOF
<hr size=4> 
<a href="../staden_home.html"><img src="i/nav_home.gif" alt="home"></a> 
<a href="../documentation.html"><img src="i/nav_up.gif" alt="up"></a> 
<a href="master_${os}_contents.html"><img src="i/nav_full.gif" alt="full"></a> 
EOF
  }
  print;
}
