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
.equiv TK_PERIOD, 11
.equiv TK_ID, 12
.equiv TK_IF, 13
.equiv TK_FOR, 14
.equiv TK_FUNC, 15
.equiv TK_PLUS, 16
.equiv TK_MINUS, 17
.equiv TK_MULT, 18
.equiv TK_DIV, 19

# Scanner state.
.struct 0
Scanner:
Scanner.pos: .space XLEN_BYTES
Scanner.end: .space XLEN_BYTES
Scanner.line: .space XLEN_BYTES
Scanner.column: .space XLEN_BYTES
.equiv Scanner_size, . - Scanner
