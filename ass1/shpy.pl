#!/usr/bin/perl -w 

# --------------------------------------------------------------
# FUNCTION PROTOTYPES
# --------------------------------------------------------------

sub echo ($);
sub command ($);
sub variableDeclaration ($);

# Control Structures
sub forLoop ($);
sub ifStatement($);
sub whileLoop ($);

# printing/outputting
sub printImports();
sub printPythonOutput();
sub addPythonImport($);
sub printIndentation ($);
sub outFile($);

# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

#including file with all the regex functions
require 'regexFunctions.pl' or die "Could not include regex functions\n";

#declaring output arrays and hashes
@pythonOutput = ();    #holds the lines of python translation
my %pythonImports;   #holds the python imports
my %variables;    #hold the variables of the script

#shell/unix command hash note: just arbitrarily initialising to 1
%commands = (     
   "echo" => 1,
   "ls" => 1,
   "pwd" => 1,
   "id" => 1,
   "date" => 1,
   "cd" => 1,
   "exit" => 1,
   "read" => 1,
   "rm" => 1,
   "mv" => 1,
);

# hash to hold built in variables
%preAssignedVars = (
   "\$#" => "len(sys.argv[1:])",
   "\$@" => "sys.argv[1:]",
);

# Integer comparison conversion hash
%numComparison = (
   "-gt" => ">",
   "-ge" => ">=",
   "-eq" => "==",
   "-ne" => "!=",
   "-lt" => "<",
   "-le" => "<=",
);


# boolean operation conversion hash
%boolOps = (
   "-o" => "or",
   "-a" => "and",
   "!" => "not",
   "&&" => "and",
   "||" => "or",
   
);

while (my $line = <>) { #read each line from stdin
   chomp $line;
   
   $line =~ s/^ +//; #removing indentation
   
   my ($command) = $line =~ /^([a-z]+)/;    #getting unix/shell commands if any 
   $command = lc $command;
   
   if ($line =~ /^#!/ && $. == 1) {
      print "#!/usr/bin/python2.7 -u\n";
   
   } elsif (exists $commands{$command}) {    #case for unix/shell commands
      command($line);

   } elsif (isVarDeclaration($line)) {    #case for variable declaration
      variableDeclaration($line);
      
   } elsif (isForLoop($line)) {  
      forLoop($line);
      
   } elsif (isWhileLoop($line)) {   
      whileLoop($line);
      
   } elsif (isDoStatement($line)) {
      push @pythonOutput, $line;
      
   } elsif (isDoneStatement($line)) {
      push @pythonOutput, $line;
      
   } elsif (isIfStatement($line) || isElifStatement($line)) {
      ifStatement($line);
      
   } elsif (isThenStatement($line)) {
      push @pythonOutput, $line;
   
   } elsif (isElseStatement($line)) {
      $line =~ s/ *$//;       #removing any trailing whitespace
      push @pythonOutput, "$line:";
 
   } elsif (isFiStatement($line)) {
      push @pythonOutput, $line;
   
   } elsif (isEmptyLine($line)) { 
      push @pythonOutput, "";
      
   } elsif (isComment($line)) {
      push @pythonOutput, "$line";
               
   } else { 
      push @pythonOutput, "#$line"; # Lines we can't translate are turned into comments

   }
   
}

printImports();      
printPythonOutput(); 


# --------------------------------------------------------------
# Functions
# --------------------------------------------------------------

# ------------------------------------------------------------------------------------
# Print Python Imports
# Prints the import libraries required for the python translations
# ------------------------------------------------------------------------------------
sub printImports() {
   if(keys %pythonImports) {  #check if there are imports to print
      foreach my $key (keys %pythonImports) {
         print "import $key\n";
      }
   }
}


