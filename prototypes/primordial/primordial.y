// Syntactic grammar of the Primordial language.
//
// We use Bison and Flex to prototype and validate the adequacy of the grammar
// against a test suite. These tests will also be reused in the future to
// validate the compiler.
//
// Design decisions:
//
// - Supports declarations, which allows the implementation of single-pass
//   variants (e.g., for p0).
//
// - Identifiers are segregated into 4 categories which are enforced and
//   exploited by the grammar:
//
//   - Exported upper IDs (`List`)
//   - Exported lower IDs (`printf`)
//   - Internal upper IDs (`_Impl`)
//   - Internal lower IDs (`_size`)
//
// - Exported symbols start with a letter. Internal symbols start with an
//   underscore. This is reminiscent of the Python naming convention, and is
//   convenient, for example, to avoid the naming ambiguity between a getter
//   (size) and the field that stores its value (_size).
//
// - The first letter in a lower ID, after possibly a number of underscores,
//   is lowercase. They denote values and constants. The first letter in an
//   upper ID, after possibly a number of underscores, is uppercase. They
//   denote types and packages. This segregation of type and value identifiers
//   prevents an analog of C's typedef ambiguity, and is helpful to humans. In
//   particular, we observe that we are merely enforcing a variant of what is
//   already a common convention in some popular programming languages.
//
// - Identifiers consisting exclusively of more than one underscore are invalid.
//
// - A single underscore is recognised as the omit token, which can be used to
//   discard results in assignments.
//
// - Internal packages are denoted by internal upper IDs. They can only be
//   accessed by their parent and siblings. This is similar to Go, but with one
//   fewer level of package depth. "_" can be used as a directory name to
//   indicate an empty package that starts a subtree of internal packages.
//
// - Expressions and statements are strictly separated to minimise unintended
//   side-effects.
//
// - All lists separated by commas are left-associative to minimise stack
//   usage in bottom-up parsers.
//
// - All binary operators are left-associative.
//
// - All value expression operators are prefix.
//
// - All type modifiers are postfix.

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

#include <algorithm>
#include <functional>
#include <iterator>
#include <list>
#include <string>
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
%token OMIT "_"
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
%token <bool> BOOLEAN_LITERAL "Boolean literal"
%token <std::string> NUMERIC_LITERAL "numeric literal"
%token <std::string> STRING_LITERAL "string literal"

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
%nterm <std::unique_ptr<AST::RawSliceType>> RawSliceType
%nterm <std::unique_ptr<AST::PointerType>> PointerType
%nterm <std::unique_ptr<AST::FunctionType>> FunctionType
%nterm <std::unique_ptr<AST::StructType>> StructType
%nterm <std::unique_ptr<AST::UnionType>> UnionType
%nterm <std::unique_ptr<AST::InterfaceType>> InterfaceType

%nterm <AST::Field> Field
%nterm <std::vector<AST::Field>> FieldList
%nterm <std::vector<AST::Field>> XFieldList

// We cannot use concrete types here because of embedding higher-precedence
// expressions in lower-precedence expressions.
%nterm <std::unique_ptr<AST::Expression>> Expression
%nterm <std::unique_ptr<AST::Expression>> AndExpression
%nterm <std::unique_ptr<AST::Expression>> RelExpression
%nterm <std::unique_ptr<AST::Expression>> SumExpression
%nterm <std::unique_ptr<AST::Expression>> MulExpression
%nterm <std::unique_ptr<AST::Expression>> UnaryExpression
%nterm <std::unique_ptr<AST::Expression>> Term
%nterm <std::unique_ptr<AST::Expression>> Literal

// Leaves in the expression hierarchy can have concrete types.
%nterm <std::unique_ptr<AST::Expression>> FunctionCall
%nterm <std::unique_ptr<AST::ArrayAccess>> ArrayAccess
%nterm <std::unique_ptr<AST::FieldAccess>> FieldAccess
%nterm <std::unique_ptr<AST::PackageAccess>> PackageAccess
%nterm <std::unique_ptr<AST::Expression>> AnonymousFunctionDef
%nterm <std::unique_ptr<AST::PointerDereference>> PointerDereference
%nterm <std::unique_ptr<AST::TypeCast>> TypeCast
%nterm <std::unique_ptr<AST::Expression>> SymbolAccess

%nterm <AST::ExpressionList> ExpressionList
%nterm <AST::ExpressionList> NEExpressionList
%nterm <AST::ExpressionList> XExpressionList

%nterm <AST::FieldAssignment> FieldAssignment
%nterm <AST::FieldAssignmentList> NEFieldAssignmentList
%nterm <AST::FieldAssignmentList> XFieldAssignmentList

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
	std::move(std::begin($4), std::end($4), std::back_inserter($$));
};

