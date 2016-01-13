#!/usr/bin/python
import sqlite3, glob, os, re, sys

# --------------------------------------------------------------------------------------------
# setUpDB.py 
# Helper script to create a database and populate it with the bitter data
# --------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
# Creates the initial tables for the bitter database
# --------------------------------------------------------------------------------------------
def createDB():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   
   c.execute('''CREATE TABLE IF NOT EXISTS bleats (
                                                   BLEATID     INTEGER PRIMARY KEY,
                                                   USERNAME    TEXT,
                                                   TIME        INTEGER,
                                                   LONGITUDE   TEXT,
                                                   LATITUDE    TEXT,
                                                   BLEAT       TEXT,
                                                   INREPLYTO   TEXT)''')
   
   c.execute('''CREATE TABLE IF NOT EXISTS users    (
                                                   USERNAME   TEXT PRIMARY KEY,
                                                   PASSWORD         TEXT,
                                                   EMAIL            TEXT,
                                                   FULLNAME         TEXT,
                                                   HOMELATITUDE     TEXT,
                                                   HOMELONGITUDE    TEXT,
                                                   HOMESUBURB       TEXT,
                                                   VERIFIED         INTEGER,
                                                   PROFILEPIC       TEXT,
                                                   SUSPENDED        INTEGER,
                                                   PROFILETEXT      TEXT)''')
                                                   
   c.execute('''CREATE TABLE IF NOT EXISTS sessions (
                                                      SESSIONID      TEXT PRIMARY KEY,
                                                      USERNAME       TEXT)''')
                              
   c. execute('''CREATE TABLE IF NOT EXISTS listens(
                                                    ID               INTEGER PRIMARY KEY AUTOINCREMENT,
                                                    USERNAME         TEXT,
                                                    LISTENSTO        TEXT)''')
                                                      
                                                                       
   db.commit()                                                 
   
# --------------------------------------------------------------------------------------------
# Reads in all the beats from the files and adds them to the beats table in the bitter db
# -------------------------------------------------------------------------------------------- 
def populateBleatsDB():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   
   for bleatPath in glob.glob("dataset-medium/bleats/*"): #os.listdir("dataset-small/bleats"): 
      bleatID = re.sub(r'[^0-9]','',bleatPath)
      
      # username, time, bleat are fields I will assume will always be filled out while the below will not
      # initialising to empty string for insertion to database
      
      longitude = ""
      latitude = ""
      inReplyTo = ""      
      
      for line in open(bleatPath):
         line = line.rstrip()
         if re.match("^username",line):
            username = re.sub(r'.*:','',line)   #getting the username
            username = re.sub(r'^ *','',username)  #stripping any beginning whitespace
            
         elif re.match("^time",line):
            time = re.sub(r'.*:','',line)
            time = re.sub(r'^ *','',time)
            
         elif re.match("^bleat",line):
            bleat = re.sub(r'.*:','',line)
            bleat = re.sub(r'^ *','',bleat)
            
         elif re.match("^longitude",line):
            longitude = re.sub(r'.*:','',line)
            longitude = re.sub(r'^ *','',longitude)
            
         elif re.match("^latitude",line):
            latitude = re.sub(r'.*:','',line)
            latitude = re.sub(r'^ *','',latitude)
         
         elif re.match("^in_reply_to",line):
            inReplyTo = re.sub(r'.*:','',line)
            inReplyTo = re.sub(r'^ *','',inReplyTo)
         
      #print bleatID, username,time, bleat, longitude, latitude, inReplyTo
      c.execute('''INSERT INTO bleats(BLEATID, USERNAME, TIME, LONGITUDE, LATITUDE, BLEAT, INREPLYTO) 
                        VALUES(:bleatid, :username, :time, :longitude, :latitude, :bleat, :inreplyto)''',
                        {'bleatid':bleatID, 'username':username, 'time':time, 'longitude':longitude, 'latitude':latitude,
                           'bleat':bleat, 'inreplyto':inReplyTo})
      db.commit()
   print "bleats successfully inserted"    
   
