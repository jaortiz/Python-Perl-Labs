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
   $start = @lines - $N;
   $start = 0 if $start < 0;
   foreach my $i ($start..$#lines) {
      print $lines[$i];
   }
   #foreach $line (@lines) {
    #  print $line;
     # last if $. == $N
   #}
   #for($i = $N;$i >= 0;$i--) {
   #   print $lines[$i];
   #}
   
} elsif (@ARGV > 0) {
   $NFiles = (@ARGV > 1);  #checking if there are multiple file arguments
   foreach $f (@ARGV) {    #read in the file names
      if(!open(FILE,"<$f")) {    #< read only mode, open files
         print "$0: can't open $f\n";
      } else {
         if($NFiles) {     #if more than one file argument
            print "==> $f <==\n";
         }
         
         #my @lines = reverse <FILE>;
         @lines = <FILE>;
         $start = @lines - $N;
         $start = 0 if $start < 0;
         foreach my $i ($start..$#lines) {
            print $lines[$i];
         }
         #for($i = $N-1;$i >= 0 && $i < @lines;$i--) {
            #print $lines[$i];
         #}

         close(FILE);
      }
   }  
}

