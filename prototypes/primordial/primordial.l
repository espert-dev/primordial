%{
#include "parser.h"

#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line; \
    yylloc.first_column = yylloc.last_column; \
    for (int i = 0; yytext[i] != '\0'; i++) { \
        if (yytext[i] == '\n') { \
            yylloc.last_line++; \
            yylloc.last_column = 0; \
        } \
        else { \
            yylloc.last_column++; \
        } \
    }
%}

%option noyywrap
%option yylineno

%%

"#"[^\n]*              {/* ignore comments */}

";"                    { return SEMI; }
"("                    { return LPAR; }
")"                    { return RPAR; }

"import"               { return IMPORT; }
"package"              { return PACKAGE; }

[A-Z][0-9A-Za-z_]*     { return UPPER_ID; }
[a-z_][0-9A-Za-z_]*    { return LOWER_ID; }

\"(\\.|[^"\\])*\"      { return STR_LITERAL; }

[ \t\n]+               {/* ignore spaces */}

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
