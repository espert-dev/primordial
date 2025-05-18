# ===========================================================================
# Lexical scanner
# ===========================================================================

# Token types.
.equiv TK_NONE, 0
.equiv TK_BAD_CHAR, 1
.equiv TK_BAD_OPERATOR, 2
.equiv TK_LPAR, 3
.equiv TK_RPAR, 4
.equiv TK_LBRA, 5
.equiv TK_RBRA, 6
.equiv TK_LCUR, 7
.equiv TK_RCUR, 8
.equiv TK_SEMI, 9
.equiv TK_COMMA, 10
.equiv TK_ID, 11
.equiv TK_IF, 12
.equiv TK_FOR, 13
.equiv TK_FUNC, 14
.equiv TK_PLUS, 15
.equiv TK_MINUS, 16
.equiv TK_MULT, 17
.equiv TK_DIV, 18

# Scanner state.
.struct 0
Scanner:
Scanner.pos: .space 8
Scanner.end: .space 8
Scanner.line: .space 8
Scanner.column: .space 8
.equiv Scanner_size, . - Scanner
