#!/usr/bin/python2.7 -u
import os

#if statement tests

print "TEST: Simple string comparisons in if statement" 
if '2' == '2': 
    print 'equal' 

if '2' '!=' '1': 
    print 'not', 'equal' 
else:
    print 'equal' 

print "TEST: number comparisons" 
if 2 == 2: 
    print 'equal' 
else:
    print 'not', 'equal' 

if 2 != 3: 
    print 'not', 'equal' 
else:
    print 'equal' 

if 5 > 2: 
    print 'greater', 'than' 
else:
    print 'not', 'greater', 'than' 

if 2 < 5: 
    print "less than" 
else:
    print "not less than" 

print "TEST: using [ ] in if statement" 
if '2' == '2': 
    print 'equal' 

print "TEST: using file permission tests" 
if os.access('shpy.pl',os.R_OK): 
    print 'readable' 
else:
    print 'not', 'readable' 

if os.access('shpy.pl',os.W_OK): 
    print 'writable' 
else:
    print 'not', 'writable' 

if os.access('shpy.pl',os.X_OK): 
    print 'executable' 
else:
    print 'not', 'executable' 

if os.access('shpy.pl',os.F_OK): 
    print "file exists" 
else:
    print "file does not exist" 

print "TEST: using logical operators" 
if not 2 != 2: 
    print 'equal' 
else:
    print 'not', 'equal' 

print "TEST: && and ||" 
if 2 >= 2 and 1 >= 1: 
    print 'both', 'greater', 'than', 'or', 'equal' 

if 2 == 2 or 3 == 1: 
    print 'one', 'or', 'both', 'equal' 

print "TEST: elif and variables" 
num = '3' 
if int(num) == 1: 
    print 'equal', 'to', '1' 
elif int(num) == 2: 
    print 'equal', 'to', '2' 
elif int(num) == 3: 
    print 'equal', 'to', '3' 
