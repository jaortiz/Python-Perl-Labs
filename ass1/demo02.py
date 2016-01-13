#!/usr/bin/python2.7 -u
import sys
import glob

#for loop tests
print "TEST: Regular for loop" 
for i in 'blah', 'foo', 'bar': 
    print i 

print "TEST: for loop with done keyword in statement" 
for word in 'blah', 'foo', 'bar': 
    print word 

print "TEST: for loop, looping over all shell files" 
for shFile in sorted(glob.glob("*.sh")): 
    print shFile 

print "TEST: for loop, looping all over all files" 
for file in sorted(glob.glob('*')): 
    print file 

print "TEST: for loop using [ ] metacharacters to loop over files" 
for file in sorted(glob.glob('[a-z]*[0-9]*')): 
    print file 


print "TEST: for loop using ? metacharacters to loop over files" 
for file in sorted(glob.glob("?*.sh")): 
    print file 

print "TEST: for loop using command line args" 
for arg in sys.argv[1:]: 
    print arg 
