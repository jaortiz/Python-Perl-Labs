#!/bin/sh

#if statement tests

echo "TEST: Simple string comparisons in if statement"
if test 2 = 2
then
   echo equal
fi

if test 2 != 1
then
   echo not equal
else
   echo equal
fi

echo "TEST: number comparisons"
if test 2 -eq 2
then
   echo equal
else
   echo not equal
fi

if test 2 -ne 3
then
   echo not equal
else
   echo equal
fi

if test 5 -gt 2
then
   echo greater than
else
   echo not greater than
fi

if test 2 -lt 5
then
   echo "less than"
else
   echo "not less than"
fi

echo "TEST: using [ ] in if statement" 
if [ 2 = 2 ]
then
   echo equal
fi

echo "TEST: using file permission tests"
if [ -r shpy.pl ]; then
   echo readable
else
   echo not readable
fi

if [ -w shpy.pl ]; then
   echo writable
else
   echo not writable
fi 

if test -x shpy.pl ; then
   echo executable   
else
   echo not executable
fi

if test -f 'shpy.pl'; then
   echo "file exists"
else
   echo "file does not exist"
fi

echo "TEST: using logical operators"
if [ ! 2 -ne 2 ];then
   echo equal
else
   echo not equal
fi

echo "TEST: && and ||"
if [ 2 -ge 2 ] && [ 1 -ge 1 ]; then
   echo both greater than or equal
fi

if [ 2 -eq 2 ] || [ 3 -eq 1 ]; then
   echo one or both equal
fi

echo "TEST: elif and variables"
num=3
if [ $num -eq 1 ];then
   echo equal to 1
elif [ $num -eq 2 ];then
   echo equal to 2
elif [ $num -eq 3 ];then
   echo equal to 3
fi
