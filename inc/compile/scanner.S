# ===========================================================================
# Lexical scanner
# ===========================================================================

.section absolute

# Token types.
.equiv TK_NONE, 0
.equiv TK_BAD_CHAR, 1
.equiv TK_BAD_OPERATOR, 2
.equiv TK_ID, 3

.equiv TK_KEYWORD_BASE, 4
.equiv TK_IF, TK_KEYWORD_BASE + 0
.equiv TK_FOR, TK_KEYWORD_BASE + 1
.equiv TK_FUNC, TK_KEYWORD_BASE + 2
.equiv NUM_KEYWORDS, TK_FUNC - TK_KEYWORD_BASE + 1

.equiv TK_SEPARATOR_BASE, TK_KEYWORD_BASE + NUM_KEYWORDS
.equiv TK_LPAR, TK_SEPARATOR_BASE + 0
.equiv TK_RPAR, TK_SEPARATOR_BASE + 1
.equiv TK_COMMA, TK_SEPARATOR_BASE + 2
.equiv TK_PERIOD, TK_SEPARATOR_BASE + 3
.equiv TK_SEMI, TK_SEPARATOR_BASE + 4
.equiv TK_MAYBE, TK_SEPARATOR_BASE + 5
.equiv TK_AT, TK_SEPARATOR_BASE + 6
.equiv TK_LBRA, TK_SEPARATOR_BASE + 7
.equiv TK_RBRA, TK_SEPARATOR_BASE + 8
.equiv TK_LCUR, TK_SEPARATOR_BASE + 9
.equiv TK_RCUR, TK_SEPARATOR_BASE + 10
.equiv NUM_SEPARATORS, TK_RCUR - TK_SEPARATOR_BASE + 1

.equiv TK_OPERATOR_BASE, TK_SEPARATOR_BASE + NUM_SEPARATORS
.equiv TK_PLUS, TK_OPERATOR_BASE + 0
.equiv TK_MINUS, TK_OPERATOR_BASE + 1
.equiv TK_MULT, TK_OPERATOR_BASE + 2
.equiv TK_DIV, TK_OPERATOR_BASE + 3
.equiv NUM_OPERATORS, TK_DIV - TK_OPERATOR_BASE + 1

# Scanner state.
.struct 0
Scanner:
Scanner.pos: .space XLEN_BYTES
Scanner.end: .space XLEN_BYTES
Scanner.line: .space XLEN_BYTES
Scanner.column: .space XLEN_BYTES
.equiv Scanner_size, . - Scanner
