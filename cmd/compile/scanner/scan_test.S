# ===========================================================================
# Tests for the scanner of the P0 compiler
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>
#include <compile/scanner.S>


# ===========================================================================
# Test macros
# ===========================================================================

.section .text

.macro input_str name, value
.section .rodata
safe_str "\name\()_input", "\value"
.endm

.macro with_input input
	.section .text

	# Make input_size and input_data implicitly available to scan_token.
	# This improves the readability of the tests a bit.
	li s1, "\input\()_size"
        la s2, "\input\()_data"

        # Initialise the scanner.
	mv a0, s1
	mv a1, s2
	call "compile/scanner.Init"
.endm

.macro scan_token type, start, size, line, column
	.section .text
	call "compile/scanner.Scan"
	expect_eqi \type, a0
	expect_eqi \line, a3
	expect_eqi \column, a4

	mv a0, a1
	mv a1, a2
	li a2, \size
	mv a3, s2
	addi a3, a3, \start
	call "mem.Eq"
	expect_nz a0
.endm

.macro scan_eof
	.section .text
	call "compile/scanner.Scan"
	expect_z a0
.endm

.macro scan_test name
.section .text
test_case \name
	.section .text
	.equ _active_input, "\name\()_input"

	# The saved registers store input_size and input_data.
	save_2
	with_input "\name\()_input"
.endm

.macro end_scan
	.section .text
	scan_eof

	# The saved registers store input_size and input_data.
	restore_2
	.equ _active_input, "<undefined>"
end_test
.endm


# ===========================================================================
# Test cases
# ===========================================================================

.equiv nil_input_data, 0
.equiv nil_input_size, 0

scan_test nil
end_scan

input_str empty, ""
scan_test empty
end_scan

input_str whitespace, "\n\t "
scan_test whitespace
end_scan

input_str single_identifier, "foo"
scan_test single_identifier
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
end_scan

input_str comments_stop_at_the_end_of_the_line, "foo # comment\nfoo"
scan_test comments_stop_at_the_end_of_the_line
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
	scan_token type=TK_ID, start=14, size=3, line=2, column=1
end_scan

input_str TK_BAD_CHAR_is_discarded, "foo \xff bar"
scan_test TK_BAD_CHAR_is_discarded
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
	scan_token type=TK_BAD_CHAR, start=4, size=1, line=1, column=5
	scan_token type=TK_ID, start=6, size=3, line=1, column=7
end_scan

input_str if_keyword, "if"
scan_test if_keyword
	scan_token type=TK_IF, start=0, size=2, line=1, column=1
end_scan

input_str for_keyword, "for"
scan_test for_keyword
	scan_token type=TK_FOR, start=0, size=3, line=1, column=1
end_scan

input_str func_keyword, "func"
scan_test func_keyword
	scan_token type=TK_FUNC, start=0, size=4, line=1, column=1
end_scan

input_str lpar_separator, "("
scan_test lpar_separator
	scan_token type=TK_LPAR, start=0, size=1, line=1, column=1
end_scan

input_str rpar_separator, ")"
scan_test rpar_separator
	scan_token type=TK_RPAR, start=0, size=1, line=1, column=1
end_scan

input_str lbra_separator, "["
scan_test lbra_separator
	scan_token type=TK_LBRA, start=0, size=1, line=1, column=1
end_scan

input_str rbra_separator, "]"
scan_test rbra_separator
	scan_token type=TK_RBRA, start=0, size=1, line=1, column=1
end_scan

input_str lcur_separator, "{"
scan_test lcur_separator
	scan_token type=TK_LCUR, start=0, size=1, line=1, column=1
end_scan

input_str rcur_separator, "}"
scan_test rcur_separator
	scan_token type=TK_RCUR, start=0, size=1, line=1, column=1
end_scan

input_str semi_separator, ";"
scan_test semi_separator
	scan_token type=TK_SEMI, start=0, size=1, line=1, column=1
end_scan

input_str comma_separator, ","
scan_test comma_separator
	scan_token type=TK_COMMA, start=0, size=1, line=1, column=1
end_scan

input_str plus_operator, "+"
scan_test plus_operator
	scan_token type=TK_PLUS, start=0, size=1, line=1, column=1
end_scan

input_str minus_operator, "-"
scan_test minus_operator
	scan_token type=TK_MINUS, start=0, size=1, line=1, column=1
end_scan

input_str mult_operator, "*"
scan_test mult_operator
	scan_token type=TK_MULT, start=0, size=1, line=1, column=1
end_scan

input_str div_operator, "/"
scan_test div_operator
	scan_token type=TK_DIV, start=0, size=1, line=1, column=1
end_scan

input_str addition, "x+y"
scan_test addition
	scan_token type=TK_ID, start=0, size=1, line=1, column=1
	scan_token type=TK_PLUS, start=1, size=1, line=1, column=2
	scan_token type=TK_ID, start=2, size=1, line=1, column=3
end_scan
