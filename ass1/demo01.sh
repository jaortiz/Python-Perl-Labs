#!/bin/sh

#commands testing and variables

echo "TEST: unix/shell commands";
pwd
id
date

ls
ls -l

echo "TEST: file creation"
file1=./file1.txt
file2=./file2.txt
blah=foo
echo $blah >> $file1

if [ -f $file1 ];then
   echo "file created"
else
   echo "file not created"
fi

echo "TEST: mv"
mv $file1 $file2 

if [ ! -f $file1 ] && [ -f $file2 ];then
      echo move successful
else 
   echo move not successful
fi

echo "TEST: rm"
rm -f $file2
if [ ! -f $file2 ];then
   echo remove successful
else
   echo remove not successful
fi
