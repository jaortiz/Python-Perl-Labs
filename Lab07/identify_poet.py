#!/usr/bin/python

import sys, glob, re, math, collections   
from collections import defaultdict

wordCount = {}       #initialising dictionaries
totalWords = {}
logProbability = defaultdict(int)   #for key errors, if trying to add with key not in dictionary, will create
                                                                              #for us and intialise to 0 for (int)
for poetFile in glob.glob("poets/*.txt"):
   poetName = re.sub(r'.*/','',poetFile)
   poetName = re.sub(r'.txt','',poetName)
   poetName = re.sub(r'_',' ',poetName)
   
   totalWords[poetName] = 0
   wordCount[poetName] = defaultdict(int)   
   
   for line in open(poetFile): 
      for word in re.findall(r'[a-zA-Z]+',line):   
         word = word.lower()
         totalWords[poetName] += 1
         wordCount[poetName][word] += 1


for pFile in sys.argv[1:]:    #loop through args
   for line in open(pFile):      #loop through lines in file
      for word in re.findall(r'[a-zA-Z]+',line):   #loop though words in line
         word = word.lower()
         for poet in sorted(wordCount):   #loop through poets
            logProbability[poet] += math.log((wordCount[poet][word] + 1)/float(totalWords[poet]))  
      
   probPoet = max(logProbability, key = logProbability.get) #get key with max value
   print "%s most resembles the work of %s (log-probability=%.1f)" % (pFile, probPoet, logProbability[probPoet])
   
   logProbability.clear()

#testing
#for poet in sorted(wordCount):
   #print "log_probability of %.1f for %s" % (logProbability[poet], poet)
   

            
