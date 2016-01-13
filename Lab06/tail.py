#!/usr/bin/python

import sys

for files in sys.argv[1:]:
   lines = open(files).readlines()
   lines = lines[-10:]     #negative index, access array starting from last 10 i.e. 
   for line in lines:
      print line,
