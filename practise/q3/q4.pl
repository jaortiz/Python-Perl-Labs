#!/usr/bin/perl -w

while($line = <STDIN>) {
   my ($time) = $line =~ /([0-9]{2}:[0-9]{2}:[0-9]{2})/;
   my ($hour) = $time =~ /^([0-9]{2})/;
   
   if($hour == "00") {
      $time =~ s/^00/12/;
      $time .= "am";
      
   } elsif($hour >= 12) {
      if($hour == 12) {
         $time .= "pm";
      } else {
        $hour -= 12;
        if($hour =~ /^[0-9]$/) {
            $hour = "0$hour";
        }
        
        $time =~ s/^([0-9]{2})/$hour/;
        $time .= "pm";
      }
   } else {
      $time .= "am";
   }
   $line =~ s/([0-9]{2}:[0-9]{2}:[0-9]{2})/$time/;
   print $line;
}
