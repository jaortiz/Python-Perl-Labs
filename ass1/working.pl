#!/usr/bin/perl -w

# --------------------------------------------------------------
# FUNCTION PROTOTYPES
# --------------------------------------------------------------

sub echo ($);
sub command ($);
sub variableDeclaration ($);

sub forLoop ($);
sub ifStatement($);
sub whileLoop ($);

sub printImports();
sub printPythonOutput();
sub addPythonImport($);

sub outFile($);

#Regex Helper Functions
sub isComment ($);
sub hasComment ($); 

sub isVariable ($);
sub isVarDeclaration ($);

#pre-assigned variables
sub isPreAssignedVar ($);
sub isAllSepCommandArgs ($);

#sub isAllCommandArgsT ($);

#for/while tests
sub isForLoop ($);
sub isDoStatement ($);
sub isDoneStatement ($);
sub isWhileLoop ($);

#if tests
sub isIfStatement ($);
sub isThenStatement ($);
sub isElseStatement ($);
sub isElifStatement ($);
sub isFiStatement ($);

#comparison operators 
sub isEqualOperator ($);
sub isReadOnly ($);
sub isDirectory ($);
sub isGrep ($);
sub isTestOperator ($);

sub isMathExpr ($);  #using `expr `

sub isDoubleParenthesis ($);

sub isEmptyLine ($);
sub hasSingleQuotes ($);
sub hasDoubleQuotes ($);

sub isIntComparison ($);   #regular math -eq, -gt etc

sub printIndentation ($);

sub isToOutFile ($);
sub isAppend ($);
#delete this later is being replaced with hash
sub convertOperator ($);
# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

require 'regexFunctions.pl' or die "Could not include regex functions";
#declaring output arrays and hashes
@pythonOutput = ();    #holds the lines of python translation
my %pythonImports;   #holds the python imports
my %variables;    #hold the variables of the script

#shell/unix command hash USING RANDOM VAR
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
);

#FILL IN
%preAssignedVars = (
   "\$#" => "len(sys.argv[1:])",
);

#FILL IN
%numComparison = (
   "-gt" => ">",
   "-eq" => "==",
   "-lt" => "<",
);

# FILL IN
%boolOps = (
   "-o" => "or",
);

while (my $line = <>) {
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

# Function to print python imports
sub printImports() {
   if(keys %pythonImports) {  #check if there are imports to print
      foreach my $key (keys %pythonImports) {
         print "import $key\n";
      }
   }
}

#Function to format and print python output conversion
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
         
      } else {
         printIndentation($indentCount);
         print "$pythonOutput[$i]\n";
      }
   } 
}

