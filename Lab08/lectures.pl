#!/usr/bin/perl -w

$url = "http://www.timetable.unsw.edu.au/current/";
$tuple = 0;
$table = 0;

my %lectureTimes;    #hash to hold the session, day, time for a course (used in 

foreach $arg (@ARGV) {  #loop through args
   if($arg eq "-d") {
      $tuple = 1;
   } elsif($arg eq "-t") {
      $table = 1;
   } else {
      push @codes, $arg;
   }

}

foreach my $course (@codes) {    #loop through the course codes
   
   #initialising variables
   my %lectures;
   my $session = "";
   
   $course  = uc $course;  #uppercasing the course code
   
   open F,"wget -q -O- $url/$course.html|" or die "Unable to open page for $course";
   
   while($line = <F>) {
      next if $line !~ /a href.*>Lecture/;   #start of info
      
      $line =~ /([A-Z][0-9])/;   #getting session 
      $session = $1;

      foreach (0..5) {     #Skipping Lines
         $line = <F>;
      }
      
      chomp $line;                  #remove newline character
      $line =~ s/<\/.*//g;          #remove everything after course codes
      $line =~ s/<[^>]*>//g;        #remove any remaining tags
      $line =~ s/^ *//;             #remove beginning whitespace
      $line =~ s/ *$//;             #remove end whitespace 
      
      
      next if !$line || $lectures{$line}++;  #next if line is empty or line is already in hash (stops duplicates)
      print "$course: $session $line\n" if (!$tuple && !$table);
      
      next if (!$table && !$tuple);    #skip below stuff if not table or tuple option
      
      foreach my $lecture (split /\), /,$line) {   #split each line into days via ), delimeter
         $lecture =~ s/ \(.*//;  #remove end stuff
         
         #capturing the groups
         my ($day, $startTime, $endTime, $endMinute) = $lecture =~ /([A-Z]{3}) ([0-9]{2}):[0-9]{2} - ([0-9]{2}):([0-9]{2})/i;
         
         $endTime++ if $endMinute ne "00";   #for lectures that dont end on the hour i.e. 11:00-12:30
         
         foreach $time($startTime..$endTime-1) {      #loop through for each hour from start to end time
            $lectureTimes{$session}{$day}{$time}++;   #increment triple key hash
            print "$session $course $day $time\n" if $tuple;               
         
         }
      }
   }
}
if($table) {
   foreach my $session (sort keys %lectureTimes) {    #loop through sessions
      
      printf "%-6s",$session;    #%-6s prints the session with 6 spaces after
      printf "%6s", $_ for qw(Mon Tue Wed Thu Fri);   #%6s pads each string with 6 spaces after the string
      print "\n";
      foreach $time (9..20) {    #printing each line by hour
         printf "%02d:00", $time;
         foreach $day (qw(Mon Tue Wed Thu Fri)) {
            if($lectureTimes{$session}{$day}{$time}) {   #if the time is in the hash
               printf "%6s", $lectureTimes{$session}{$day}{$time};
            } else {
               printf "%6s","";
            }
         }
         print "\n";
      }
   }
}










