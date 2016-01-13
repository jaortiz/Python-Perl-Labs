#!/bin/sh

if [ $# -eq 0 ]; then
   echo "Usage: $0 <image>+"
   exit 1
else
   for image in "$@"
   do
      display "$image"
      echo -n "Address to email this image to?"
      read email
      
      if [ "$email" ]; then
         echo -n "Message to accompany image?"
         read message
         echo "$message" | mutt -s "email_image" -a "$image" -- "$email"      
         echo "$@ sent to $email"   
      else
         echo "invalid email address"
      fi
      
   done

fi
