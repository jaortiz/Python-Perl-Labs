#!/usr/bin/perl -w

while($line = <STDIN>) {
   chomp $line;
   foreach my $word ($line =~ /[^ ]+/ig) {
      if($word =~ /[0-9]+/) {
         my ($num) = $word =~ /([0-9.]+)/;
         $num = int($num);
         $word =~ s/([0-9.]+)/$num/;
         print "$word ";
      } else {
         print "$word ";
      }
   }
   print "\n";
}
