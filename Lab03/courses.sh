#!/bin/sh

if [ $# -ne 1 ]; then
   echo "Usage: $0 <course code>"
   exit 1
fi

courseCode=$1

#getting the first letter for search
firstLetter=`echo $courseCode | cut -c 1`

#URL's for undergrad and postgrad courses by first letter
ugrdURL="http://www.handbook.unsw.edu.au/vbook2015/brCoursesByAtoZ.jsp?StudyLevel=Undergraduate&descr=$firstLetter"
pgrdURL="http://www.handbook.unsw.edu.au/vbook2015/brCoursesByAtoZ.jsp?StudyLevel=Postgraduate&descr=$firstLetter"

#getting webpages and filtering 
wget -q -O- "$ugrdURL" "$pgrdURL" | grep "$courseCode[0-9][0-9][0-9][0-9].html"|
sed "s/.*\($courseCode[0-9][0-9][0-9][0-9]\)\.html\">\([^<]*\).*/\1 \2/"| sed "s/ *$//" | sort | uniq


exit 0
