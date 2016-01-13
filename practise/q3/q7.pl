#!/usr/bin/perl -w

my %fines;

while(1) {
   print "Enter student name: ";
   $name = <STDIN>;
   last if !defined $name;
   chomp $name;
   print"Enter library fine: ";
   $fine = <STDIN>;
   chomp $fine;
   if(exists($fines{$name})) {
      $fines{$name} += $fine;
   } else {
      $fines{$name} = $fine;
   }
}
print "\n";
my ($expel) = sort { $fines{$b} <=> $fines{$a} } keys %fines;

print "Expel $expel whose library fines total $fines{$expel}\n";
