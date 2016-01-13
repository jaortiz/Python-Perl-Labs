#!/bin/sh

if [ 5 -gt 2 ];then  #Testing semi colon and then on same line
   echo "5 greater 2"
fi


if test 2 -lt 5 ;then   #testing using test command
   echo "2 less 5"
fi

if test 2 -eq 2 ; #testing semi colon by itself
then
   echo "equal Nums"
fi

if test 5==5   #testing no spaces in string comparison
then
   echo "5 equal 5"
fi

#testing single quotation
ls '-l'

#testing double quotations
ls "-l"

'ls' -l

#bool ops

#directory tests


