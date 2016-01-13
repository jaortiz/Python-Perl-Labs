#!/usr/bin/perl -w

my @lines;

while ($line = <STDIN>) {
  push @lines,$line;
}

foreach my $line (@lines) {
   if($line =~ /^#/) {
      my ($num) = $line =~ /#([0-9]+)/;
      $num -= 1;
      print $lines[$num];
   } else {
      print $line;
   }
}
