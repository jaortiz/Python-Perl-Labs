#!/usr/bin/python

import sys

if len(sys.argv) != 3:
   print "Usage %s <number of lines> <string>" %sys.argv[0]
   sys.exit(1)

for i in range(0,int(sys.argv[1])):
   print sys.argv[2]
