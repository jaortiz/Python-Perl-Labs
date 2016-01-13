#!/bin/sh

#for loop tests
echo "TEST: Regular for loop"
for i in blah foo bar
do
   echo $i
done

echo "TEST: for loop with done keyword in statement"
for word in blah foo bar;do
   echo $word
done

echo "TEST: for loop, looping over all shell files"
for shFile in *.sh
do
   echo $shFile
done

echo "TEST: for loop, looping all over all files"
for file in *
do
   echo $file
done

echo "TEST: for loop using [ ] metacharacters to loop over files"
for file in [a-z]*[0-9]*
do
   echo $file
done


echo "TEST: for loop using ? metacharacters to loop over files"
for file in ?*.sh
do
   echo $file
done

echo "TEST: for loop using command line args"
for arg in "$@"
do 
   echo $arg
done
