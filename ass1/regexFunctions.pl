#!/usr/bin/perl -w

# ---------------------------------------------------------------------------
# FUNCTION PROTOTYPES
# ---------------------------------------------------------------------------

# for/while tests
sub isForLoop ($);
sub isDoStatement ($);
sub isDoneStatement ($);
sub isWhileLoop ($);
sub hasDo ($);

# if statement tests
sub isIfStatement ($);
sub isThenStatement ($);
sub isElseStatement ($);
sub isElifStatement ($);
sub isFiStatement ($);
sub hasThen ($);

# Command Options
sub isReadable ($);
sub isDirectory ($);
sub isExecutable ($);
sub isWriteable ($);
sub fileExists ($);
sub noNewline ($);

# Comment helper functions
sub isComment ($);
sub hasComment ($); 

# Variable tests
sub isVariable ($);
sub isVarDeclaration ($);

# Pre-assigned variables
sub isPreAssignedVar ($);

# Math
sub isMathExpr ($);  #using `expr `
sub isIntComparison ($);   #regular math -eq, -gt etc
sub isDoubleParenthesis ($);

# Files
sub isToOutFile ($);
sub isAppend ($);
sub isWriteFile ($);

# other
sub isEmptyLine ($);
sub hasSingleQuotes ($);
sub hasDoubleQuotes ($);
sub isEqualOperator ($);   
sub isGrep ($);
sub isTestOperator ($);

# ---------------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# FOR/WHILE TESTS
# ---------------------------------------------------------------------------
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

sub hasDo($) {
   my ($line) = @_;
   return $line =~ /(; *do)/;
}


# ---------------------------------------------------------------------------
# IF STATEMENT TESTS
# ---------------------------------------------------------------------------
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

sub hasThen ($) {
   my ($line) = @_;
   return $line =~ /(; *then)/;
}

# ---------------------------------------------------------------------------
# MATH TESTS
# ---------------------------------------------------------------------------
sub isMathExpr($) {
   my ($line) = @_;
   return $line =~ /`expr.*`/;
}

sub isDoubleParenthesis ($) {
   my ($Line) = @_;
   return $Line =~ /\(\(.*\)\)/;

}

sub isIntComparison($) {
   my ($line) = @_;
   return $line =~ /-(lt|le|ne|eq|gt|ge)/; 
}


# ---------------------------------------------------------------------------
# COMMAND OPTIONS TEST
# ---------------------------------------------------------------------------
sub isEqualOperator ($) { 
   my ($operator) = @_;
   return $operator eq '=';
}


sub isReadable ($) {
   my ($operator) = @_;
   return $operator eq '-r';
}


sub isDirectory ($) {
   my ($operator) = @_;
   return $operator eq '-d';

}
sub isExecutable ($) {
   my ($operator) = @_;
   return $operator eq '-x';
}
sub isWriteable ($) {
   my ($operator) = @_;
   return $operator eq '-w';
}

sub fileExists ($) {
   my ($operator) = @_;
   return $operator eq '-f';
}

sub noNewline ($) {
   my ($line) = @_;
   return $line =~ /(-n)/;
}
   
# ---------------------------------------------------------------------------
# COMMENT TESTS
# ---------------------------------------------------------------------------
sub isComment($) {
   my ($line) = @_;
   return $line =~ /^#.*/;
}

sub hasComment($) {
   my ($line) =@_;
   return $line =~ /([^\$]#.+$)/;
}


# ---------------------------------------------------------------------------
# VARIABLE TESTS
# ---------------------------------------------------------------------------
sub isVariable($) {
   my ($line) = @_;
   return $line =~ /(\$.+)/;
}

sub isVarDeclaration($) {
   my ($line) = @_;
   return $line =~ /^[a-zA-Z0-9_]+=[^ ]+/#[a-zA-Z0-9_\.\/\$`]+/;
}

sub isPreAssignedVar ($) {
   my ($var) = @_;
   return $var =~ /^\$([0-9]+|#|\*|@|\?|\$)/;
}

sub isNumVar ($) {
   my ($var) = @_;
   return $var =~ /^\$[0-9]+/;
}


# ---------------------------------------------------------------------------
# OUTFILE TESTS
# ---------------------------------------------------------------------------
sub isToOutFile ($) {
   my ($line) = @_;
   return $line =~ /echo.*>+.*/;
}


sub isAppend ($) {
   my ($line) = @_;
   return $line =~ />{2}/;
}

sub isWriteFile ($) {
   my ($line) = @_;
   return $line =~ />{1}/;
}
# ---------------------------------------------------------------------------
# OTHER
# ---------------------------------------------------------------------------
sub isTestOperator($) {
   my ($line) = @_;
   return $line =~ /^(test|\[|\])/; 
}

sub hasSingleQuotes($) {
   my ($line) = @_;
   return $line =~ /'[^']+'/;

}

sub hasDoubleQuotes($) {
   my ($line) = @_;
   return $line =~ /"[^"]+"/;

}

sub isGrep ($) {
   my ($operator) = @_;
   return $operator =~ /(grep)/;
   
}

sub isPrint ($) {
   my ($line) = @_;
   return $line =~ /^print/;
}

1; #for require









