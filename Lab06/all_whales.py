#!/usr/bin/python

import sys, re

whaleIndiv = {}   #creating empty dicitonaries 
whalePods = {}    

for line in sys.stdin:
   whale = line.lower();
   whale = re.sub(r'[^a-z \']','',whale)  #removing everything thats not a letter, or a space
   whale = re.sub(r'^ +','',whale)  #removing beginning whitespace
   whale = re.sub(r' +',' ',whale)  #removing extra middle whitespace
   whale = re.sub(r's$','',whale)  #removing trailing s
   whale = re.sub(r' +$','',whale)  #removing trailing  spaces
   
   #print "whale:", whale
   
   whaleCount = int(re.sub(r'[^0-9]','',line))  #getting number of whales
   
   #print "whaleCount:", whaleCount
   
   if whale in whaleIndiv:    #check if whale is in dicitonary
      whaleIndiv[whale] += whaleCount
      whalePods[whale] += 1
   else:                   #if whale not in dicitonary
      whaleIndiv[whale] = 0      #intial value
      whaleIndiv[whale] += whaleCount
      whalePods[whale] = 1
      
for name in sorted(whaleIndiv):
   print "%s observations: %d pods, %d individuals" % (name, whalePods[name], whaleIndiv[name]) 
