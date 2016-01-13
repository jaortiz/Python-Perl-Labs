#!/usr/bin/python

import sys, re

pods = 0
individuals = 0

if len(sys.argv) == 1:
   print "Usage %s 'Whale Name'" %sys.argv[0]
   sys.exit(1)

for line in sys.stdin:
   if(re.search(r'^[0-9]+ %s' %sys.argv[1],line)):
      pods += 1;
      individuals += int(re.sub(r'[^0-9]','',line))
      #int(line.split()[0])
      #individuals += int(re.findall('\d+',line))
      #print int(re.findall('\d+',line))

print sys.argv[1], "observations:", pods, "pods,", individuals, "individuals"
