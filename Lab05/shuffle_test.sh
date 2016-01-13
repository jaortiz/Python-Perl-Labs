#!/bin/sh

for ((i=0;i<5;i++))
do
   echo "$i"
done > check.txt

for ((i=0;i<100;i++)) {
echo "$i"
./shuffle.pl < check.txt > shuffle_output.txt
sort shuffle_output.txt > shuffle_sort.txt
test=`diff check.txt shuffle_sort.txt`
   if[ test ]; then
      echo "Something went wrong" 
   fi
      

}

