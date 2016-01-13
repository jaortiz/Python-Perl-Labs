#!/usr/bin/perl -w


if(@ARGV == 0) {
   die "Usage: $0 <file>\n";
}

#gets counts for each word and total words per poet
foreach my $file (glob "poets/*.txt") {     #loop through all file names with .txt and get counts 
   my $poetName = $file;   
   $poetName =~ s/.*\///;     #getting poet name from file path 
   $poetName =~ s/\.txt$//;
   $poetName =~ s/_/ /g;   
   
   #$wordCount{$poetName} = 0;    #initalising, used for 0 case
   
   open poetFile, "<$file" or die;
   while($line = <poetFile>) {
         foreach my $word ($line =~ /[a-z]+/ig) {  #capture all occurences, case insensitive
            $word = lc $word;
            $totalWords{$poetName}++;           #incrementing hashes
            $wordCount{$poetName}{$word}++;     #multidimensional hash by poet->word->wordCount
         }
   }   
}


foreach my $file (@ARGV) {    #looping through mystery poems
   open pFile, "<$file" or die;
   
   while($line = <pFile>) {
      foreach my $word ($line =~ /[a-z]+/ig) {
         $word = lc $word;
         foreach my $poet (keys %wordCount) {      #loop through poets
         
            #summation of the log probability that a poet uses the word in the mystery poem, done by
            #looking at the prev analysis and adding the log probability they had of using the word
            if(exists $wordCount{$poet}{$word}) {  #checking for initialisation
               $logProbability{$poet} += log(($wordCount{$poet}{$word}+1)/$totalWords{$poet});
            } else {
               $logProbability{$poet} += log(1/$totalWords{$poet});
            }
         }           
      }   
   }
   
   #sorting the hash by value and returning the sorted list by keys values 
   # my($a) = @b == $a = $b[0]
   my ($probPoet) = sort { $logProbability{$b} <=> $logProbability{$a} } keys %logProbability;

   printf "%s most resembles the work of %s (log-probability=%.1f)\n",$file, $probPoet, 
                                                               $logProbability{$probPoet};
                                                               
   undef %logProbability;     #cleaning hash for subsequent files
}


#testing
=pod
foreach my $poet (sort keys %logProbability) {
   printf "log_probability of %.1f for %s\n", $logProbability{$poet}, $poet;

}
=cut














