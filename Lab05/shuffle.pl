#!/usr/bin/perl -w

@lines = <>;
while(@lines) {
   print splice(@lines,rand(@lines),1);
}
