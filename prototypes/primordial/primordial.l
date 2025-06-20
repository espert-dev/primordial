/*
 * Lexical grammar for the Primordial language.
 */

%{
#include <iostream>

#define YY_DECL yy::Parser::symbol_type\
	yylex(yyscan_t yyscanner, yy::location& loc)

#define YY_USER_ACTION\
	loc.columns(yyleng);

#define yyterminate()\
	return yy::Parser::make_END(loc)

#include "parser.hpp"

// Track the last token for the implicit semicolon rule
static bool can_insert_semicolon = false;
%}

%option reentrant
%option nounput
%option noyywrap
%option yylineno

%%

%{
	loc.step();
%}

"#"[^\n]* {
	// ignore comments
}

"(" {
	can_insert_semicolon = false;
	return yy::Parser::make_LPAR(loc);
}
"[" {
	can_insert_semicolon = false;
	return yy::Parser::make_LBRA(loc);
}
"{" {
	can_insert_semicolon = false;
	return yy::Parser::make_LCUR(loc);
}
")" {
	can_insert_semicolon = true;
	return yy::Parser::make_RPAR(loc);
}
"]" {
	can_insert_semicolon = true;
	return yy::Parser::make_RBRA(loc);
}
"}" {
	can_insert_semicolon = true;
	return yy::Parser::make_RCUR(loc);
}
"@" {
	can_insert_semicolon = true;
	return yy::Parser::make_AT(loc);
}
"," {
	can_insert_semicolon = true;
	return yy::Parser::make_COMMA(loc);
}
";" {
	can_insert_semicolon = false;
	return yy::Parser::make_SEMI(loc);
}
"." {
	// This one has to be final because of the possibility of a pointer
	// dereference happening at the end of an expression.
	can_insert_semicolon = true;
	return yy::Parser::make_PERIOD(loc);
}

"=" {
	can_insert_semicolon = false;
	return yy::Parser::make_ASSIGN(loc);
}
":=" {
	can_insert_semicolon = false;
	return yy::Parser::make_DEFINE(loc);
}
"->" {
	can_insert_semicolon = false;
	return yy::Parser::make_TO(loc);
}
":" {
	can_insert_semicolon = false;
	return yy::Parser::make_COLON(loc);
}
"||" {
	can_insert_semicolon = false;
	return yy::Parser::make_LOGIC_OR(loc);
}
"&&" {
	can_insert_semicolon = false;
	return yy::Parser::make_LOGIC_AND(loc);
}
"==" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_EQ(loc);
}
"!=" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_NE(loc);
}
"<=" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_LE(loc);
}
">=" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_GE(loc);
}
"<" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_LT(loc);
}
">" {
	can_insert_semicolon = false;
	return yy::Parser::make_CMP_GT(loc);
}
"+" {
	can_insert_semicolon = false;
	return yy::Parser::make_ADD(loc);
}
"-" {
	can_insert_semicolon = false;
	return yy::Parser::make_SUB(loc);
}
"|" {
	can_insert_semicolon = false;
	return yy::Parser::make_BITWISE_OR(loc);
}
"^" {
	can_insert_semicolon = false;
	return yy::Parser::make_BITWISE_XOR(loc);
}
"*" {
	can_insert_semicolon = false;
	return yy::Parser::make_MUL(loc);
}
"/" {
	can_insert_semicolon = false;
	return yy::Parser::make_DIV(loc);
}
"%" {
	can_insert_semicolon = false;
	return yy::Parser::make_REM(loc);
}
"&" {
	can_insert_semicolon = false;
	return yy::Parser::make_BITWISE_AND(loc);
}
"&^" {
	can_insert_semicolon = false;
	return yy::Parser::make_BITWISE_AND_NOT(loc);
}
"<<" {
	can_insert_semicolon = false;
	return yy::Parser::make_LSHIFT(loc);
}
">>" {
	can_insert_semicolon = false;
	return yy::Parser::make_RSHIFT(loc);
}
"!" {
	can_insert_semicolon = false;
	return yy::Parser::make_LOGICAL_NOT(loc);
}
"~" {
	can_insert_semicolon = false;
	return yy::Parser::make_BITWISE_NOT(loc);
}

[!%&*+-/:<=>\\^|~]+     {
	// Handle unknown operator.
	// This rule must appear AFTER all known operators.
	can_insert_semicolon = false;
	exit(42);
}

"_" {
	// For consistency with identifiers.
	can_insert_semicolon = true;
	return yy::Parser::make_OMIT(loc);
}
"import" {
 	can_insert_semicolon = false;
 	return yy::Parser::make_IMPORT(loc);
}
"package" {
	can_insert_semicolon = false;
	return yy::Parser::make_PACKAGE(loc);
}
"let" {
 	can_insert_semicolon = false;
 	return yy::Parser::make_LET(loc);
 }
"var" {
	can_insert_semicolon = false;
 	return yy::Parser::make_VAR(loc);
 }
"if" {
	can_insert_semicolon = false;
 	return yy::Parser::make_IF(loc);
 }
"else" {
	can_insert_semicolon = false;
	return yy::Parser::make_ELSE(loc);
}
"while" {
	can_insert_semicolon = false;
	return yy::Parser::make_WHILE(loc);
}
"for" {
	can_insert_semicolon = false;
	return yy::Parser::make_FOR(loc);
}
"type" {
	can_insert_semicolon = false;
	return yy::Parser::make_TYPE(loc);
}
"func" {
	can_insert_semicolon = false;
	return yy::Parser::make_FUNC(loc);
}
"struct" {
	can_insert_semicolon = false;
	return yy::Parser::make_STRUCT(loc);
}
"union" {
	can_insert_semicolon = false;
	return yy::Parser::make_UNION(loc);
}
"interface" {
	can_insert_semicolon = false;
	return yy::Parser::make_INTERFACE(loc);
}
"continue" {
	can_insert_semicolon = true;
	return yy::Parser::make_CONTINUE(loc);
}
"break" {
	can_insert_semicolon = true;
	return yy::Parser::make_BREAK(loc);
}
"goto" {
	can_insert_semicolon = true;
	return yy::Parser::make_GOTO(loc);
}
"true" {
	can_insert_semicolon = true;
	return yy::Parser::make_BOOLEAN_LITERAL(true, loc);
}
"false" {
	can_insert_semicolon = true;
	return yy::Parser::make_BOOLEAN_LITERAL(false, loc);
}

[_]*[A-Z][_0-9A-Za-z]* {
	// This rule must appear AFTER all keywords.
	can_insert_semicolon = true;
	return yy::Parser::make_UPPER_ID(yytext, loc);
}

[_]*[a-z][_0-9A-Za-z]* {
	// This rule must appear AFTER all keywords.
	can_insert_semicolon = true;
	return yy::Parser::make_LOWER_ID(yytext, loc);
}

([0-9]*[0-9.][0-9]*([Ee][-+]?[0-9]+)?|"0x"[0-9A-Fa-f]+) {
	can_insert_semicolon = true;
	return yy::Parser::make_NUMERIC_LITERAL(yytext, loc);
}

\"(\\.|[^"\\])*\" {
	can_insert_semicolon = true;
	return yy::Parser::make_STRING_LITERAL(yytext, loc);
}

[ \t]+ {
	// Ignore spaces.
}

\n+ {
	if (can_insert_semicolon) {
		can_insert_semicolon = false;
		return yy::Parser::make_SEMI(loc);
	}
}

. {
	// Handle lexical error.
	can_insert_semicolon = true;
	exit(41);
}

%%
