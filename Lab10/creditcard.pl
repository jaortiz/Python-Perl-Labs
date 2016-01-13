#!/usr/bin/perl -w

# Function Prototypes
sub luhn_checksum ($);
sub validate ($);

# Main
foreach $arg (@ARGV) {  # Loop through command args
   print validate($arg);
}


# Functions
sub validate ($) {
   my ($number) = @_;
   my $creditCard = $number;
   $number =~ s/\D//g;
   
   print "Number: $number\n";
   
   if(length($number) != 16) {
      return "$creditCard is invalid - does not contain exactly 16 digits\n";
      
   } elsif ((luhn_checksum($number)) % 10 == 0) {
      return "$creditCard is valid\n";
   
   } else {
      return "$creditCard is invalid\n";
   }
}

sub luhn_checksum ($) {
   my ($number) = @_;
   my $checksum = 0;
   
   my $digits = reverse($number);
   my $index = 0;
   foreach my $digit (split(//,$number)) {
      my $multiplier = 1 + $index % 2;
      my $d = $digit * $multiplier;
      if($d > 9) {
         $d -= 9;
      }
      $checksum += $d;
      $index++;
   }
}




