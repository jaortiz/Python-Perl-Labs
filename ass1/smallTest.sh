#!/bin/sh

if test 2 -eq 2 ;then
   echo 'hello'
else
   echo 'no hello'
fi

echo -n "testing no newline"
echo "after no newline"

series="series.py"

if test -r $series
then
   echo "readable";
fi

for i in blah foo bar; do
   echo $i
done

counter=0
while [ $counter -lt 4 ];do
   echo $counter
   let counter=counter+1
done
