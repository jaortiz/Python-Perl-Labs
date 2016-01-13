#!/usr/bin/python

import sqlite3, Cookie, uuid, os
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

# --------------------------------------------------------------------------------------------
# userActions.py
# Helper script to deal with any operations that involve the user
# --------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
# Checks whether or not the password matches the one associated with the username
# Also checks whether or not the user is verified
# Return bool
# --------------------------------------------------------------------------------------------
def checkLogin(username, password):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   
   c.execute('''SELECT PASSWORD FROM users WHERE USERNAME = ? AND VERIFIED = 1 ''', (username,))
   results = c.fetchall()
   
   if len(results) != 1:
      return False
   
   dbPassword, = results[0]
  
   if dbPassword == password:
      return True
   else:
      return False

# --------------------------------------------------------------------------------------------
# Queries the database to get the session id associtated with a user
# Returns session id associated with a user or new session id
# --------------------------------------------------------------------------------------------
def getSessionID(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   
   c.execute('''SELECT SESSIONID FROM sessions WHERE USERNAME = ?''',(username,))
   results = c.fetchall()
   
   if len(results) != 0:
      sessionid, = results[0]
      
   else:
      sessionid = str(uuid.uuid4())
      c.execute('''INSERT INTO sessions(SESSIONID, USERNAME) VALUES(:sessionid, :username)''',
                           {'sessionid':sessionid, 'username':username})
      db.commit()
   return sessionid

# --------------------------------------------------------------------------------------------
# Creates a session cookie 
# Return cookie header
# --------------------------------------------------------------------------------------------
def createSessionCookie(username):
   cookie = Cookie.SimpleCookie()
   cookie["sessionid"] = getSessionID(username)
   
   return cookie.output()

# --------------------------------------------------------------------------------------------
# Deletes a session cookie
# Return cookie header
# --------------------------------------------------------------------------------------------
def deleteSessionCookie():
   cookie = Cookie.SimpleCookie()
   cookie["sessionid"] = ""
   cookie["sessionid"]["expires"] = "Thu, 01 Jan 1970 00:00:00 GMT"
   return cookie.output()
   
# --------------------------------------------------------------------------------------------
# Checks whether a user is logged in by checking if the sessionid has been set in cookie
# Return bool
# --------------------------------------------------------------------------------------------   
def isLoggedIn():
   cookie = Cookie.SimpleCookie(os.getenv("HTTP_COOKIE"))
   if "sessionid" in cookie:
      return True
   else:
      return False
      
# --------------------------------------------------------------------------------------------   
# Logs out a user by deleting them from the session table
# --------------------------------------------------------------------------------------------   
def logOut(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DELETE FROM sessions WHERE USERNAME = ?''',(username,))
   db.commit()

# --------------------------------------------------------------------------------------------   
# Looks at the session cookie and determines who is logged in
# Return currentUser or none
# --------------------------------------------------------------------------------------------   
def getCurrentUser():
   cookie = Cookie.SimpleCookie(os.getenv("HTTP_COOKIE"))
   if "sessionid" in cookie:
      session = cookie["sessionid"].value
      return getUsername(session)
   else:
      return None
      
# --------------------------------------------------------------------------------------------   
# Finds the user associated with the session id
# Return user 
# --------------------------------------------------------------------------------------------   
def getUsername(sessionid):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT USERNAME FROM sessions WHERE SESSIONID = ?''',(sessionid,))
   results = c.fetchall()
   
   if len(results) != 0:
      user, = results[0]
      return user
      
   else:
      return None
   
# --------------------------------------------------------------------------------------------   
# Queries database to get all information about a given user
# Return result list
# --------------------------------------------------------------------------------------------   
def getUserInfoByUserName(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM users WHERE USERNAME = ?''',(username,))
   results = c.fetchall()
   return results

# --------------------------------------------------------------------------------------------   
# Searches for all users by username or full name based on the query
# Return result list
# --------------------------------------------------------------------------------------------   

def searchUsers(searchQuery):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM users WHERE (USERNAME LIKE '%' || ? || '%' OR 
                                       FULLNAME LIKE '%' || ? || '%') AND SUSPENDED = 0 ''',(searchQuery,searchQuery,))
   results = c.fetchall()
   return results
   
# --------------------------------------------------------------------------------------------
# Checks whether the current user is listening to the given user
# Return bool
# --------------------------------------------------------------------------------------------
def isListeningTo(listenTo):
   user = getCurrentUser()

   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM listens WHERE USERNAME = ? AND LISTENSTO = ?''',(user,listenTo))
   results = c.fetchall()
   
   if len(results) != 0:
      return True
   else:   
      return False

# --------------------------------------------------------------------------------------------
# Add the given user to the current users listeners
# --------------------------------------------------------------------------------------------
def listen(listenTo):
   user = getCurrentUser()
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''INSERT INTO listens(USERNAME, LISTENSTO) VALUES(?,?)''',(user,listenTo))
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Removes the given user from the current users listeners
# --------------------------------------------------------------------------------------------
def unlisten(listenTo):
   user = getCurrentUser()
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DELETE FROM listens WHERE USERNAME = ? AND LISTENSTO = ?''',(user,listenTo))
   db.commit()

# --------------------------------------------------------------------------------------------
# Signs a user up to bitter
# Returns True if created successfully, false if not
# --------------------------------------------------------------------------------------------
def signUp(username, fullName, email, password):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM users WHERE USERNAME = ?''',(username,))
   results = c.fetchall()
   if len(results) != 0:   #username already exists
      return False
   
   #create account
   c.execute('''INSERT INTO users(USERNAME, EMAIL, PASSWORD, FULLNAME, VERIFIED, PROFILEPIC, SUSPENDED) 
   VALUES(?,?,?,?,?,?,?)''',(username,email,password,fullName,int("0"),"images/defaultProfile.jpg", int("0")))
   db.commit()
   sendVerificationEmail(username, fullName, email)
   return True

