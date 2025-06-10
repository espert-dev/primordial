/*
 * Grammar for the Primordial language.
 *
 * Design decisions:
 *
 * - Supports declarations, which allows the implementation of single-pass
 *   variants (e.g., for p0).
 *
 * - Value and type identifiers have been segregated at the lexical level,
 *   following a common convention among many programming languages by which
 *   types are denoted by uppercase letters. This, in turn, allows us to have
 *   a more precise grammar, that for example removes the C typedef ambiguity.
 *
 * - Expressions and statements are strictly separated to minimise unintended
 *   side-effects.
 *
 * - All lists separated by commas are left-associative to minimise stack
 *   usage in bottom-up parsers.
 *
 * - All binary operators are left-associative.
 *
 * - All value expression operators are prefix.
 *
 * - All type modifiers are postfix.
 *
 */

%{
#include <stdbool.h>
#include "parser.h"

#define YY_USER_ACTION {\
	yylloc.first_line = yylloc.last_line;\
	yylloc.first_column = yylloc.last_column;\
	for (int i = 0; yytext[i] != '\0'; i++) {\
		if (yytext[i] == '\n') {\
			yylloc.last_line++;\
			yylloc.last_column = 1;\
		} else {\
			yylloc.last_column++;\
		}\
	}\
}

/* Return, indicating that an implicit semicolon can follow this token */
#define final(x) {\
	can_insert_semicolon = true;\
	return x;\
}

/* Return, indicating that an implicit semicolon cannot follow this token */
#define non_final(x) {\
	can_insert_semicolon = false;\
	return x;\
}

/* Track the last token for the implicit semicolon rule */
static bool can_insert_semicolon = false;
%}

%option noyywrap
%option yylineno

%%

"#"[^\n]*               {/* ignore comments */}

"("                     { non_final(LPAR); }
"["                     { non_final(LBRA); }
"{"                     { non_final(LCUR); }
")"                     { final(RPAR); }
"]"                     { final(RBRA); }
"}"                     { final(RCUR); }
"@"                     { final(AT); }
","                     { final(COMMA); }
";"                     { non_final(SEMI); }
"."                     {
	/*
	 * This one has to be final because of the possibility of a pointer
	 * dereference happening at the end of an expression.
	 */
	final(PERIOD);
}

"="                     { non_final(ASSIGN); }
":="                    { non_final(DEFINE); }
"->"                    { non_final(TO); }
":"                     { non_final(COLON); }
"||"                    { non_final(LOGIC_OR); }
"&&"                    { non_final(LOGIC_AND); }
"=="                    { non_final(CMP_EQ); }
"!="                    { non_final(CMP_NE); }
"<="                    { non_final(CMP_LE); }
">="                    { non_final(CMP_GE); }
"<"                     { non_final(CMP_LT); }
">"                     { non_final(CMP_GT); }
"+"                     { non_final(ADD); }
"-"                     { non_final(SUB); }
"|"                     { non_final(BITWISE_OR); }
"^"                     { non_final(BITWISE_XOR); }
"*"                     { non_final(MUL); }
"/"                     { non_final(DIV); }
"%"                     { non_final(REM); }
"&"                     { non_final(BITWISE_AND); }
"&^"                    { non_final(BITWISE_AND_NOT); }
"<<"                    { non_final(LSHIFT); }
">>"                    { non_final(RSHIFT); }
"!"                     { non_final(LOGICAL_NOT); }
"~"                     { non_final(BITWISE_NOT); }

[!%&*+-/:<=>\\^|~]+     {
	/*
	 * Catch anything else that looks like an operator and report it as an
	 * error. This allows us to add additional operators without generating
	 * incompatibilities with existing code.
	 */
	printf(
		"** Line %d, column %d: unrecognized operator \u2018%s\u2019\n",
		yylloc.first_line,
		yylloc.first_column,
        	yytext
        );
        exit(0);
}

"import"                { non_final(IMPORT); }
"package"               { non_final(PACKAGE); }
"let"                   { non_final(LET); }
"var"                   { non_final(VAR); }
"if"                    { non_final(IF); }
"else"                  { non_final(ELSE); }
"while"                 { non_final(WHILE); }
"for"                   { non_final(FOR); }
"type"                  { non_final(TYPE); }
"func"                  { non_final(FUNC); }
"struct"                { non_final(STRUCT); }
"union"                 { non_final(UNION); }
"interface"             { non_final(INTERFACE); }
"continue"              { final(CONTINUE); }
"break"                 { final(BREAK); }
"goto"                  { final(GOTO); }
"true"                  { final(TRUE); }
"false"                 { final(FALSE); }

[A-Z][0-9A-Za-z_]*      { yylval.text = strdup(yytext); final(UPPER_ID); }
[a-z_][0-9A-Za-z_]*     { yylval.text = strdup(yytext); final(LOWER_ID); }

([0-9]*[0-9.][0-9]*([Ee][-+]?[0-9]+)?|"0x"[0-9A-Fa-f]+) {
 	yylval.text = strdup(yytext);
	final(NUM_LITERAL);
}

\"(\\.|[^"\\])*\"       { yylval.text = strdup(yytext); final(STR_LITERAL); }

[ \t]+                  { /* ignore spaces */ }

\n+                     {
	if (can_insert_semicolon) {
		non_final(SEMI);
	}
}

.                       {
	printf(
		"** Line %d, column %d: unrecognized symbol \u2018%s\u2019\n",
		yylloc.first_line,
		yylloc.first_column,
        	yytext
        );
        exit(0);
}

%%
