#!/usr/bin/perl -w

$recursive = 0;
$ugrad_URL = "http://www.handbook.unsw.edu.au/undergraduate/courses/2015";
$pgrad_URL = "http://www.handbook.unsw.edu.au/postgraduate/courses/2015";

my %prereqList;

sub prereq {
   my ($courseCode) = @_;
   open F, "wget -q -O- $ugrad_URL/$courseCode.html $pgrad_URL/$courseCode.html |" or die "couldnt open";

   while ($line = <F>) {
      next if $line !~ /Pre.*:/i;   #filtering through lines until we find the prereq line
      $line = uc $line;             #converting to upper case for some cases with lower case codes
      $line =~ s/<\/.*//g;          #remove everything after course codes
      $line =~ s/<[^>]*>//g;        #remove any remaining tags
      my @courses = ($line =~ /([A-Z]{4}[0-9]{4})/g); #putting all regex captures into array
      push @prereqs, @courses;      #push regex captures into another array
   }
   
   foreach my $course (sort @prereqs) {
      if(!$prereqList{$course}++ && $recursive) {  #if the course is in not in the hash and is recursive, recurse
         prereq($course);                          #Using autovivification to add the item to the hash after check
      }
   }
}


if($ARGV[0] eq "-r") {  #Check whether to recurse
   $recursive = 1;
   prereq($ARGV[1]);
} else {
   prereq($ARGV[0]);
}


foreach my $course (sort keys %prereqList) {    
   print "$course\n";
}
