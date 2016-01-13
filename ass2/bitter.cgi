#!/usr/bin/python

# Accessed At
# http://cgi.cse.unsw.edu.au/~z3461601/ass2/bitter.cgi

import cgi, cgitb, glob, os, sys
import userActions
import viewPage
import bleatActions

cgitb.enable()
form = cgi.FieldStorage()

cookieCreated = None

# --------------------------------------------------------------------------------------------
# prints http header 
# --------------------------------------------------------------------------------------------
def httpHeader(cookie):
   if cookie:
      print "Content-Type: text/html"
      print cookie
      print ""
   else:
      print "Content-Type: text/html"
      print ""
      
   return

# --------------------------------------------------------------------------------------------
# Functions to handle all the back-end functions i.e. controller
# Each html form is an "operation" and the following ifs handle each operation appropriately
# --------------------------------------------------------------------------------------------
if "operation" in form and "Log In" in form.getlist("operation"):
   if userActions.checkLogin(form.getfirst("username"), form.getfirst("password")):
      cookieCreated = userActions.createSessionCookie(form.getfirst("username"))
      html = viewPage.userHome(form.getfirst("username"))
   else:
      html = viewPage.message("Incorrect Username or Password")
            
elif "operation" in form and "Sign Up" in form.getlist("operation"):
   if userActions.signUp(form.getfirst("username"), form.getfirst("fullName"), 
                                                form.getfirst("email"), form.getfirst("password")):
      html = viewPage.message("Account Created, Verification email sent")
   else:
      html = viewPage.message("Sorry that username is unavailable")

elif "operation" in form and "Log Out" in form.getlist("operation"):
   if userActions.isLoggedIn():
      userActions.logOut(userActions.getCurrentUser())   
      cookieCreated = userActions.deleteSessionCookie()
      loginFile = open("html/login.html","r")
      html = loginFile.read()
      
elif "operation" in form and "search" in form.getlist("operation"):
   html = viewPage.search(form.getfirst("searchQuery"))

elif "operation" in form and "View Profile" in form.getlist("operation"):
   html = viewPage.userProfile(form.getfirst("username"))

elif "operation" in form and "Home" in form.getlist("operation"):
   html = viewPage.userHome(userActions.getCurrentUser())

elif "operation" in form and "Bleat" in form.getlist("operation"):
   bleatActions.insertBleat(userActions.getCurrentUser(),form.getfirst("bleatStr"))
   html = viewPage.userHome(userActions.getCurrentUser())   
   #html = viewPage.test(userActions.getCurrentUser(), form.getfirst("bleatStr"))

elif "operation" in form and "Unlisten" in form.getlist("operation"):
   userActions.unlisten(form.getfirst("username"))
   html = viewPage.userProfile(form.getfirst("username")) # TEMP
   #show msg page/use js instead

elif "operation" in form and "Listen" in form.getlist("operation"):
   userActions.listen(form.getfirst("username"))
   html = viewPage.userProfile(form.getfirst("username")) #TEMP
   #show msg page/ use js instead

elif "operation" in form and "Reply" in form.getlist("operation"):
   html = viewPage.reply(form.getfirst("bleatID"))

elif "operation" in form and "Reply To Bleat" in form.getlist("operation"):
   bleatActions.replyToBleat(userActions.getCurrentUser(), form.getfirst("bleatid"), 
                                                                        form.getfirst("bleatStr"))
   html = viewPage.userHome(userActions.getCurrentUser())

elif "operation" in form and "verify" in form.getlist("operation"):
   userActions.verify(form.getfirst("user"))
   html = viewPage.message("Verified!")
   #show msg page

elif "operation" in form and "Settings" in form.getlist("operation"):
   html = viewPage.settings()

elif "operation" in form and "Update Account" in form.getlist("operation"):   # TO DO
   userActions.updateAccount(userActions.getCurrentUser(), form.getfirst("password"), form.getfirst("email"), form.getfirst("fullName"), form.getfirst("homeLatitude"), form.getfirst("homeLongitude"),
                                                                                                                                          form.getfirst("homeSuburb"), form.getfirst("profileText"))
   html = viewPage.settings()

elif "operation" in form and "Suspend Account" in form.getlist("operation"):
   userActions.suspendAccount(userActions.getCurrentUser())
   html = viewPage.settings()
   
elif "operation" in form and "Unsuspend Account" in form.getlist("operation"):
   userActions.unsuspendAccount(userActions.getCurrentUser())
   html = viewPage.settings()
   
elif "operation" in form and "Delete Account" in form.getlist("operation"):   #UNTESTED
   user = userActions.getCurrentUser()
   userActions.logOut(user) 
   userActions.deleteAccount(user)
   cookieCreated = userActions.deleteSessionCookie()
   loginFile = open("html/login.html","r")
   html = loginFile.read()

elif "operation" in form and "RecoverPassword" in form.getlist("operation"):
   if userActions.recoverPassword(form.getfirst("username")):
      html = viewPage.message("An email has been sent to your email address with instructions on how to recover your password")
   else:
      html = viewPage.message("Username doesn't exist")

elif "operation" in form and "Forgot Password" in form.getlist("operation"):
   forgotPassFile = open("html/forgotPassword.html")
   html = forgotPassFile.read()

elif "operation" in form and "resetPasswordView" in form.getlist("operation"):
   html = viewPage.resetPasswordView(form.getfirst("user"))

elif "operation" in form and "resetPassword" in form.getlist("operation"):
   userActions.resetPassword(form.getfirst("username"), form.getfirst("password"))
   loginFile = open("html/login.html","r")
   html = loginFile.read()
   
elif userActions.isLoggedIn():   #otherwise show the user their home page
   html = viewPage.userHome(userActions.getCurrentUser())

else: #otherwise show the login page
   loginFile = open("html/login.html","r")
   html = loginFile.read()

# Printing the HTML generated from the controller above
httpHeader(cookieCreated)
print html



