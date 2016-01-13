#!/bin/sh

if [ $# -eq 0 ]; then
   echo "Usage: $0 <image>+"
   exit 1
else
   for image in "$@"
   do
      lastModified=`ls -l "$image"| cut -d ' ' -f6-8 ` 
      tempImage="$image.$$"      #creating temporary file for copying/converting

      convert -gravity south -pointsize 36 -draw "text 0,10 '$lastModified'" "$image" "$tempImage" 

      touch -r "$image" "$tempImage"   #preserving the last modified date
      cp -p "$tempImage" "$image"      #copying from temp to original
      rm "$tempImage"
   done
fi

