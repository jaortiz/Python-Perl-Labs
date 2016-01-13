#!/usr/bin/perl -w

$N = 10; #default N lines

if(@ARGV > 0 && $ARGV[0] =~ /-[0-9]+/) {  #checking whether a number has been passed 
   $N = $ARGV[0];
   $N =~ s/-//;
   shift @ARGV;   #moving next argument up/shifting args left
}

if(@ARGV == 0) {  #case for piping/redirecting input
   #my @lines = reverse <>;
   @lines = <>;
   $start = @lines - $N;   #finding start of the tail
   
   if($start < 0) {  #if start is < 0 file has less than n lines to print
      $start = 0;
   }
   
   foreach my $i ($start..$#lines) {
      print $lines[$i];
   }
   
} elsif (@ARGV > 0) {
   $NFiles = (@ARGV > 1);  #checking if there are multiple file arguments
   foreach $f (@ARGV) {    #read in the file names
      if(!open(FILE,"<$f")) {    #< read only mode, open files
         print "$0: can't open $f\n";
      } else {
         if($NFiles) {     #if more than one file argument
            print "==> $f <==\n";
         }
         
         @lines = <FILE>;
         $start = @lines - $N;
         
         if($start < 0) {
            $start = 0;
         }
         
         foreach my $i ($start..$#lines) {
            print $lines[$i];
         }
         

         close(FILE);
      }
   }  
}