# ------------------------------------------------------------------------------------
# Print Python Output
# Prints the translated contents of the python array and adds python indentation
# ------------------------------------------------------------------------------------
sub printPythonOutput() {
my $indent = 4;
my $indentCount = 0;
   for my $i (0..$#pythonOutput) {
   
      if(isDoStatement($pythonOutput[$i])) {
         $indentCount++;  
         
      } elsif (isDoneStatement($pythonOutput[$i]) || isFiStatement($pythonOutput[$i])) {
         $indentCount--;
         
      } elsif (isElifStatement($pythonOutput[$i])) {
         $indentCount--;
         printIndentation($indentCount);
         print "$pythonOutput[$i]\n";
      
      } elsif (isThenStatement($pythonOutput[$i])) {
         $indentCount++;
         
      } elsif ($pythonOutput[$i] =~ /^else:/) {
         $indentCount--;
         printIndentation($indentCount);
         print "$pythonOutput[$i]\n";
         $indentCount++;
      
      } elsif (isPrint($pythonOutput[$i])) {
         if(noNewline($pythonOutput[$i])) {
            $pythonOutput[$i] =~ s/ -n//;
            printIndentation($indentCount);
            print "$pythonOutput[$i]";
         } else {
            printIndentation($indentCount);
            print "$pythonOutput[$i]\n";
         }
      
      } else {
         printIndentation($indentCount);
         print "$pythonOutput[$i]\n";
      }
   } 
}


# ------------------------------------------------------------------------------------
# Unix/Shell Commands
# Translates the unix/shell command and adds it to the end of the python array
# Param: shell line 
# ------------------------------------------------------------------------------------
sub command ($) {
   my ($line) = @_ ;

   #checking for comments
   my $comment = "";
   if(hasComment($line)) { 
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   if($line =~ /^(echo)/) {   #if echo command
   
      if(isToOutFile($line)) {   #if outputting to a file
         outFile($line);   
         
      } else {
      
         my $string = "print ";  #creating string
         $line =~ s/^echo //; #remove beginning echo
         my @prints;
         
         if(noNewline($line)) {  #for -n option in echo
            $string .= "-n ";
            $line =~ s/(-n)//;
         }

         #different quotation cases
         if(hasSingleQuotes($line)) {
            @prints = ($line =~ /('[^']+')/g);   
            
         } elsif(hasDoubleQuotes($line)) {
            @prints = ($line =~ /("[^"]+")/g);
         
         } else {
            @prints = ($line =~ /[^ ]+/g);   #putting all print words into an array
            
         }
         
         foreach my $i (0..$#prints) {    #looping through array
            if(hasSingleQuotes($prints[$i]) || hasDoubleQuotes($prints[$i])) { #for quotes case
               #$prints[$i] =~ s/\$//g;
               $string .= $prints[$i];
            
            } elsif (isVariable($prints[$i])) {  #Checking for printing variables
               $prints[$i] =~ s/"//g;
               if(isPreAssignedVar($prints[$i])) {   #check if a command line argument
                  addPythonImport("sys");
                  if(isNumVar($prints[$i])) {   #if command line arg i.e $1 $2 etc
                     my ($numVar) = $prints[$i] =~ /^\$([0-9]+)/; #getting number
                     $string .= "sys.argv[$numVar]";
                     
                  } else {
                     $string .= "$preAssignedVars{$prints[$i]}";  #if built in var i.e $@ $#
                     
                  }

               } else { #for regular variables
                  $prints[$i] =~ s/^\$//;
                  $string .= "$prints[$i]";
               }
            } else {
               $string .= "'$prints[$i]'";   #concatenating
            }
            
            if ($i != $#prints) {      #making sure last variable doesnt have ',' following
               $string .= ", "
            }
            
         }
         push @pythonOutput, "$string $comment";  #adding string to output array
      }  
   } elsif ($line =~ /^(ls)/) {     #case for ls command
      addPythonImport("subprocess");   
      my $lsString = "subprocess.call([";
      
      foreach my $var ($line =~ /[^ ]+/g) {
         if(isVariable($var)) {  #case for variables
            $var =~ s/"//g;
            if(isNumVar($var)) { #if command line arg i.e. $1 $2
               addPythonImport("sys");
               my ($numVar) = $var =~ /^\$([0-9]+)/; #getting number
               $lsString .= "sys.argv[$numVar] ";
               
            } elsif(isPreAssignedVar($var)) {   #if built in variable $2 $# etc
               addPythonImport("sys");
               $lsString =~ s/, *$//;
               $lsString .= "] + $preAssignedVars{$var})"
            
            } else { #regular variable
               $var =~ s/^\$//;
               $lsString .= "'$var' ";
            }
         } else { 
            $lsString .= "'$var', ";
         }
      }
      $lsString =~ s/, $/\]\)/;
      push @pythonOutput, "$lsString $comment";
      
   } elsif ($line =~ /^(rm)/) {   #rm [- option] file1 file2 file3 ..
      addPythonImport("subprocess");
      $line =~ s/^rm //;
      $rmString = "subprocess.call(['rm', ";
      
      foreach my $option ($line =~ /[^ ]+/g) {  #getting all options
         if(isVariable($option)) {  #case for files
            $option =~ s/"//g;
            $option =~ s/^\$//;
            $rmString .= "str($option), ";
         
         } else { #else are - options
            $rmString .= "'$option', ";
         }
      }
      $rmString =~ s/, $/])/;
      push @pythonOutput, "$rmString $comment";
      
   } elsif ($line =~ /^(mv)/) {  #move command usage: mv src dest
      addPythonImport("shutil");
      my ($src, $dest) = $line =~ /^mv *([^ ]+) *([^ ]+)/;  #getting the src and dest
      $src =~ s/\$//;
      $dest =~ s/\$//;
      push @pythonOutput, "shutil.move($src, $dest)";        
      
   
   } elsif ($line =~ /^(pwd)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['pwd']) $comment";
      
   } elsif ($line =~ /^(id)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['id']) $comment";
      
   } elsif ($line =~ /^(date)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['date']) $comment";
      
   } elsif ($line =~ /^(cd)/) {
      addPythonImport("os");
      $line =~ s/^cd //;   #removing the beginning cd command
      push @pythonOutput, "os.chdir('$line') $comment";
      
   } elsif ($line =~ /^(exit)/) {
      addPythonImport("sys");
      my ($exitStatus) = $line =~ /exit (.+)/;  #getting exit status
      push @pythonOutput, "sys.exit($exitStatus) $comment"; 
     
   } elsif ($line =~ /^(read)/) {
      addPythonImport("sys");
      my ($var) = $line =~ /read ([a-zA-Z0-9_]+)/; #getting read variable
      push @pythonOutput, "$var = sys.stdin.readline().rstrip() $comment";
   }
}


