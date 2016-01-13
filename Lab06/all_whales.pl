#!/usr/bin/perl -w

my %whaleIndiv;
my %whalePods;

while($line = <STDIN>) {
   $whale = $line;
   $whale =~ s/[^a-zA-Z ']//g; #remove everything but letters
   $whale =~ s/^ +//g;
   $whale =~ s/ +/ /g;         #remove beginning whitespace
   $whale =~ s/[sS]$//;
   $whale =~ s/ +$//;
   
   $whale = lc $whale;        #convert to lower case
   
   $whaleCount = $line;
   $whaleCount =~ s/[^0-9]//g;
   
   if(exists $whaleIndiv{$whale}) {
      $whaleIndiv{$whale} += $whaleCount;
      $whalePods{$whale}++; 
   } else {
      #print "not in hash\n";
      $whaleIndiv{$whale} = $whaleCount;
      $whalePods{$whale} = 1;
   
   }
   
   #$whaleLine = "$whale $whaleCount";
   #print "whaleline: $whaleLine\n";
   
   #print "Name: $whale Count: $whaleCount\n";
  
}

foreach my $name (sort keys %whaleIndiv) {
   print "$name observations:  $whalePods{$name} pods, $whaleIndiv{$name} individuals\n";
}