#Function to handle unix/shell commands
sub command ($) {
   my ($line) = @_ ;
   
   if($line =~ /(echo)/) {
      if(isToOutFile($line)) {
         outFile($line);
      } else {
         my $string = "print ";  #creating string
         $line =~ s/^echo //; #remove beginning echo
         my @prints;

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
               $string .= $prints[$i];
            
            } elsif ($prints[$i] =~ /\$/) {  #Checking for printing variables
               if($prints[$i] =~ /(\$[0-9]+)/) {   #check if a command line argument
                  addPythonImport("sys");
                  my ($numVar) = $prints[$i] =~ /^\$([0-9]+)/; #getting number
                  $string .= "sys.argv[$numVar]";
                  
               } else { #for regular variables
                  $prints[$i] =~ s/\$//;
                  $string .= "$prints[$i]";
               }
            } else {
               $string .= "'$prints[$i]'";   #concatenating
            }
            
            if ($i != $#prints) {      #making sure last variable doesnt have ',' following
               $string .= ", "
            }
            
         }
         push @pythonOutput, $string;  #adding string to output array
      }  
   } elsif ($line =~ /(ls)/) {
      addPythonImport("subprocess");   
      $line =~ s/^ls //; #remove beginning ls
      my @options;    

      foreach my $option ($line =~ /[^ ]+/g) {  #getting ls options
         push @options, $option;      
      }
      
      #cases for number of ls options
      if (scalar @options == 0) {
         push @pythonOutput, "subprocess.call(['ls'])";
         
      } elsif (scalar @options == 1) {
         push @pythonOutput, "subprocess.call(['ls','$options[0]]'])";
         
      } elsif (scalar @options == 2) {
      
         if(isVariable($options[1])) {
            
            if(isAllSepCommandArgs($options[1])) {      #MAKE MORE GENERIC       
               push @pythonOutput, "subprocess.call(['ls','$options[0]'] + sys.argv[1:])";
            }
            
         } else {
            push @pythonOutput, "subprocess.call(['ls','$options[0]','$options[1]'])";
         }
      } 
      
   } elsif ($line =~ /(rm)/) {   #rm [- option] file1 file2 file3 ..
      addPythonImport("subprocess");
      $line =~ s/^rm //;
      my @options;
      $rmString = "subprocess.call(['rm', ";
      
      foreach my $option ($line =~ /[^ ]+/g) {  #getting all options
         if(isVariable($option)) {  #case for files
            $option =~ s/^\$//;
            $rmString .= "str($option), ";
         
         } else { #else are - options
            $rmString .= "'$option', ";
         }
      }
      $rmString =~ s/, $/])/;
      push @pythonOutput, $rmString;
      
   } elsif ($line =~ /(pwd)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['pwd'])";
      
   } elsif ($line =~ /(id)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['id'])";
      
   } elsif ($line =~ /(date)/) {
      addPythonImport("subprocess");
      push @pythonOutput, "subprocess.call(['date'])";
      
   } elsif ($line =~ /(cd)/) {
      addPythonImport("os");
      $line =~ s/^cd //;   #removing the beginning cd command
      push @pythonOutput, "os.chdir('$line')";
      
   } elsif ($line =~ /(exit)/) {
      addPythonImport("sys");
      my ($exitStatus) = $line =~ /exit (.+)/;  #getting exit status
      push @pythonOutput, "sys.exit($exitStatus)"; 
     
   } elsif ($line =~ /(read)/) {
      addPythonImport("sys");
      my ($var) = $line =~ /read ([a-zA-Z0-9_]+)/; #getting read variable
      push @pythonOutput, "$var = sys.stdin.readline().rstrip()";
   }
}


