#!/bin/sh

#while loop testing

echo "TEST: normal while loop"
count=0
while test $count -lt 5 ;do
   echo $count
   count=`expr $count + 1`
done

echo "TEST: multiple conditions for while loop"
count=0
while [ $count -ge 0 ] && [ $count -lt 5 ]
do
   echo $count
    count=`expr $count + 1`
done

echo "TEST: command line args in while loop"
args=0
while [ $args -lt $# ];do
   args=`expr $args + 1`
done
echo number of arguments $args
