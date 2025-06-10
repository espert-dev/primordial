%{
#include <stdbool.h>
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

"#"[^\n]*              {/* ignore comments */}

";"                    { non_final(SEMI); }
"("                    { non_final(LPAR); }
")"                    { final(RPAR); }

"import"               { non_final(IMPORT); }
"package"              { non_final(PACKAGE); }

[A-Z][0-9A-Za-z_]*     { yylval.text = strdup(yytext); final(UPPER_ID); }
[a-z_][0-9A-Za-z_]*    { yylval.text = strdup(yytext); final(LOWER_ID); }

\"(\\.|[^"\\])*\"      { yylval.text = strdup(yytext); final(STR_LITERAL); }

[ \t]+                 { /* ignore spaces */ }

\n+                    {
	if (can_insert_semicolon) {
		non_final(SEMI);
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
