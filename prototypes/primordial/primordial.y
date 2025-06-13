// Grammar of the Primordial language.
//
// We use Bison and Flex to prototype and validate the adequacy of the grammar
// against a test suite. These tests will also be reused in the future to
// validate the compiler.

%require "3.8.0"
%language "c++"

%define lr.type lalr
%skeleton "lalr1.cc"
%locations
%defines

%define api.token.raw
%define api.prefix {yy}
%define api.parser.class {Parser}
%define api.token.constructor
%define api.value.type variant

%define parse.assert
%define parse.trace
%define parse.error detailed

%lex-param {void *scanner} {yy::location &loc}
%parse-param {void *scanner} {yy::location &loc} {Primordial::Driver &drv}

%code requires {

#include <list>
#include <string>
#include <functional>
#include "primordial.hpp"
#include "ast.hpp"

}

%code {

#include "scanner.hpp"

yy::Parser::symbol_type yylex(void* yyscanner, yy::location& loc);

}

%start File

%token END 0

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
%token ASSIGN "="
%token DEFINE ":="
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
%token <std::string> UPPER_ID "upper identifier"
%token <std::string> LOWER_ID "lower identifier"

/* Literals */
%token <bool> BOOL_LITERAL "Boolean literal"
%token <std::string> NUM_LITERAL "numeric literal"
%token <std::string> STR_LITERAL "string literal"

/* Non-terminals */
%nterm <std::string> PackageDecl
%nterm <std::vector<AST::Import>> ImportList
%nterm <std::vector<AST::Import>> ImportGroup
%nterm <AST::Import> Import

%nterm <std::unique_ptr<AST::Type>> Type
%nterm <std::unique_ptr<AST::Type>> CompoundLiteralType

%nterm <AST::TypeList> NETypeList
%nterm <AST::TypeList> XTypeList

%nterm <std::unique_ptr<AST::TypeName>> TypeName
%nterm <std::unique_ptr<AST::QualifiedTypeName>> QualifiedTypeName
%nterm <std::unique_ptr<AST::TypeInstantiation>> TypeInstantiation
%nterm <std::unique_ptr<AST::ArrayType>> ArrayType
%nterm <std::unique_ptr<AST::SliceType>> SliceType
%nterm <std::unique_ptr<AST::PointerType>> PointerType
%nterm <std::unique_ptr<AST::FunctionType>> FunctionType
%nterm <std::unique_ptr<AST::StructType>> StructType
%nterm <std::unique_ptr<AST::UnionType>> UnionType
%nterm <std::unique_ptr<AST::InterfaceType>> InterfaceType

%nterm <std::unique_ptr<AST::Expression>> Expression

%%

File : PackageDecl ImportList TopItems {
	auto file = std::make_unique<AST::File>(std::move($1), std::move($2));
	drv.set_result(std::move(file));
};

PackageDecl : "package" UPPER_ID ";" {
	$$ = std::string(std::move($2));
};

ImportList : %empty {
	// $$ was default constructed.
};

ImportList : ImportList "import" Import ";" {
	$$ = std::move($1);
	$$.push_back(std::move($3));
};

ImportList : ImportList "import" "(" ImportGroup ")" ";" {
	$$ = std::move($1);
	$$.insert(std::end($$), std::begin($4), std::end($4));
};

ImportGroup : %empty {
	// $$ was default constructed.
};

ImportGroup : ImportGroup Import ";"	{
	$$ = std::move($1);
	$$.push_back(std::move($2));
};

Import : STR_LITERAL {
	$$ = AST::Import(std::move($1));
};

Import : UPPER_ID STR_LITERAL {
	$$ = AST::Import(std::move($2), std::move($1));
};

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
	: "let" NELowerIDList "=" NEExpressionList
	| "let" NELowerIDList Type "=" NEExpressionList
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
	: "var" NELowerIDList
	| "var" NELowerIDList Type
	| "var" NELowerIDList "=" NEExpressionList
	| "var" NELowerIDList Type "=" NEExpressionList
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
	: "func" LOWER_ID FunctionSignature Block
	| "func" LOWER_ID "[" NETypeArgList "]" FunctionSignature Block
	| "func" Receiver LOWER_ID FunctionSignature Block
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
	: "func" LOWER_ID FunctionSignature
	| "func" LOWER_ID "[" NETypeArgList "]" FunctionSignature
	| "func" LOWER_ID "[" NETypeList "]" FunctionSignature
	| "func" Receiver LOWER_ID FunctionSignature
	;

FunctionSignature
	: "(" ArgumentList ")" FunctionReturnValues
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

