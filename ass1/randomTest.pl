#!/usr/bin/perl -w
use Text::ParseWords;

$random = '"test this" test';
@words = quotewords('\s+',0,$random);

foreach(@words) {
   print "$_\n";
}

$mvString = "mv /test/directory/source     /test/directory/dest/";
my ($src, $dest) = $mvString =~ /^mv *([^ ]+) *([^ ]+)/;

print "shutil.move('$src', '$dest')\n";    


