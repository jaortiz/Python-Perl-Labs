#!/usr/bin/python2.7 -u
import shutil
import subprocess
import os

#commands testing and variables

print "TEST: unix/shell commands" 
subprocess.call(['pwd']) 
subprocess.call(['id']) 
subprocess.call(['date']) 

subprocess.call(['ls']) 
subprocess.call(['ls', '-l']) 

print "TEST: file creation" 
file1 = './file1.txt' 
file2 = './file2.txt' 
blah = 'foo' 
with open( file1, 'a') as f: print >>f, blah  

if os.access(file1,os.F_OK): 
    print "file created" 
else:
    print "file not created" 

print "TEST: mv" 
shutil.move(file1, file2)

if not os.access(file1,os.F_OK) and os.access(file2,os.F_OK): 
    print 'move', 'successful' 
else:
    print 'move', 'not', 'successful' 

print "TEST: rm" 
subprocess.call(['rm', '-f', str(file2)]) 
if not os.access(file2,os.F_OK): 
    print 'remove', 'successful' 
else:
    print 'remove', 'not', 'successful' 
