#!/usr/bin/perl -w

if(@ARGV != 1) {           #error checking
   die "Usage: $0 <word>\n";
}

$searchWord = lc $ARGV[0];

foreach $file (glob "poets/*.txt") {     #loop through all file names with .txt 
   my $poetName = $file;   
   $poetName =~ s/.*\///;     #getting poet name from file path 
   $poetName =~ s/\.txt$//;
   $poetName =~ s/_/ /g;   
   
   $wordCount{$poetName} = 0;    #initalising, used for 0 case
   
   open poetFile, "<$file" or die;
   while($line = <poetFile>) {
         foreach my $word ($line =~ /[a-z]+/ig) {  #capture all occurences, case insensitive
            $word = lc $word;
            $totalWords{$poetName}++;           #incrementing hashes
            $wordCount{$poetName}++ if $word eq $searchWord;
         }
   }   
}

foreach my $poet (sort keys %wordCount) {
   printf "log((%d+1)/%6d) = %8.4f %s\n", $wordCount{$poet}, $totalWords{$poet}, 
         log(($wordCount{$poet}+1)/$totalWords{$poet}), $poet;

}