#Function to handle variable declaration
sub variableDeclaration ($) {
   my ($line) = @_;
   my $comment = "";

   if(hasComment($line)) { #checking for comments
      ($comment) = $line =~ /(#.*)$/;
      $line =~ s/#.*$//;
   }
   
   my ($var) = $line =~ /([a-zA-Z0-9_]+)=/;
   $line =~ s/^.*=//;
   my $value = $line;
   
   if(isMathExpr($value)) {
      $value =~ s/`//g;  #strip backquotes
      my $valueString = "$var = ";
      
      foreach my $exprElem ($value =~ /[^ ]+/g) {
         next if $exprElem eq 'expr';
         if(isVariable($exprElem)) {
            $exprElem =~ s/^\$//;
            $valueString .= "int($exprElem) ";
         } else {
            $exprElem =~ s/'//g;
            $valueString .= "$exprElem ";
         }
      }
      
      push @pythonOutput, "$valueString$comment";
      
   } elsif(isDoubleParenthesis($value)) {
      $value =~ s/.*\(\(//;   #stripping beginning and ending double parenthesis
      $value =~ s/ *\)\)//;
      my $valueString = "$var = ";
      
      foreach my $exprElem ($value =~ /[^ ]+/g) {
         if(isVariable($exprElem)) {
            $exprElem =~ s/^\$//;
            $valueString .= "int($exprElem) ";
         } else {
            $valueString .= "$exprElem ";
         }
      }
      
      push @pythonOutput, "$valueString$comment";
      
   } elsif(isVariable($value)) {
      addPythonImport("sys");
      $value =~ s/^\$//;

      if(isPreAssignedVar($value)) {
         push @pythonOutput, "$var = sys.argv[$value] $comment";
      } else {
         push @pythonOutput, "$var = $value $comment";   
      }
   } else {
      push @pythonOutput, "$var = '$value' $comment";
   }
}


#Function to handle for loops
sub forLoop ($) {
   my ($line) = @_;
   my ($loopVar) = $line =~ /for ([a-zA-Z0-9_]+)/;    #getting for loop variable
   my $forLoop = "for $loopVar in ";
   
   $line =~ s/^.* in //;   #removing everything before loop elements
   
   foreach my $loopElem ($line =~ /[a-zA-Z0-9_\.\*]+/g) { #split into the iteration elements
      if($loopElem =~ /(\*\.)/) {   #if all of a file type
         addPythonImport("glob");
         $forLoop .= "sorted(glob.glob(\"$loopElem\")), ";
             
      } else {
         $forLoop .= "'$loopElem', ";   
      }
   }   
      
   $forLoop =~ s/, $/:/;
   
   push @pythonOutput, $forLoop;
}


#Function to handle if statements
sub ifStatement ($) {
   my ($line) = @_;
   my $ifString;
   my $readOnly = 0;    #Flag for checking if operator is read only
   my $directory = 0;   #Flag for checking if operator is a directory
   my $grep = 0;
   my $numComp = 0;
   
   if (isIfStatement($line)) {
      $line =~ s/^if *//;  #remove beginning if
      $ifString = "if ";
      
   } elsif (isElifStatement($line)) {
      $line =~ s/^elif *//;
      $ifString = "elif ";
   
   }
   
   if(isIntComparison($line)) {
      $numComp = 1;
   }
   
   foreach my $ifElem ($line =~ /[^ ]+/g) {
      if(isEqualOperator($ifElem)) {
         $ifString .= "== ";
         
      } elsif (isReadOnly($ifElem)) {
         addPythonImport("os");
         $readOnly = 1;
      } elsif (isDirectory($ifElem)) {
         addPythonImport("os.path");
         $directory = 1;
      
      } elsif (isGrep($ifElem)) {
         addPythonImport("subprocess");
         $grep = 1;
         $ifString .= "not subprocess.call(['$ifElem', ";
      
      } elsif ($readOnly) {
         $ifElem =~ s/^\$//;
         $ifString .= "os.access('$ifElem',os.R_OK):";   #CHECK
         $readOnly = 0;
         
      } elsif($directory) {
         $ifString .= "os.path.isdir('$ifElem'):";
         $directory = 0;
         
      } elsif($grep) {
         if(isVariable($ifElem)) {
            $ifElem =~ s/^\$//;
            $ifString .= "str($ifElem), ";
         } else {
            $ifString .= "'$ifElem', ";         
         }
      
      } elsif(isVariable($ifElem)) {
         if(exists $preAssignedVars{$ifElem}) {
            $ifString .= "$preAssignedVars{$ifElem} ";
         } else {
            if($numComp) {
               $ifElem =~ s/^\$//;
               $ifString .= "int($ifElem) ";
               
            } else { #string comparison NEED TO HANDLE AS WELL
               $ifString .= "$ifElem ";   #TEMP
            }
         }
         
      } elsif(exists $numComparison{$ifElem}) {
         $ifString .= "$numComparison{$ifElem} ";
         
      } elsif(exists $boolOps{$ifElem}) {
         $ifString .= "$boolOps{$ifElem} ";
      
      } elsif(!isTestOperator($ifElem)) { #is a regular var
         if($numComp) {
            $ifString .= "$ifElem ";
         } else {
            $ifString .= "'$ifElem' ";
         }
         
      }
   }
   
   if($grep) {
      $ifString =~ s/, $/\]\):/;
   } else {
      $ifString =~ s/ $/:/;
   }
   push @pythonOutput, $ifString;
}


# Function to handle while loops
sub whileLoop($) {
   my ($line) = @_;
   $line =~ s/^while //;   #strip beginning while
   my $whileString = "while ";
   
   if(isIntComparison($line)) {
      
      foreach my $whileElem ($line =~ /[^ ]+/g) {
         next if isTestOperator($whileElem);
         if(isVariable($whileElem)) {
            $whileElem =~ s/^\$//;
            $whileString .= "int($whileElem) "; 
         
         } elsif (isIntComparison($whileElem)) {
            my $operator = convertOperator($whileElem);  #CHANGE THIS
            $whileString .= "$operator ";
         
         } else {          #is a number
            $whileString .= "$whileElem ";
         }
      }
      
      $whileString =~ s/ *$/:/;
      push @pythonOutput, $whileString;
   
   } elsif($line =~ /(true)/) {
      $whileString .= "True:";
      push @pythonOutput, $whileString;
   
   } else { #elsif isStringComparison
   
   }
}


#Helper function to add python imports to hash
sub addPythonImport($) {
   my ($import) = @_;
   if(!exists $pythonImports{$import}) {
      $pythonImports{$import}++;
   }
}


# Helper Function to print python indentation
sub printIndentation ($) {
   my ($indentCount) = @_;
   my $indentLength = 4;
   my $numIndents = $indentCount * $indentLength;
   
   foreach my $i (0..$numIndents-1) {  #Adding indentation
      print " ";
   }
}


#Function to handle outfile operations
sub outFile ($) {
   my ($line) = @_;
   my $outString;
   #print "outfile: $line\n";
   $line =~ s/^echo //;
   
   my ($outfile) = $line =~ />+(.+)/;
   $outfile =~ s/\$//;
   
  
   if(isAppend($line)) { #maybe temp use HASH ?
      $line =~ s/>>.*$//;
      $line =~ s/\$//g;
      $outString = "with open($outfile, 'a') as f: print >>f, $line";    
   } 
   push @pythonOutput, $outString;   

}

# -----------------------------------------------------------------------------------------
# Regex Helper Functions
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# Check Regex Functions
# Returns boolean
# -----------------------------------------------------------------------------------------

#Checks if line is variable declaration
sub isComment($) {
   my ($line) = @_;
   return $line =~ /^#.*/;
}

sub isVariable($) {
   my ($line) = @_;
   return $line =~ /(\$.+)/;
}

sub isVarDeclaration($) {
   my ($line) = @_;
   return $line =~ /^[a-zA-Z0-9_]+=[a-zA-Z0-9_\.\/\$`]+/;
}


sub isForLoop($) {
   my ($line) = @_;
   return $line =~ /^\bfor\b/;
}


sub isWhileLoop($) {
   my ($line) = @_;
   return $line =~ /^\bwhile\b/;
}


sub isDoStatement($) {
   my ($line) = @_;
   return $line =~ /^\bdo\b/;
}


sub isDoneStatement ($) {
   my ($line) = @_;
   return $line =~ /^\bdone\b/;
}


sub isIfStatement ($) {
   my ($line) = @_;
   return $line =~ /^\bif\b/;
}


sub isThenStatement ($) {
   my ($line) = @_;
   return $line =~ /^\bthen\b/;
}


sub isElseStatement ($) {
   my ($line) = @_;
   return $line =~ /^\belse\b/;
}


sub isElifStatement ($) {
   my ($line) = @_;
   return $line =~ /^\belif\b/;
}


sub isFiStatement ($) {
   my ($line) = @_;
   return $line =~ /^\bfi\b/;
}


sub isEmptyLine ($) {
   my ($line) = @_;
   return $line eq "";
}


sub hasSingleQuotes($) {
   my ($line) = @_;
   return $line =~ /'[^']+'/;

}


