%{
#include "parser.h"

#define YY_USER_ACTION {\
	yylloc.first_line = yylloc.last_line;\
	yylloc.first_column = yylloc.last_column;\
	for (int i = 0; yytext[i] != '\0'; i++) {\
		if (yytext[i] == '\n') {\
			yylloc.last_line++;\
			yylloc.last_column = 0;\
		} else {\
			yylloc.last_column++;\
		}\
	}\
}

/* Record the token for the implicit semicolon rule and return it */
#define emit(x) {\
	last_token = x;\
	return x;\
}

/* Track the last token for the implicit semicolon rule */
static int last_token = -1;
%}

%option noyywrap
%option yylineno

%%

"#"[^\n]*              {/* ignore comments */}

";"                    { emit(SEMI); }
"("                    { emit(LPAR); }
")"                    { emit(RPAR); }

"import"               { emit(IMPORT); }
"package"              { emit(PACKAGE); }

[A-Z][0-9A-Za-z_]*     { yylval.text = strdup(yytext); emit(UPPER_ID); }
[a-z_][0-9A-Za-z_]*    { yylval.text = strdup(yytext); emit(LOWER_ID); }

\"(\\.|[^"\\])*\"      { yylval.text = strdup(yytext); emit(STR_LITERAL); }

[ \t]+                 { /* ignore spaces */ }

\n+                    {
	/* Adapt BCPL's and Go's rules for automatic semicolons */
	switch (last_token) {
		/* After IDs */
		case UPPER_ID: [[fallthrough]];
		case LOWER_ID: [[fallthrough]];
		case STR_LITERAL: [[fallthrough]];

		/* After control flow keywords */

		/* After operators */

		/* After closing brackets and separators other than SEMI */
		case RPAR:
			emit(SEMI);
			break;

		default:
			/* No implicit semicolon */
	}
}

.                      {
	printf(
		"** Line %d, column %d: unrecognized symbol \u2018%s\u2019\n",
		yylloc.first_line,
		yylloc.first_column,
        	yytext
        );
        exit(0);
}

%%
