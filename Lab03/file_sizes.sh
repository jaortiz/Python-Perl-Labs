#!/bin/sh

for file in *
do
   lineCount=`wc -l < $file`
   if [ $lineCount -lt 10 ]; then
      smallFiles+=" $file"
   elif [ $lineCount -lt 100 ]; then
      mediumFiles+=" $file"
   else
      largeFiles+=" $file"
   fi
done

echo "Small files:$smallFiles"
echo "Medium-sized files:$mediumFiles"
echo "Large files:$largeFiles"
exit 0
