#!/usr/bin/perl -w

while($line = <STDIN>) {
   my ($name) = $line =~ /^[^|]+\|[^|]+\|([^|]+)\|/;
   my ($lName) = $name =~ /^([^,]+)/;
   my ($fName) = $name =~ / (.+)/;
   $newName = "$fName $lName";
   $line =~ s/[^0-9\|]+,[^0-9|]+/$newName/;
   print $line;
}
