#!/usr/bin/python

import sys, urllib2, re, subprocess
from collections import defaultdict

tags = defaultdict(int)

if len(sys.argv) > 1 and sys.argv[1] == "-f":
   sortFrequency = 1
   url = sys.argv[2]
else:
   sortFrequency = 0
   url = sys.argv[1]


wget = subprocess.Popen(['wget','-q','-O-',url], stdout=subprocess.PIPE).communicate()[0] #get page
wget = re.sub(r'<!.*?>','',wget) #remove comments
wget = wget.lower()

for tag in re.findall(r'<[^>]*>',wget):   #get every tag
   tag = re.sub(r'[<>]','',tag)     #remove brackets from each tag
   tag = re.sub(r' +.*','',tag)     #remove everything after a space i.e. a href.....
   
   if not re.search(r'\/',tag):     #if not an ending tag (</.*>
      tags[tag] += 1

if sortFrequency:
   for tag in sorted(tags, key=tags.get):    #sort by value
      print tag, tags[tag]
else:
   for tag in sorted(tags.keys()):     #sort by key
      print tag, tags[tag]

