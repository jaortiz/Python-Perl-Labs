#!/usr/bin/perl -w

while ($line = <STDIN>) {
   while($line =~ s/<!([^>]+)>/<!>/g) {
      $command = `$1`;
      $line =~ s/<!>/$command/;
   }
   
   while ($line =~ s/<([^>]+)>/<>/g) {
      $command = `cat $1`;
      $line =~ s/<>/$command/;
   }
   print $line;
   
}
