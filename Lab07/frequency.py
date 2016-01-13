#!/usr/bin/python

import sys, glob, re

if len(sys.argv) != 2:
   print "Usage %s <word>" %sys.argv[0]
   sys.exit(1)
   
searchWord = sys.argv[1].lower()

wordCount = {}
totalWords = {}

for poetFile in glob.glob("poets/*.txt"):
   poetName = re.sub(r'.*/','',poetFile)
   poetName = re.sub(r'.txt','',poetName)
   poetName = re.sub(r'_',' ',poetName)
   
   wordCount[poetName] = 0
   totalWords[poetName] = 0
   
   for line in open(poetFile): 
      
      for word in re.findall(r'[a-zA-Z]+',line):   
         word = word.lower()
         totalWords[poetName] += 1
      
         if word == searchWord:
            wordCount[poetName] += 1

for poet in sorted(wordCount):
   print "%4d/%6d = %.9f %s" % (wordCount[poet], totalWords[poet], 
                                          wordCount[poet]/float(totalWords[poet]), poet)
