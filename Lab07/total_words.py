#!/usr/bin/python

import sys, re

wordCount = 0

for line in sys.stdin:
   #for word in re.split(r'[^a-zA-Z]+',line):
   for word in re.findall(r'[a-zA-Z]+',line):   
      wordCount += 1
      
print wordCount, "words"