# --------------------------------------------------------------------------------------------
# Reads in all the users from the files and adds them to the user table in the bitter db
# --------------------------------------------------------------------------------------------
def populateUsersDB():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   
   for userPath in glob.glob("dataset-medium/users/*"):  
      #Assuming that all details.txt are completed
      profilePic = ""
      if os.path.isfile(userPath + "/profile.jpg"):
         profilePic = userPath + "/profile.jpg"
      else:
         profilePic = "images/defaultProfile.jpg"
      
      for line in open("%s/details.txt" % userPath):
         line = line.rstrip()
         if re.match("^username",line):
            username = re.sub(r'.*:','',line)   #getting the username
            username = re.sub(r'^ *','',username)  #stripping any beginning whitespace
            
         elif re.match("^email",line):
            email = re.sub(r'.*:','',line)
            email = re.sub(r'^ *','',email)
            
         elif re.match("^password",line):
            password = re.sub(r'.*:','',line)
            password = re.sub(r'^ *','',password)
         
         elif re.match("^full_name",line):
            fullName = re.sub(r'.*:','',line)
            fullName = re.sub(r'^ *','',fullName)
                     
         elif re.match("^home_latitude",line):
            homeLatitude = re.sub(r'.*:','',line)
            homeLatitude = re.sub(r'^ *','',homeLatitude)
         
         elif re.match("^home_longitude",line):
            homeLongitude = re.sub(r'.*:','',line)
            homeLongitude = re.sub(r'^ *','',homeLongitude)
            
         elif re.match("^home_suburb",line):
            homeSuburb = re.sub(r'.*:','',line)
            homeSuburb = re.sub(r'^ *','',homeSuburb)
            
         elif re.match("^listens",line):
            listens = re.sub(r'.*:','',line)
            listens = re.sub(r'^ *','',listens)
      
      
      #print username, email, password, fullName, homeLatitude, homeLongitude, homeSuburb, listens
      c.execute('''INSERT INTO users(USERNAME, PASSWORD, EMAIL, FULLNAME, HOMELATITUDE, HOMELONGITUDE, HOMESUBURB,VERIFIED, PROFILEPIC, SUSPENDED)
       VALUES(:username, :password, :email, :fullname, :homeLatitude, :homeLongitude, :homeSuburb, :verified, :profilepic, :suspended)'''
                     , {'username':username, 'password':password, 'email':email, 'fullname':fullName, 
                     'homeLatitude':homeLatitude,'homeLongitude':homeLongitude, 'homeSuburb':homeSuburb,
                     'verified': int("1"), 'profilepic':profilePic, 'suspended':int("0")})
      db.commit()
      
      for user in re.findall(r'[a-zA-Z0-9]+',listens): 
         c.execute('''INSERT INTO listens(USERNAME,LISTENSTO) VALUES (?,?)''',(username,user))
         db.commit()
   print "users successfully inserted"

# --------------------------------------------------------------------------------------------
# Drops the user table from the database
# --------------------------------------------------------------------------------------------
def dropUsersTable():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DROP TABLE users''')
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Drops the bleats table from the database
# --------------------------------------------------------------------------------------------   
def dropBleatsTable():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DROP TABLE bleats''')
   db.commit()

# --------------------------------------------------------------------------------------------
# Drops the sessions table from the database
# --------------------------------------------------------------------------------------------   
def dropSessionsTable():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DROP TABLE sessions''')
   db.commit()

# --------------------------------------------------------------------------------------------
# Drops the listens table from the database
# --------------------------------------------------------------------------------------------   
def dropListensTable():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DROP TABLE listens''')
   db.commit()

# --------------------------------------------------------------------------------------------
# Clears all the entries from the sessions table
# --------------------------------------------------------------------------------------------   

def clearSessions():
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DELETE FROM sessions''')
   db.commit()

# --------------------------------------------------------------------------------------------  
# MAIN
# --------------------------------------------------------------------------------------------  
if len(sys.argv) != 2:
   print "Usage %s [init|drop|clear]" %sys.argv[0]
   sys.exit(1)

if sys.argv[1] == "init":
   createDB()
   populateBleatsDB()
   populateUsersDB()
elif sys.argv[1] == "drop":
   dropUsersTable()
   dropBleatsTable()
   dropSessionsTable()
   dropListensTable()
elif sys.argv[1] == "clear":
   clearSessions()
   


















