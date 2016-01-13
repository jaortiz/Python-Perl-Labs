#!/usr/bin/perl -w

die "Usage:$0 <file> <string>" if @ARGV != 2;

open(my $f, '<', "$ARGV[0]") or die $!;

while($line = <$f>) {
   $line =~ s/$ARGV[1]/($ARGV[1])/g;
   print $line;
}
