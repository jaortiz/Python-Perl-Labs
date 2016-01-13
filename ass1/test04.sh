#!/bin/sh

count=0
bool=0
while [ $count -lt 10 ] && [ $bool -eq 0 ]; do    #testing while loops and bool operations
   echo $count
   count=$(($count + 1))
   if [ $count -eq 5 ];then
      bool=1
   fi
done