# --------------------------------------------------------------------------------------------
# Sends a verification email to the new user
# --------------------------------------------------------------------------------------------
def sendVerificationEmail(username, fullName, email):
   bitterEmail = "bitter.control@gmail.com"  
   mailServer = smtplib.SMTP("smtp.gmail.com", 587)
   mailServer.ehlo()
   mailServer.starttls()
   mailServer.ehlo()
   mailServer.login(bitterEmail, "bitter2041")
   
   url = "http://cgi.cse.unsw.edu.au/~z3461601/ass2/bitter.cgi?operation=verify&user="+username
   
   htmlFile = open("html/emailVerify.html")
   emailContent = htmlFile.read()
   htmlFile.close()
   emailContent = emailContent % {"fullName":fullName, "url":url, "username":username}
   
   msg = MIMEMultipart()
   msg["From"] = bitterEmail
   msg["To"] = email
   msg["Subject"] = "Bitter Verification"
   
   msg.attach(MIMEText(emailContent,"html"))
   
   mailServer.sendmail(bitterEmail, email, msg.as_string())
   mailServer.quit()
   
# --------------------------------------------------------------------------------------------
# Verifies a user
# --------------------------------------------------------------------------------------------
def verify(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''UPDATE users SET VERIFIED = 1 WHERE USERNAME = ?''',(username,))
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Sends an email with recover password options
# Returns bool 
# --------------------------------------------------------------------------------------------
def recoverPassword(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT * FROM users WHERE USERNAME = ?''',(username,))
   results = c.fetchall()
   
   if len(results) != 0:   
      user = results[0]
      sendPasswordRecoveryEmail(username, str(user[2]),str(user[3]))
      return True
   else:
      return False