ImportGroup : %empty {
	// $$ was default constructed.
};

ImportGroup : ImportGroup Import ";"	{
	$$ = std::move($1);
	$$.push_back(std::move($2));
};

Import : STRING_LITERAL {
	$$ = AST::Import(std::move($1));
};

Import : UPPER_ID STRING_LITERAL {
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

// The parentheses aren't really necessary, but might provide a visual cue.
Receiver
	: "(" ReceiverType ")"
	| "(" LOWER_ID ReceiverType ")"
	;

ReceiverType
	: UPPER_ID
	| UPPER_ID "?"
	| UPPER_ID "[" NETypeList "]"
	| UPPER_ID "[" NETypeList "]" "?"
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
	: "(" ArgumentList ")"
	| "(" ArgumentList ")" "->" "(" NETypeList ")"
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
	: NELeftValueList "=" NEExpressionList
	| NELeftValueList ":=" NEExpressionList
	;

MaybeAssignment
	: %empty
	| Assignment
	;

AssignmentSeq
	: %empty
	| AssignmentSeq Assignment ";"
	;

NELeftValueList
	: XLeftValueList MaybeComma
	;

XLeftValueList
	: LeftValue
	| XLeftValueList "," LeftValue
	;

LeftValue
	: OMIT
	| Expression
	;

NELowerIDList
	: XLowerIDList MaybeComma
	;

XLowerIDList
	: LOWER_ID
	| XLowerIDList "," LOWER_ID
	;

FunctionCall
	: Term "(" ExpressionList ")" { /* TODO */ }
	| Term "[" NETypeList "]" "(" ExpressionList ")" { /* TODO */ }
	;

AnonymousFunctionDef
	: "func" FunctionSignature Block { /* TODO */ }
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

Expression : AndExpression {
	$$ = std::move($1);
};

Expression : Expression "||" AndExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::LOGICAL_AND,
		std::move($1),
		std::move($3)
	);
};

AndExpression : RelExpression {
 	$$ = std::move($1);
};

AndExpression : AndExpression "&&" RelExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::LOGICAL_AND,
		std::move($1),
		std::move($3)
	);
};

RelExpression : SumExpression {
	$$ = std::move($1);
};

RelExpression : RelExpression "==" SumExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::EQ,
		std::move($1),
		std::move($3)
	);
};

RelExpression : RelExpression "!=" SumExpression {
$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::NE,
		std::move($1),
		std::move($3)
	);
};

RelExpression : RelExpression "<=" SumExpression {
$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::LE,
		std::move($1),
		std::move($3)
	);
};

RelExpression : RelExpression ">=" SumExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::GE,
		std::move($1),
		std::move($3)
	);
};

RelExpression : RelExpression "<" SumExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::LT,
		std::move($1),
		std::move($3)
	);
};

RelExpression : RelExpression ">" SumExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::GT,
		std::move($1),
		std::move($3)
	);
};

SumExpression : MulExpression {
	$$ = std::move($1);
};

SumExpression : SumExpression "+" MulExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::ADD,
		std::move($1),
		std::move($3)
	);
};

SumExpression : SumExpression "-" MulExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::SUB,
		std::move($1),
		std::move($3)
	);
};

SumExpression : SumExpression "|" MulExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::BITWISE_OR,
		std::move($1),
		std::move($3)
	);
};

SumExpression : SumExpression "^" MulExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::BITWISE_XOR,
		std::move($1),
		std::move($3)
	);
};

MulExpression : UnaryExpression {
	$$ = std::move($1);
};

MulExpression : MulExpression "*" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::MUL,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression "/" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::DIV,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression "%" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::REM,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression "&" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::BITWISE_AND,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression "&^" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::BITWISE_CLEAR,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression "<<" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::LEFT_SHIFT,
		std::move($1),
		std::move($3)
	);
};

MulExpression : MulExpression ">>" UnaryExpression {
	$$ = std::make_unique<AST::BinaryExpression>(
		AST::BinaryOperator::RIGHT_SHIFT,
		std::move($1),
		std::move($3)
	);
};

UnaryExpression	: Term {
	$$ = std::move($1);
};

UnaryExpression	: "-" UnaryExpression {
	$$ = std::make_unique<AST::UnaryExpression>(
		AST::UnaryOperator::NEG,
		std::move($2)
	);
};

UnaryExpression	: "~" UnaryExpression {
	$$ = std::make_unique<AST::UnaryExpression>(
		AST::UnaryOperator::BITWISE_NOT,
		std::move($2)
	);
};

