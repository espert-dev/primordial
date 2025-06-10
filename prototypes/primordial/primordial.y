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
%token LBRA "["
%token RBRA "]"
%token LCUR "{"
%token RCUR "}"
%token COMMA ","
%token PERIOD "."
%token SEMI ";"
%token MAYBE "?"
%token AT "@"

/* Operators */
%token TO "->"
%token COLON ":"
%token LOGIC_OR "||"
%token LOGIC_AND "&&"
%token CMP_EQ "=="
%token CMP_NE "!="
%token CMP_LE "<="
%token CMP_GE ">="
%token CMP_LT "<"
%token CMP_GT ">"
%token ADD "+"
%token SUB "-"
%token BITWISE_OR "|"
%token BITWISE_XOR "^"
%token MUL "*"
%token DIV "/"
%token REM "%"
%token BITWISE_AND "&"
%token BITWISE_AND_NOT "&^"
%token LSHIFT "<<"
%token RSHIFT ">>"
%token LOGICAL_NOT "!"
%token BITWISE_NOT "~"

/* Keywords */
%token IMPORT "import"
%token PACKAGE "package"
%token LET "let"
%token VAR "var"
%token IF "if"
%token ELSE "else"
%token WHILE "while"
%token FOR "for"
%token TYPE "type"
%token FUNC "func"
%token STRUCT "struct"
%token UNION "union"
%token INTERFACE "interface"
%token CONTINUE "continue"
%token BREAK "break"
%token GOTO "goto"

/* Identifiers */
%token <text> UPPER_ID "upper identifier"
%token <text> LOWER_ID "lower identifier"

/* Literals */
%token <text> NUM_LITERAL "numeric literal"
%token <text> STR_LITERAL "string literal"

%union {
	const char *text;
}

%%

File
	: PackageDecl Imports TopItems
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

TopItems
	: %empty
	| TopItems TopItem ";"
	;

TopItem
	: TypeDef
	| TypeDecl
	| FunctionDef
	| FunctionDecl
	| Let
	| Var
	;

Let
	: "let" NELOWER_IDList "=" NEExpressionList
	: "let" NELOWER_IDList Type "=" NEExpressionList
	| "let" "(" LetDefinitionGroup ")"
	;

LetDefinitionItem
	: LOWER_ID "=" Expression
	| LOWER_ID Type "=" Expression
	;

LetDefinitionGroup
	: %empty
	| LetDefinitionGroup LetDefinitionItem ";"
	;

Var
	: "var" NELOWER_IDList
	| "var" NELOWER_IDList Type
	| "var" NELOWER_IDList "=" NEExpressionList
	| "var" NELOWER_IDList Type "=" NEExpressionList
	| "var" "(" VarDefinitionGroup ")"
	;

VarDefinitionItem
	: LOWER_ID
	| LOWER_ID Type
	| LOWER_ID "=" Expression
	| LOWER_ID Type "=" Expression
	;

VarDefinitionGroup
	: %empty
	| VarDefinitionGroup VarDefinitionItem ";"
	;

TypeDef
	: "type" UPPER_ID Type
	| "type" UPPER_ID "[" NETypeArgList "]" Type
	;

/* Potentially useful to define opaque types */
TypeDecl
	: "type" UPPER_ID
	| "type" UPPER_ID "[" NETypeArgList "]"
	| "type" UPPER_ID "[" NETypeList "]"
	;

/* Methods cannot take generic parameters */
FunctionDef
	: "func" LOWER_ID FullSignature Block
	| "func" LOWER_ID "[" NETypeArgList "]" FullSignature Block
	| "func" Receiver LOWER_ID FullSignature Block
	;

/* Type already includes generic instantiation */
Receiver
	: "(" Type ")"
	| "(" LOWER_ID Type ")"
	;

/*
 * The syntax supports opaque function declarations.
 *
 * These would be necessary should we decide to implement p0 as a single-pass
 * compiler.
 */
FunctionDecl
	: "func" LOWER_ID Signature
	| "func" LOWER_ID "[" NETypeArgList "]" Signature
	| "func" LOWER_ID "[" NETypeList "]" Signature
	| "func" Receiver LOWER_ID Signature
	;

/* Naming return values is always optional */
Signature
	: FullSignature
	| PartialSignature
	;

FullSignature
	: "(" ArgumentList ")" ReturnValues
	;

PartialSignature
	: "(" NETypeList ")" ReturnValues
	;

ArgumentList
	: %empty
	| XArgumentList MaybeComma
	;

XArgumentList
	: Argument
	| XArgumentList "," Argument
	;

Argument
	: LOWER_ID Type
	;

ReturnValues
	: %empty
	| "->" "(" NETypeList ")"
	| "->" "(" ArgumentList ")"
	;

Block
	: "{" StatementList "}"
	;

StatementList
	: %empty
	| StatementList Statement ";"
	;

Statement
	: FunctionCall
	| Assignment
	| If
	| While
	| For
	| Let
	| Var
	| Block
	| Label
	| Continue
	| Break
	| Goto
	;

Label
	: LOWER_ID ":"
	;

Continue
	: "continue"
	| "continue" LOWER_ID
	;

Break
	: "break"
	| "break" LOWER_ID
	;

Goto
	: "goto" LOWER_ID
	;

Assignment
	: NEExpressionList "=" NEExpressionList
	| NEExpressionList ":=" NEExpressionList
	;

MaybeAssignment
	: %empty
	| Assignment
	;