# ------------------------------------------------------------------------------------
# Variable Declaration
# Translates a shell variable declaration and adds it to the end of the python array
# Param: shell line
# ------------------------------------------------------------------------------------
sub variableDeclaration ($) {
   my ($line) = @_;
   my $comment = "";

   if(hasComment($line)) { #checking for comments
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   my ($var) = $line =~ /([a-zA-Z0-9_]+)=/;  #getting variable name
   $line =~ s/^.*=//;
   my $value = $line;   #getting value the variable is being assigned to
   
   if(isMathExpr($value)) {   #is the value is a math expression
      $value =~ s/`//g;  #strip backquotes
      my $valueString = "$var = ";
      
      foreach my $exprElem ($value =~ /[^ ]+/g) {  #loop through elements
         next if $exprElem eq 'expr';
         if(isVariable($exprElem)) {
            $exprElem =~ s/^\$//;
            $valueString .= "int($exprElem) ";  #string to int conversion
         } else {
            $exprElem =~ s/'//g;
            $valueString .= "$exprElem ";
         }
      }
      
      push @pythonOutput, "$valueString$comment";
      
   } elsif(isDoubleParenthesis($value)) { #case for math expression using double parenthesis
      $value =~ s/.*\(\(//;   #stripping beginning and ending double parenthesis
      $value =~ s/ *\)\)//;
      my $valueString = "$var = ";
      
      foreach my $exprElem ($value =~ /[^ ]+/g) {
         if(isVariable($exprElem)) {
            $exprElem =~ s/"//g;
            $exprElem =~ s/^\$//;
            $valueString .= "int($exprElem) ";
         } else {
            $valueString .= "$exprElem ";
         }
      }
      
      push @pythonOutput, "$valueString$comment";
      
   } elsif(isVariable($value)) { #case for variable assignment
      addPythonImport("sys");

      if(isPreAssignedVar($value)) {
         addPythonImport("sys");
         $value =~ s/"//g;
         if(isNumVar($value)) {
            $value =~ s/^\$//;
            push @pythonOutput, "$var = sys.argv[$value] $comment";   
            
         } else {
            push @pythonOutput, "$var = $preAssignedVars{$value} $comment";
            
         }
            
      } else { #is regular variable
         $value =~ s/^\$//;
         push @pythonOutput, "$var = $value $comment";   
         
      }
   } else {
      push @pythonOutput, "$var = '$value' $comment";
      
   }
}


# ------------------------------------------------------------------------------------
# For Loop Statement
# Translates a a shell for loop statement and adds it to the end of the python array
# Param: shell line
# ------------------------------------------------------------------------------------
sub forLoop ($) {
   my ($line) = @_;
   my $hasDo = 0;
   
   #checking for comments
   my $comment = "";
   if(hasComment($line)) { 
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   if (hasDo($line)) {  #checking if do command is on the same line
      $hasDo = 1;
      $line =~ s/; *do//;
   }
   
   my ($loopVar) = $line =~ /for ([a-zA-Z0-9_]+)/;    #getting for loop variable
   my $forLoop = "for $loopVar in ";
   
   $line =~ s/^.* in //;   #removing everything before loop elements
   
   foreach my $loopElem ($line =~ /[^ ]+/g) { #[a-zA-Z0-9_\.\*\?\[\]]+/g) { #split into the iter elements
      if($loopElem =~ /(\*\.)/) {   #if all of a file type
         addPythonImport("glob");
         $forLoop .= "sorted(glob.glob(\"$loopElem\")), ";
         
      } elsif ($loopElem =~ /(\[.*\])/) { #case for [ ] metacharacters in file search
         addPythonImport("glob");
         $forLoop .= "sorted(glob.glob('$loopElem')), ";
      
      } elsif ($loopElem =~ /\?/) { #case for ? metacharacter in file search
         addPythonImport("glob");
         $forLoop .= "sorted(glob.glob('$loopElem')), ";
         
      } elsif ($loopElem =~ /\*/) { #case for * metcharacter in file search
         addPythonImport("glob");
         $forLoop .= "sorted(glob.glob('$loopElem')), ";
      
      } elsif (isVariable($loopElem)) {   #case for looping over a variable
         $loopElem =~ s/"//g;
         if(exists $preAssignedVars{$loopElem}) {  #if built in shell variable
            addPythonImport("sys");            
            
            if(isNumVar($loopElem)) {
               $loopElem =~ s/^\$//;
               $forLoop .= "sys.argv[$loopElem], "; 
            } else {
               $forLoop .= "$preAssignedVars{$loopElem}, ";
            }
            
         } else {    #regular defined variable
            $loopElem =~ s/^\$//;
            $forLoop .= "$loopElem, ";
         }
      
      } else {
         $forLoop .= "'$loopElem', ";   
      }
   }   
      
   $forLoop =~ s/, $/:/;   #python editing
   
   push @pythonOutput, "$forLoop $comment";
   
   if($hasDo) {   #if do keyword was on same line add to array
      push @pythonOutput, "do";
   }
}


# ------------------------------------------------------------------------------------
# if Statement
# Translates a shell if statement and adds it to the end of the python array
# Param: shell line
# ------------------------------------------------------------------------------------
sub ifStatement ($) {
   my ($line) = @_;
   my $ifString;
   
   #flags for file/directory checks
   my $readable = 0;    
   my $directory = 0;   
   my $executable = 0;
   my $writeable = 0;
   my $fileExists = 0;
   my $grep = 0;
   my $numComp = 0;
   my $hasThen = 0;
   
   #checking for comments
   my $comment = "";
   if(hasComment($line)) { 
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   if (isIfStatement($line)) {
      $line =~ s/^if *//;  #remove beginning if
      $ifString = "if ";
      
   } elsif (isElifStatement($line)) {
      $line =~ s/^elif *//;
      $ifString = "elif ";
   
   }
   
   if(isIntComparison($line)) {  #if if statement is comparing numbers
      $numComp = 1;
   }
   
   if(hasThen($line)) { #if then keyword is on the same line
      $line =~ s/; *then//;
      $hasThen = 1;
   }
   
   foreach my $ifElem ($line =~ /[^ ]+/g) {  #loop through elements
      if(isEqualOperator($ifElem)) {
         $ifString .= "== ";
         
      } elsif (isReadable($ifElem)) {  #if is readable test option
         addPythonImport("os");
         $readable = 1;
         
      } elsif ($readable) {
         $ifElem =~ s/^\$//;  
         $ifString .= "os.access('$ifElem',os.R_OK) ";  
         $readable = 0;
         
      } elsif (isDirectory($ifElem)) { #if is directory test option
         addPythonImport("os.path");
         $directory = 1;
         
       } elsif($directory) {
         $ifString .= "os.path.isdir('$ifElem') ";
         $directory = 0;
         
      } elsif (isExecutable($ifElem)) {   #if is executable test option
         addPythonImport("os");
         $executable = 1;
            
      } elsif ($executable) {
         $ifElem =~ s/^\$//;  
         $ifString .= "os.access('$ifElem',os.X_OK) ";  
         $executable = 0;
         
      } elsif (isWriteable($ifElem)) { #if is writable test option
         addPythonImport("os");
         $writeable = 1;
         
      } elsif ($writeable) {
         $ifElem =~ s/^\$//;  
         $ifString .= "os.access('$ifElem',os.W_OK) ";  
         $writeable = 0;
         
      } elsif (fileExists($ifElem)) {  #if file exists test option
         addPythonImport("os");
         $fileExists = 1;
      
      } elsif ($fileExists) {
         $ifElem =~ s/^\$//;  
         $ifString .= "os.access($ifElem,os.F_OK) ";  #NOTE: Is sensitive to no quotation
         $fileExists = 0;
         
      } elsif (isGrep($ifElem)) {      #if using grep
         addPythonImport("subprocess");
         $grep = 1;
         $ifString .= "not subprocess.call(['$ifElem', ";
      
      } elsif($grep) {
         if(isVariable($ifElem)) {
            $ifElem =~ s/^\$//;
            $ifString .= "str($ifElem), ";
         } else {
            $ifString .= "'$ifElem', ";         
         }
      
      } elsif(isVariable($ifElem)) {   #case for variable use in if statement
         $ifElem =~ s/"//g;
         if(exists $preAssignedVars{$ifElem}) {
            if(isNumVar($ifElem)) {
               if($numComp) {
                  $ifElem =~ s/^\$//;
                  $ifString .= "int(sys.argv[$ifElem]) ";
               } else {
                  $ifElem =~  s/^\$//;
                  $ifString .= "sys.argv[$ifElem]) ";
               }
            } else {
               $ifString .= "$preAssignedVars{$ifElem} ";
            }
         } else {
            if($numComp) { #if expression is integer comparison cast
               $ifElem =~ s/^\$//;
               $ifString .= "int($ifElem) ";
               
            } else {    #regular variable
               $ifElem =~ s/^\$//;
               $ifString .= "$ifElem ";   
            }
         }
         
      } elsif(exists $numComparison{$ifElem}) {    #conversion of number comparison operators
         $ifString .= "$numComparison{$ifElem} ";
         
      } elsif(exists $boolOps{$ifElem}) {    #conversion of boolean operators 
         $ifString .= "$boolOps{$ifElem} ";
      
      } elsif(!isTestOperator($ifElem)) { #constant
         if($numComp) {
            $ifString .= "$ifElem ";
         } else {
            $ifString .= "'$ifElem' ";
         }
         
      }
   }
   
   #editing for python
   if($grep) {
      $ifString =~ s/, $/\]\):/;
   } else {
      $ifString =~ s/ $/:/;
   }
   push @pythonOutput, "$ifString $comment";
   
   if($hasThen) { #if then keyword was on the same line add to array
      push @pythonOutput, "then";
   }
}


# ------------------------------------------------------------------------------------
# While Loop
# Translates a shell while loop and adds it to the end of the python array
# Param: shell line
# ------------------------------------------------------------------------------------
sub whileLoop($) {
   my ($line) = @_;
   my $hasDo = 0;
   
   #checking for comments
   my $comment = "";
   if(hasComment($line)) { 
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   if (hasDo($line)) {  #if while line has the do keyword 
      $hasDo = 1;
      $line =~ s/; *do//;
   }
   
   $line =~ s/^while //;   #strip beginning while
   my $whileString = "while ";   #creating python conversion
   
   if(isIntComparison($line)) {  #if integer comparison is being used in the while loop
      
      foreach my $whileElem ($line =~ /[^ ]+/g) {
         next if isTestOperator($whileElem); #next if keyword test or [ ]
         if(isVariable($whileElem)) {  #if element is a variable
            $whileElem =~ s/"//g;
            if(exists $preAssignedVars{$whileElem}) {
               addPythonImport("sys");
               if (isNumVar($whileElem)) {            
                  $whileElem =~ s/^\$//;
                  $whileString .= "int(sys.argv[$whileElem]) "; #casting variables to ints
                  
               } else {
                  $whileString .= "int($preAssignedVars{$whileElem}) ";
                 
               }
            } else { #regular variable
               $whileElem =~ s/^\$//;
               $whileString .= "int($whileElem) ";
            }
         
         } elsif (isIntComparison($whileElem)) {   #integer comparison conversion
            $whileString .= "$numComparison{$whileElem} ";
         
         } elsif(exists $boolOps{$whileElem}) { #boolean operator conversion
            $whileString .= "$boolOps{$whileElem} ";
         
         } else {          #is a number
            $whileString .= "$whileElem ";
         }
      }
      
      $whileString =~ s/ *$/:/;  #editing for python conversion
      push @pythonOutput, "$whileString $comment";
   
   } elsif($line =~ /(true) *$/) {  #while true loop
      $whileString .= "True:";
      push @pythonOutput, "$whileString $comment";
   
   } else { #elsif isStringComparison
      
      foreach my $whileElem ($line =~ /[^ ]+/g) {
         next if isTestOperator($whileElem); #skip if a test operator i.e. test [ ]
         if(isEqualOperator($whileElem)) {   #equals conversion for strings
            $whileString .= "== ";
         
         } elsif (isVariable($whileElem)) {  #cases for variables in the while loop
            $whileElem =~ s/"//g;
            if(exists $preAssignedVars{$whileElem}) {
               if (isNumVar($whileElem)) {            
                  $whileElem =~ s/^\$//;
                  $whileString .= "sys.argv[$whileElem] ";
                  
               } else {
                  $whileString .= "$preAssignedVars{$whileElem} ";
                 
               }
            } else { #regular variable
               $whileElem =~ s/^\$//;
               $whileString .= "$whileElem ";
            }
         
         } elsif(exists $boolOps{$whileElem}) {
            $whileString .= "$boolOps{$whileElem} ";
         
         } else { #const
            $whileString .= "'$whileElem' ";
         }
         
      }
      $whileString =~ s/ *$/:/;  #python conversion editing
      push @pythonOutput, "$whileString $comment";
   }
   
   if($hasDo) {   #if do keyword was on the same line add to array
      push @pythonOutput, "do";
   }
}


# ------------------------------------------------------------------------------------
# Add Python Imports
# Adds required python imports to hash
# Param: Python Libaray to import
# Return: void
# ------------------------------------------------------------------------------------
sub addPythonImport($) {
   my ($import) = @_;
   if(!exists $pythonImports{$import}) {
      $pythonImports{$import}++;
   }
}


# ------------------------------------------------------------------------------------
# Print Indentations
# Prints the number of indentations for a line
# Param: Number of indents to print
# Return: void
# ------------------------------------------------------------------------------------
sub printIndentation ($) {
   my ($indentCount) = @_;
   my $indentLength = 4;
   my $numIndents = $indentCount * $indentLength;
   
   foreach my $i (0..$numIndents-1) {  #Adding indentation
      print " ";
   }
}


# ------------------------------------------------------------------------------------
# Out File
# Translates an outfile operation and adds it to the end of the python array
# Param: shell line
# Return: void
# ------------------------------------------------------------------------------------
sub outFile ($) {
   my ($line) = @_;
   my $outString;
   
   #checking for comments
   my $comment = "";
   if(hasComment($line)) { 
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }

   $line =~ s/^echo //;
   
   my ($outfile) = $line =~ />+(.+)/;  #getting the file we want to output to
   $outfile =~ s/\$//;
   
  
   if(isAppend($line)) {   #if appending to file
      $line =~ s/>>.*$//;
      $line =~ s/\$//g;
      $outString = "with open($outfile, 'a') as f: print >>f, $line";    
   } elsif (isWriteFile($line)) {   #if writing to a file
      $line =~ s/>.*$//;
      $line =~ s/\$//g;
      $outString = "with open($outfile, 'w') as f: print >>f, $line";    
   }
   push @pythonOutput, "$outString $comment";   

}







