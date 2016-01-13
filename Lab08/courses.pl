#!/usr/bin/perl -w

$URL = "http://www.timetable.unsw.edu.au/current/";

if(@ARGV == 0) {
   die "Usage: $0 <Course Code>";
}

$prefix = uc $ARGV[0];

open F, "wget -q -O- $URL/${prefix}KENS.html|" or die;

while ($line = <F>) {

   if($line =~ />$prefix[0-9]{4}</) {  
      $line =~ /($prefix[0-9]{4})/; 
      print "$1\n";     #capture variable for above regex
   }
   
}

   