AssignmentSeq
	: %empty
	| AssignmentSeq Assignment ";"
	;

NELOWER_IDList
	: XLOWER_IDList MaybeComma
	;

XLOWER_IDList
	: LOWER_ID
	| XLOWER_IDList "," LOWER_ID
	;

FunctionCall
	: Term "(" ExpressionList ")"
	| Term "[" NETypeList "]" "(" ExpressionList ")"
	;

AnonymousFunctionDef
	: "func" Signature Block
	;

/*
 * This is a left-associative 'if', which you may find a bit counterintuitive,
 * but is more efficient with LR and Earley parsers.
 */
If
	: IfClause
	| IfClause "else" Block
	;

IfClause
	: "if" Condition Block
	| IfClause "else" "if" Condition Block
	;

While
	: "while" Condition Block
	;

/*
 * Unlike C and Go, we can have an arbitrary number of setup assignments:
 *
 *   for i := 0; l := len(l); i < l; i++ {
 *           # ...
 *   }
 *
 */
For
	: "for" AssignmentSeq Expression ";" MaybeAssignment Block
	;

/*
 * Unlike Go, we can have more than one statement in a Condition.
 *
 *   if la := len(a); lb := len(b); la < lb {
 *           # ...
 *   }
 *
 * In my opinion, this is more readable than:
 *
 *   if la, lb := len(a), len(b); la < lb {
 *           # ...
 *   }
 *
 * Don't abuse it and it should be fine.
 *
 */
Condition
	: AssignmentSeq Expression
	;

Expression
	: AndExpression
	| Expression "||" AndExpression
	;

AndExpression
	: RelExpression
	| AndExpression "&&" RelExpression
	;

RelExpression
	: SumExpression
	| RelExpression "==" SumExpression
	| RelExpression "!=" SumExpression
	| RelExpression "<=" SumExpression
	| RelExpression ">=" SumExpression
	| RelExpression "<" SumExpression
	| RelExpression ">" SumExpression
	;

SumExpression
	: MulExpression
	| SumExpression "+" MulExpression
	| SumExpression "-" MulExpression
	| SumExpression "|" MulExpression
	| SumExpression "^" MulExpression
	;

MulExpression
	: Unary
	| MulExpression "*" Unary
	| MulExpression "/" Unary
	| MulExpression "%" Unary
	| MulExpression "&" Unary
	| MulExpression "&^" Unary
	| MulExpression "<<" Unary
	| MulExpression ">>" Unary
	;

Unary
	: Term
	| "-" Unary
	| "~" Unary
	| "!" Unary
	| "@" Unary /* Address of */
	;

Term
	: "(" Expression ")"
	| Term "[" Expression "]"
	| FunctionCall
	| AnonymousFunctionDef
	| Term "." LOWER_ID /* field access */
	| Term "." /* Pointer dereference */
	| Type "(" Expression ")"
	| LOWER_ID
	| STR_LITERAL
	| NUM_LITERAL
	;

/*
 * The empty struct and the empty list look identical, so we need to treat it
 * on its own to prevent ambiguities.
 */
Term
	: CompoundLiteralType "{" "}"
	| CompoundLiteralType "{" NEFieldAssignmentList "}"
	| CompoundLiteralType "{" NEExpressionList "}"
	;

/*
 * We cannot use the full Type here because otherwise, e.g.,
 *
 *   x := func(){}
 *
 * could be interpreted as a struct literal, instead of an anonymous
 * function definition.
 */
CompoundLiteralType
	: UPPER_ID
	| Type "." UPPER_ID
	| Type "[" NETypeList "]"
	| Type "[" Expression "]"
	| Type "[" "]"
	| StructType
	| UnionType
	;

NEFieldAssignmentList
	: XFieldAssignmentList MaybeComma
	;

XFieldAssignmentList
	: FieldAssignment
	| XFieldAssignmentList "," FieldAssignment
	;

FieldAssignment
	: LOWER_ID ":" Expression
	;

NETypeList
	: XTypeList MaybeComma
	;

XTypeList
	: Type
	| XTypeList "," Type
	;

TypeArg
	: UPPER_ID Type
	;

NETypeArgList
	: XTypeArgList MaybeComma
	;

XTypeArgList
	: TypeArg
	| XTypeArgList "," TypeArg
	;

Type
	: UPPER_ID
	| Type "." UPPER_ID
	| Type "[" NETypeList "]"
	| Type "[" Expression "]" /* Array */
	| Type "[" "]" /* Slice */
	| Type "?" /* Pointer (nullable) */
	| Type "@" /* Reference (not nullable) */
	| "func" Signature
	| StructType
	| UnionType
	| InterfaceType
	;

StructType
	: "struct" "{" RecordItems "}"
	;

UnionType
	:  "union" "{" RecordItems "}"
	;

InterfaceType
	: "interface" "{" InterfaceItems "}"
	;

ExpressionList
	: %empty
	| XExpressionList MaybeComma
	;

NEExpressionList
	: XExpressionList MaybeComma
	;

XExpressionList
	: Expression
	| XExpressionList "," Expression
	;

RecordItems
	: %empty
	| RecordItems RecordItem ";"
	;

RecordItem
	: Type /* Embedding */
	| LOWER_ID Type /* Field */
	;

InterfaceItems
	: %empty
	| InterfaceItems InterfaceItem ";"
	;

InterfaceItem
	: Type /* Embedding or type constraint */
	| "~" Type
	| LOWER_ID Signature /* Method */
	;

MaybeComma
	: %empty
	| ","
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
