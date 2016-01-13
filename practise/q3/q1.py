#!/usr/bin/python

import sys

words = {}

for word in sys.argv[1:]:
   if word not in words:
      print word,
      words[word] = 1


