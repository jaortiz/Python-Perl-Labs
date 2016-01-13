#!/usr/bin/python

import sys

words = {}

for arg in sys.argv[1:]:
   if arg in words:
      words[arg] += 1
   else:
      words[arg] = 1

maxWord = max(words, key = words.get)

print maxWord   
