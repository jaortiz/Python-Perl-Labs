#!/bin/sh
if [ $# -ne 2 ]; then
   echo "Usage: $0 <number of lines> <string>"
   exit 1
fi

#check if the argument is a number and whether it is a negative integer 
if ! [[ $1 =~ ^[0-9]+$ ]]; then     
   echo "$0: argument 1 must be a non-negative integer"
   exit 1
fi

#loop through and output
for ((i=0;i <$1;i++))
do
   echo "$2"
done
