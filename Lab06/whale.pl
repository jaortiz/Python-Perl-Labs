#!/usr/bin/perl -w


if(@ARGV == 0) {
   die "Usage: $0 'Whale name'";
   
} else {
   my $individual = 0;
   my $pods = 0;
   $whale = $ARGV[0];
   
   while($line = <STDIN>) {
      if($line =~ /^[0-9]+ $whale$/) {
         $pods++;
         $line =~ s/[^0-9]//g;
         $individual = $individual + $line;
      }
   }
   
   print "$whale observations: $pods pods, $individual individuals \n";
}