FunctionReturnValues
	: %empty
	| "->" "(" NETypeList ")"
	| "->" "(" ArgumentList ")"
	;

Block
	: "{" StatementList "}"
	;

StatementList
	: %empty
	| XStatementList MaybeSemi
	;

XStatementList
	: Statement
	| XStatementList ";" Statement
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

NELowerIDList
	: XLowerIDList MaybeComma
	;

XLowerIDList
	: LOWER_ID
	| XLowerIDList "," LOWER_ID
	;

FunctionCall
	: Term "(" ExpressionList ")"
	| Term "[" NETypeList "]" "(" ExpressionList ")"
	;

AnonymousFunctionDef
	: "func" FunctionSignature Block
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
 *	for i := 0; l := len(l); i < l; i++ {
 *		# ...
 *	}
 *
 */
For
	: "for" AssignmentSeq Expression ";" MaybeAssignment Block
	;

/*
 * Unlike Go, we can have more than one statement in a Condition.
 *
 *	if la := len(a); lb := len(b); la < lb {
 *		# ...
 *	}
 *
 * In my opinion, this is more readable than:
 *
 *	if la, lb := len(a), len(b); la < lb {
 *		# ...
 *	}
 *
 * Don't abuse it and it should be fine.
 *
 */
Condition
	: AssignmentSeq Expression
	;

Expression
	: AndExpression { /* TODO */ }
	| Expression "||" AndExpression { /* TODO */ }
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
	| BOOL_LITERAL
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
 *	x := func(){}
 *
 * could be interpreted as a struct literal, instead of an anonymous
 * function definition.
 */
CompoundLiteralType
	: TypeName { $$ = std::move($1); }
	| QualifiedTypeName { $$ = std::move($1); }
	| TypeInstantiation { $$ = std::move($1); }
	| ArrayType { $$ = std::move($1); }
	| SliceType { $$ = std::move($1); }
	| StructType { $$ = std::move($1); }
	| UnionType { $$ = std::move($1); }
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

NETypeList : XTypeList MaybeComma {
	$$ = std::move($1);
};

XTypeList : Type {
	$$.push_back(std::move($1));
};

XTypeList : XTypeList "," Type {
	$$ = std::move($1);
	$$.push_back(std::move($3));
};

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
	: TypeName { $$ = std::move($1); }
	| QualifiedTypeName { $$ = std::move($1); }
	| TypeInstantiation { $$ = std::move($1); }
	| ArrayType { $$ = std::move($1); }
	| SliceType { $$ = std::move($1); }
	| PointerType { $$ = std::move($1); }
	| FunctionType { $$ = std::move($1); }
	| StructType { $$ = std::move($1); }
	| UnionType { $$ = std::move($1); }
	| InterfaceType { $$ = std::move($1); }
	;

TypeName : UPPER_ID {
	$$ = std::make_unique<AST::TypeName>(std::move($1));
};

QualifiedTypeName : UPPER_ID "." UPPER_ID {
 	$$ = std::make_unique<AST::QualifiedTypeName>(
 		std::move($1),
 		std::move($3)
	);
};

TypeInstantiation : Type "[" NETypeList "]" {
	$$ = std::make_unique<AST::TypeInstantiation>(
		std::move($1),
		std::move($3)
	);
};

ArrayType : Type "[" Expression "]" {
	$$ = std::make_unique<AST::ArrayType>(std::move($1), std::move($3));
};

SliceType : Type "[" "]" {
	$$ = std::make_unique<AST::SliceType>(std::move($1));
};

PointerType : Type "?" {
	$$ = std::make_unique<AST::PointerType>(std::move($1));
};

FunctionType : "func" "(" NETypeList ")" {
	$$ = std::make_unique<AST::FunctionType>(std::move($3));
};

FunctionType : "func" "(" NETypeList ")" "->" "(" NETypeList ")" {
	$$ = std::make_unique<AST::FunctionType>(std::move($3), std::move($7));
};

StructType : "struct" "{" RecordItems "}" {
	// TODO
};

UnionType :  "union" "{" RecordItems "}" {
	// TODO
};

InterfaceType : "interface" "{" InterfaceItems "}" {
	// TODO
};

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
	: Type
	| "~" Type
	| LOWER_ID FunctionSignature
	;

MaybeComma
	: %empty
	| ","
	;

MaybeSemi
	: %empty
	| ";"
	;

%%

void yy::Parser::error(const yy::location& l, const std::string& m) {
	std::cerr << l << ": " << m << std::endl;
}
