#!/usr/bin/python

import sys, re

for line in sys.stdin:
   line = re.sub(r'[0-4]','<',line)
   line = re.sub(r'[6-9]','>',line)
   print line,
