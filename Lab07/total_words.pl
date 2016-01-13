#!/usr/bin/perl -w

$wordCount = 0;



while($line = <STDIN>) {

   foreach my $word ($line =~ /[a-z]+/ig) {  #capture all occurences, case insensitive
      $wordCount++;
   }
}

print "$wordCount words\n";
