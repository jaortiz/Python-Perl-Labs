#!/usr/bin/python2.7 -u
import sys

#while loop testing

print "TEST: normal while loop" 
count = '0' 
while int(count) < 5: 
    print count 
    count = int(count) + 1 

print "TEST: multiple conditions for while loop" 
count = '0' 
while int(count) >= 0 and int(count) < 5: 
    print count 
    count = int(count) + 1 

print "TEST: command line args in while loop" 
args = '0' 
while int(args) < int(len(sys.argv[1:])): 
    args = int(args) + 1 
print 'number', 'of', 'arguments', args 
