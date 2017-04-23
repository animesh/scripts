#!/usr/bin/perl

print "Hello, World...\n";
  use Encode;
  @list = Encode->encodings();
print @list;
