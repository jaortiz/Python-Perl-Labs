#!/usr/bin/perl -w

my %occur;

foreach my $arg (@ARGV) {
   $occur{$arg}++ if exists($occur{$arg});
  
   $occur{$arg} = 1 if ! exists($occur{$arg});
   
}

my ($maxOccur) = sort { $occur{$b} <=> $occur{$a} } keys %occur;

print "$maxOccur\n";
