#!/usr/bin/perl -w

if(@ARGV != 1) {
   die "Usage: $0 <word>\n";
}

$wordCount = 0;

$searchWord = lc $ARGV[0];

while($line = <STDIN>) {

   foreach my $word ($line =~ /[a-z]+/ig) {  #capture all occurences, case insensitive
      $word = lc $word;
      $wordCount++ if $word eq $searchWord;
   }
}

print "$searchWord occurred $wordCount times\n";

