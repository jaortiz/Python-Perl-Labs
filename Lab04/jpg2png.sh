#!/bin/sh

#loop over all jpg's
for jpg in *.jpg
do
   png=`echo "$jpg"|sed "s/jpg$/png/"`   #creating png file name
   if [ -f "$png" ]; then                   #check if the png already exists
      echo "$png already exists"
   exit 1
   fi
   
   convert "$jpg" "$png"
   rm "$jpg"
done
