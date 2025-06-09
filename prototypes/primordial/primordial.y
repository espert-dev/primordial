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
%define parse.error detailed
%locations

%start File

/* Separators */
%token LPAR "("
%token RPAR ")"
%token SEMI ";"

/* Keywords */
%token IMPORT "import"
%token PACKAGE "package"

/* Identifiers */
%token <text> UPPER_ID "upper identifier"
%token <text> LOWER_ID "lower identifier"

/* Literals */
%token <text> STR_LITERAL "string literal"

%union {
	const char *text;
}

%%

File
    : PackageDecl Imports
    ;

PackageDecl
    : "package" UPPER_ID ";"  { printf("Package(%s)\n", $2); }
    ;

Imports
    : %empty
    | Imports Import ";"
    ;

Import
    : "import" ImportItem
    | "import" "(" GroupedImportItems ")"
    ;

ImportItem
    : STR_LITERAL  { printf("Import(%s)\n", $1); }
    | UPPER_ID STR_LITERAL  { printf("Import(%s as %s)\n", $2, $1); }
    ;

GroupedImportItems
    : %empty
    | GroupedImportItems ImportItem ";"
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
