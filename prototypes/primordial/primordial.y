/*
 * Grammar of the Primordial language.
 *
 * We use Bison and Flex to prototype and validate the adequacy of the grammar
 * against a test suite. These tests will also be reused in the future to
 * validate the compiler.
 */

%{

#include <stdio.h>
#include "scanner.h"

int yylex(void);
void yyerror(const char* s);

%}

%define lr.type lalr

%define parse.trace
%define parse.error verbose
%locations

%start File

%token PACKAGE "package"
%token UPPER_ID "upper identifier"
%token LOWER_ID "lower identifier"
%token SEMI ";"

%%

File
    : PackageDecl
    ;

PackageDecl
    : "package" UPPER_ID ";"
    ;

%%

int main(int argc, char **argv) {
   if (yyparse()) {
   	puts("\nFAIL\n");
   } else {
   	puts("\nPASS\n");
   }

   return 0;
}

void yyerror(const char *msg) {
   printf(
   	"** Line %d, column %d: %s\n",
   	yylloc.first_line,
   	yylloc.first_column,
   	msg
   );
}