# --------------------------------------------------------------------------------------------
# Send password recovery email to user
# --------------------------------------------------------------------------------------------
def sendPasswordRecoveryEmail(username, email, fullName):
   
   bitterEmail = "bitter.control@gmail.com"  
   mailServer = smtplib.SMTP("smtp.gmail.com", 587)
   mailServer.ehlo()
   mailServer.starttls()
   mailServer.ehlo()
   mailServer.login(bitterEmail, "bitter2041")
   
   url = "http://cgi.cse.unsw.edu.au/~z3461601/ass2/bitter.cgi?operation=resetPasswordView&user="+username
   
   htmlFile = open("html/emailRecoverPassword.html")
   emailContent = htmlFile.read()
   htmlFile.close()
   emailContent = emailContent % {"fullName":fullName, "url":url, "username":username}
   
   msg = MIMEMultipart()
   msg["From"] = bitterEmail
   msg["To"] = email
   msg["Subject"] = "Bitter Verification"
   
   msg.attach(MIMEText(emailContent,"html"))
   
   mailServer.sendmail(bitterEmail, email, msg.as_string())
   mailServer.quit()

# --------------------------------------------------------------------------------------------
# Resets the password for the given account
# --------------------------------------------------------------------------------------------
def resetPassword(username, password):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''UPDATE users SET PASSWORD = ? WHERE USERNAME = ?''',(password, username,))
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Deletes a users account
# --------------------------------------------------------------------------------------------
def deleteAccount(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''DELETE FROM users WHERE USERNAME = ?''',(username,))
   db.commit()

# --------------------------------------------------------------------------------------------
# Suspends user account
# --------------------------------------------------------------------------------------------
def suspendAccount(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''UPDATE users SET SUSPENDED = 1 WHERE USERNAME = ?''',(username,))
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Unsuspends user account
# --------------------------------------------------------------------------------------------
def unsuspendAccount(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''UPDATE users SET SUSPENDED = 0 WHERE USERNAME = ?''',(username,))
   db.commit()
   
# --------------------------------------------------------------------------------------------
# Gets the path to the users profile picture
# Return profile pic path
# --------------------------------------------------------------------------------------------
def getProfilePic(username):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   c.execute('''SELECT PROFILEPIC FROM users WHERE USERNAME = ?''',(username,))
   results = c.fetchall()
   
   profilePic, = results[0]
   return profilePic

# --------------------------------------------------------------------------------------------
# Updates the user account with the given information
# --------------------------------------------------------------------------------------------
def updateAccount(username, password, email, fullName, homeLatitude, homeLongitude, homeSuburb, profileText):
   db = sqlite3.connect("bitter.db")
   c = db.cursor()
   if password:
      c.execute('''UPDATE users SET PASSWORD = ? WHERE USERNAME = ?''',(password, username))   
      db.commit()
   
   if email:
      c.execute('''UPDATE users SET EMAIL = ? WHERE USERNAME = ?''',(email, username))   
      db.commit()
   
   if fullName:
      c.execute('''UPDATE users SET FULLNAME = ? WHERE USERNAME = ?''',(fullName, username))   
      db.commit()
   
   if homeLatitude:
      c.execute('''UPDATE users SET HOMELATITUDE = ? WHERE USERNAME = ?''',(homeLatitude, username))   
      db.commit()

   if homeLongitude:
      c.execute('''UPDATE users SET HOMELONGITUDE = ? WHERE USERNAME = ?''',(homeLongitude, username))   
      db.commit()
   
   if homeSuburb:
      c.execute('''UPDATE users SET HOMESUBURB = ? WHERE USERNAME = ?''',(homeSuburb, username))   
      db.commit()

   if profileText:
      c.execute('''UPDATE users SET PROFILETEXT = ? WHERE USERNAME = ?''',(profileText, username))   
      db.commit()
   
# --------------------------------------------------------------------------------------------
# Testing Area
# --------------------------------------------------------------------------------------------
#print checkLogin("TenderAaron","oliver")
#createSessionCookie()
#print deleteSessionCookie()
#print isListeningTo("DaisyFuentes")
#signUp("test", "test", "jort1z@hotmail.com", "password")
#verify("test")
#sendVerificationEmail("test", "test", "jort1z@hotmail.com")
#recoverPassword("TenderAaron")
#resetPassword("TenderAaron","password")
#getProfilePic("TenderAaron")



