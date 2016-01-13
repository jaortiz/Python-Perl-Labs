#!/usr/bin/python

import sys,re

if len(sys.argv) != 2:
   print "Usage %s <word>" %sys.argv[0]
   sys.exit(1)
   
searchWord = sys.argv[1].lower()
wordCount = 0

for line in sys.stdin:
   for word in re.findall(r'[a-zA-Z]+',line):   
      word = word.lower()
      if word == searchWord:
         wordCount += 1

print searchWord, "occurred", wordCount, "times"
