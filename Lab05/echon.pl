#!/usr/bin/perl -w

if (@ARGV != 2) {
   die "Usage $0 <number of lines> <string>";
}

for($i = 0; $i < $ARGV[0]; $i++) {
   print "$ARGV[1]\n";
}
