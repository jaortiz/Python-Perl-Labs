#!/usr/bin/python

import sqlite3, sys, time
# --------------------------------------------------------------------------------------------
# bleatActions.py 
# Is a helper script to deal with any operations that use bleats
# --------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
# Gets all bleats from a user by querying the db
# Returns user bleats
# --------------------------------------------------------------------------------------------
def viewAllBleatsByUser(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM bleats WHERE USERNAME = ? ORDER BY TIME DESC''',(username,))
   results = c.fetchall()
   
   return results

# --------------------------------------------------------------------------------------------
# Queries the db for all relevant bleats for the passed in user i.e. who they listen to
# their own bleats and if they are mentioned in a bleat
# Returns relevant bleats
# --------------------------------------------------------------------------------------------
def viewAllRelevantBleats(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT  DISTINCT bleats.BLEATID, bleats.USERNAME, bleats.TIME, 
                  bleats.LONGITUDE, bleats.LATITUDE, bleats.BLEAT,bleats.INREPLYTO
                  FROM users,bleats
	               JOIN listens ON users.USERNAME = listens.USERNAME
	               WHERE (users.USERNAME = ? AND bleats.USERNAME = listens.LISTENSTO) OR 
	               (bleats.USERNAME = ?) OR (bleats.BLEAT LIKE '%' || ? || '%')
	               ORDER BY bleats.TIME DESC''',(username,username,username))
   results = c.fetchall()

   return results
   
# --------------------------------------------------------------------------------------------
# Searches all bleats for anything matching the passed in query
# Returns results set of query
# --------------------------------------------------------------------------------------------
def searchBleats(searchQuery):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM bleats WHERE BLEAT LIKE '%' || ? || '%' ''',(searchQuery,))
   results = c.fetchall()
  
   return results

# --------------------------------------------------------------------------------------------
# Inserts a bleat into the database for the given user
# --------------------------------------------------------------------------------------------
def insertBleat(username, bleatStr):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT MAX(BLEATID) FROM bleats''')
   results = c.fetchall()
   
   # getting the current max bleat id and incrementing, not the best method...
   bleatID, = results[0]
   bleatID = bleatID + 1

   curTime = int(time.time())   # time since epoch (Jan 1 1970)
   
   c.execute('''INSERT INTO bleats(BLEATID, USERNAME, TIME, LONGITUDE, LATITUDE, BLEAT, INREPLYTO) 
               VALUES(?,?,?,?,?,?,?)''',
               (bleatID, username, curTime, "", "", bleatStr, ""))
               
              # {'bleatid':bleatID, 'username':username, 'time':curTime, 'bleat':str(bleatStr)})
   db.commit()

# --------------------------------------------------------------------------------------------
# Inserts a reply bleat into the database for the given user
# --------------------------------------------------------------------------------------------
def replyToBleat(username, inReplyToBleatID, bleatStr):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT MAX(BLEATID) FROM bleats''')
   results = c.fetchall()
   
   # getting the current max bleat id and incrementing, not the best method...
   bleatID, = results[0]
   bleatID = bleatID + 1

   curTime = int(time.time())   # time since epoch (Jan 1 1970)
   
   c.execute('''INSERT INTO bleats(BLEATID, USERNAME, TIME, LONGITUDE, LATITUDE, BLEAT, INREPLYTO) 
               VALUES(?,?,?,?,?,?,?)''',
               (bleatID, username, curTime, "", "", bleatStr, inReplyToBleatID))
   db.commit()

# --------------------------------------------------------------------------------------------
# Queries the database for a bleat given a bleat ID
# Returns bleat 
# --------------------------------------------------------------------------------------------
def getBleatByID(bleatID):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM bleats WHERE BLEATID = ?''',(bleatID,))
   results = c.fetchall()
   
   return results


# --------------------------------------------------------------------------------------------
# Testing Area
# --------------------------------------------------------------------------------------------
#insertBleat("TenderAaron","testbleater")