sub hasDoubleQuotes($) {
   my ($line) = @_;
   return $line =~ /"[^"]+"/;

}


sub hasComment($) {
   my ($line) =@_;
   return $line =~ /#.+$/;
}

sub isIntComparison($) {
   my ($line) = @_;
   return $line =~ /(lt|le|ne|eq)/; #/-[(lt)(ne)(eq)]/;
}


sub isTestOperator($) {
   my ($line) = @_;
   return $line =~ /^[(test)\[\]]/;
}


sub isMathExpr($) {
   my ($line) = @_;
   return $line =~ /`expr.*`/;
}

sub isDoubleParenthesis ($) {
   my ($Line) = @_;
   return $Line =~ /\(\(.*\)\)/;

}

# Comparison/operators checks
sub isEqualOperator ($) {
   my ($operator) = @_;
   return $operator eq '=';
}


sub isReadOnly ($) {
   my ($operator) = @_;
   return $operator eq '-r';
}


sub isDirectory ($) {
   my ($operator) = @_;
   return $operator eq '-d';
}


sub isGrep ($) {
   my ($operator) = @_;
   return $operator =~ /(grep)/;
   
}


sub isToOutFile ($) {
   my ($line) = @_;
   return $line =~ /echo.*>+.*/;
}


sub isAppend ($) {
   my ($line) = @_;
   return $line =~ />{2}/;
}

# Pre-assigned variable checks

sub isPreAssignedVar ($) {
   my ($var) = @_;
   return $var =~ /([0-9#\*@\?\$]+)/;
}

sub isAllSepCommandArgs ($) {
   my ($var) = @_;
   return $var =~ /(\$@)/;
}


sub convertOperator ($) {
   my ($line) = @_;
   my $operator = "";
   
   if ($line eq '-le') {
      $operator = '<=';
   }
   return $operator;
}


#before cleaning





