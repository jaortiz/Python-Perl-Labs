#!/usr/bin/perl -w

my @words;

foreach my $arg (@ARGV) {
   if(!(grep /$arg/,@words)) {
      push @words,$arg;
   }
}

foreach my $word (@words) {
   print "$word ";
}

print "\n";