UnaryExpression	: "!" UnaryExpression {
	$$ = std::make_unique<AST::UnaryExpression>(
		AST::UnaryOperator::LOGICAL_NOT,
		std::move($2)
	);
};

UnaryExpression	: "@" UnaryExpression {
	$$ = std::make_unique<AST::UnaryExpression>(
		AST::UnaryOperator::ADDRESS_OF,
		std::move($2)
	);
};

Term
	: "(" Expression ")" { $$ = std::move($2); }
	| FunctionCall { $$ = std::move($1); }
	| AnonymousFunctionDef { $$ = std::move($1); }
	| ArrayAccess { $$ = std::move($1); }
	| FieldAccess { $$ = std::move($1); }
	| PackageAccess { $$ = std::move($1); }
	| SymbolAccess { $$ = std::move($1); }
	| PointerDereference { $$ = std::move($1); }
	| TypeCast { $$ = std::move($1); }
	| Literal { $$ = std::move($1); }
	;

ArrayAccess : Term "[" Expression "]" {
	$$ = std::make_unique<AST::ArrayAccess>(
		std::move($1),
		std::move($3)
	);
};

FieldAccess : Term "." LOWER_ID {
	$$ = std::make_unique<AST::FieldAccess>(std::move($1), std::move($3));
};

PackageAccess : UPPER_ID "." LOWER_ID {
	$$ = std::make_unique<AST::PackageAccess>(std::move($1), std::move($3));
};

SymbolAccess : LOWER_ID {
	$$ = std::make_unique<AST::SymbolAccess>(std::move($1));
}

Literal : BOOLEAN_LITERAL {
	$$ = std::make_unique<AST::BooleanLiteral>($1);
};

Literal : STRING_LITERAL {
	$$ = std::make_unique<AST::StringLiteral>(std::move($1));
};

Literal : NUMERIC_LITERAL {
	$$ = std::make_unique<AST::NumericLiteral>(std::move($1));
};

// The empty struct and the empty list look identical, so we need to treat it
// on its own to prevent ambiguities, and require non-emptiness from the rest.
Literal : CompoundLiteralType "{" "}" {
	$$ = std::make_unique<AST::EmptyCompoundLiteral>(std::move($1));
};

Literal	: CompoundLiteralType "{" NEFieldAssignmentList "}" {
	$$ = std::make_unique<AST::RecordLiteral>(std::move($1), std::move($3));
};

Literal : CompoundLiteralType "{" NEExpressionList "}" {
	$$ = std::make_unique<AST::ListLiteral>(std::move($1), std::move($3));
};

PointerDereference : Term "." {
	$$ = std::make_unique<AST::PointerDereference>(std::move($1));
};

TypeCast : Type "(" Expression ")" {
	$$ = std::make_unique<AST::TypeCast>(std::move($1), std::move($3));
};

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

NEFieldAssignmentList : XFieldAssignmentList MaybeComma {
	$$ = std::move($1);
};

XFieldAssignmentList : FieldAssignment {
	$$.push_back(std::move($1));
};

XFieldAssignmentList: XFieldAssignmentList "," FieldAssignment {
	$$ = std::move($1);
	$$.push_back(std::move($3));
};

FieldAssignment : LOWER_ID ":" Expression {
	$$ = AST::FieldAssignment(std::move($1), std::move($3));
};

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
	| RawSliceType { $$ = std::move($1); }
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

RawSliceType : Type "[" "_" "]"	{
	$$ = std::make_unique<AST::RawSliceType>(std::move($1));
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

StructType : "struct" "{" FieldList "}" {
	$$ = std::make_unique<AST::StructType>(std::move($3));
};

UnionType :  "union" "{" FieldList "}" {
	$$ = std::make_unique<AST::UnionType>(std::move($3));
};

InterfaceType : "interface" "{" InterfaceItems "}" {
	// TODO
};

ExpressionList : %empty {
	// $$ was default constructed.
};

ExpressionList : XExpressionList MaybeComma {
	$$ = std::move($1);
};

NEExpressionList : XExpressionList MaybeComma {
	$$ = std::move($1);
};

XExpressionList	: Expression {
	$$.push_back(std::move($1));
};

XExpressionList : XExpressionList "," Expression {
	$$ = std::move($1);
	$$.push_back(std::move($3));
};

FieldList : %empty {
	// $$ was default constructed.
};

FieldList : XFieldList MaybeSemi {
	$$ = std::move($1);
};

XFieldList : Field {
	$$.push_back(std::move($1));
};

XFieldList : XFieldList ";" Field {
	$$ = std::move($1);
	$$.push_back(std::move($3));
};

Field : Type {
	$$ = AST::Field(std::move($1));
};

Field : LOWER_ID Type {
	$$ = AST::Field(std::move($1), std::move($2));
};

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
