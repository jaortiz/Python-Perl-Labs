#!/usr/bin/python

import bleatActions
import userActions

# --------------------------------------------------------------------------------------------
# viewPage.py
# Handles the presentation logic of the website
# Generates all the html to be printed by the cgi
# --------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
# Returns the html of al the bleats associated with a user
# --------------------------------------------------------------------------------------------
def userHome(username):
   #retrieving the html to print
   userHomeFile = open("html/userHome.html", "r")
   userHome = userHomeFile.read()
   userHomeFile.close()
   
   bleatFile = open("html/bleat.html", "r")
   bleatHTML = bleatFile.read()
   bleatFile.close()
   
   userArr = userActions.getUserInfoByUserName(username)
   userInfo = userArr[0]
   
   #bleatArr = bleatActions.viewAllBleatsByUser(username)
   bleatArr = bleatActions.viewAllRelevantBleats(username)
   bleatString = ""
   
   for bleat in bleatArr:
      userProfilePic = userActions.getProfilePic(str(bleat[1]))
      bleatString += bleatHTML % {"bleatid":str(bleat[0]), "username":str(bleat[1]), "time":str(bleat[2]), 
         "longitude":str(bleat[3]), "latitude":str(bleat[4]), "bleat":str(bleat[5]),
         "inReplyTo":str(bleat[6]), "profilepic":userProfilePic}
   
   #print userHome % { "user":str(userInfo[0]), "fullName":str(userInfo[3]), "bleats": bleatString}
   return userHome % { "bleats": bleatString, "user":str(userInfo[0]), "fullName":str(userInfo[3]),
                        "profilepic":str(userInfo[8]), "homeLatitude":str(userInfo[4]), "homeLongitude":str(userInfo[5]), "homeSuburb":str(userInfo[6]), "profileText":str(userInfo[10])}

# --------------------------------------------------------------------------------------------
# Returns the html of all the relevant users and bleats relating to the search query
# --------------------------------------------------------------------------------------------
def search(searchQuery):
   #retrieving the search page html to print
   searchFile = open("html/search.html","r")
   searchPage = searchFile.read()
   searchFile.close()
   
   #User ops
   userFile = open("html/user.html","r")
   userHTML = userFile.read()
   userFile.close()
   
   userArr = userActions.searchUsers(searchQuery)
   userString = ""
   
   for user in userArr:
      userString += userHTML % {"username":str(user[0]), "fullName":str(user[3]), "profilepic":str(user[8])}
   
   #bleat ops
   bleatFile = open("html/bleat.html", "r")
   bleatHTML = bleatFile.read()
   bleatFile.close()
   
   bleatArr = bleatActions.searchBleats(searchQuery)
   bleatString = ""
   
   for bleat in bleatArr:
      userProfilePic = userActions.getProfilePic(str(bleat[1]))
      bleatString += bleatHTML % {"bleatid":str(bleat[0]), "username":str(bleat[1]), "time":str(bleat[2]), 
         "longitude":str(bleat[3]), "latitude":str(bleat[4]), "bleat":str(bleat[5]),
         "inReplyTo":str(bleat[6]), "profilepic":userProfilePic}
   
   return searchPage % {"users":userString, "bleats":bleatString}

# --------------------------------------------------------------------------------------------
# Returns the html of the user profile
# --------------------------------------------------------------------------------------------
def userProfile(username):
   userFile = open("html/userProfile.html", "r")
   userPage = userFile.read()
   userFile.close()
   
   #listener = ""
   if userActions.isListeningTo(username):
      listenFile = open("html/unlisten.html")
      listener = listenFile.read()
      listener = listener % {"username":username}
   else:
      listenFile = open("html/listen.html")
      listener = listenFile.read()
      
   listenFile.close()
   listener = listener % {"username":username}
   
   bleatFile = open("html/bleat.html", "r")
   bleatHTML = bleatFile.read()
   bleatFile.close()
   
   
   bleatArr = bleatActions.viewAllBleatsByUser(username)
   bleatString = ""
   
   for bleat in bleatArr:
      userProfilePic = userActions.getProfilePic(str(bleat[1]))
      bleatString += bleatHTML % {"bleatid":str(bleat[0]),"username":str(bleat[1]), "time":str(bleat[2]), "longitude":str(bleat[3]),
      "latitude":str(bleat[4]), "bleat":str(bleat[5]), "inReplyTo":str(bleat[6]), "profilepic":userProfilePic}
   
   user, = userActions.getUserInfoByUserName(username)
   
   return userPage % {"username":username, "fullName":str(user[3]), "bleats":bleatString, "listener":listener, "profilepic":str(user[8]), "homeLatitude":str(user[4]), "homeLongitude":str(user[5]), "homeSuburb":str(user[6]), "profileText":str(user[10])}
   #print userPage % {"username":username, "fullName":fullName, "bleats":bleatString, "listener":listener, "profilepic":str(user[8]), "homeLatitude":str(user[4]), "homeLongitude":str(user[5]), "homeSuburb":str(user[6])}
# --------------------------------------------------------------------------------------------
# Generate the html for a reply
# --------------------------------------------------------------------------------------------
def reply(replyToID):
   bleatArr = bleatActions.getBleatByID(replyToID) 
   bleat = bleatArr[0]  #since the return is a list, getting the first element
   
   bleatFile = open("html/bleatOnly.html")
   bleatHTML = bleatFile.read()
   bleatFile.close()
   
   user, = userActions.getUserInfoByUserName(str(bleat[1]))
   
   bleatHTML = bleatHTML % {"username":str(bleat[1]), "time":str(bleat[2]), "longitude":str(bleat[3]),
      "latitude":str(bleat[4]), "bleat":str(bleat[5]), "inReplyTo":str(bleat[6]), "profilepic":str(user[8])}
   
   replyFile = open("html/reply.html", "r")
   replyPage = replyFile.read()
   replyFile.close()
   
   return replyPage % {"bleat":bleatHTML, "bleatID":replyToID}
   #print replyPage % {"bleat":bleatHTML, "bleatID":replyToID}

# --------------------------------------------------------------------------------------------
# Generic Message page
# --------------------------------------------------------------------------------------------
def message(msg):
   messageFile = open("html/message.html")
   messageHTML = messageFile.read()
   messageFile.close()
   
   return messageHTML % {"message": msg}

# --------------------------------------------------------------------------------------------
# Show Settings Page
# --------------------------------------------------------------------------------------------
def settings():
   settingsFile = open("html/settings.html")
   settingsHTML = settingsFile.read()
   settingsFile.close()
   
   return settingsHTML

# --------------------------------------------------------------------------------------------
# Show Reset Password Page
# --------------------------------------------------------------------------------------------
def resetPasswordView(username):
   resetFile = open("html/resetPassword.html")
   resetHTML = resetFile.read()
   resetFile.close()
   
   return resetHTML % {"username":username}
# --------------------------------------------------------------------------------------------
# Helper Test Function
# --------------------------------------------------------------------------------------------
def test(user, bleatStr):
   testFile = open("html/test.html","r")
   testPage = testFile.read()
   testFile.close()
   
   return testPage % {"bleats":bleatStr, "user": user}
# --------------------------------------------------------------------------------------------
# TESTING AREA
# --------------------------------------------------------------------------------------------
#userHome("TenderAaron")
#userProfile("DaisyFuentes","Daisy Fuentes")
#reply("2041904142")
#search("DaisyFuentes")
#resetPasswordView("TenderAaron")



