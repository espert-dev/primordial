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
safe_str \name\()_input, "\value"
.endm

.macro with_input input
	.section .text
	la a0, \input\()_data
	li a1, \input\()_size
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
	la a2, \start
	li a3, \size
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
	.equ _active_input, \name\()_input
	save_0
	with_input \name\()_input
.endm

.macro end_scan
	.section .text
	scan_eof
	restore_0
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
	scan_token TK_ID, single_identifier_input_data, 3, 1, 1
end_scan

input_str comments_stop_at_the_end_of_the_line, "foo # comment\nfoo"
scan_test comments_stop_at_the_end_of_the_line
	scan_token TK_ID, comments_stop_at_the_end_of_the_line_input_data, 3, 1, 1
	scan_token TK_ID, comments_stop_at_the_end_of_the_line_input_data + 14, 3, 2, 1
end_scan

input_str TK_BAD_CHAR_is_discarded, "foo \xff bar"
scan_test TK_BAD_CHAR_is_discarded
	scan_token TK_ID, TK_BAD_CHAR_is_discarded_input_data, 3, 1, 1
	scan_token TK_BAD_CHAR, TK_BAD_CHAR_is_discarded_input_data + 4, 1, 1, 5
	scan_token TK_ID, TK_BAD_CHAR_is_discarded_input_data + 6, 3, 1, 7
end_scan

input_str if_keyword, "if"
scan_test if_keyword
	scan_token TK_IF, if_keyword_input_data, 2, 1, 1
end_scan

input_str for_keyword, "for"
scan_test for_keyword
	scan_token TK_FOR, for_keyword_input_data, 3, 1, 1
end_scan

input_str func_keyword, "func"
scan_test func_keyword
	scan_token TK_FUNC, func_keyword_input_data, 4, 1, 1
end_scan

input_str lpar_separator, "("
scan_test lpar_separator
	scan_token TK_LPAR, lpar_separator_input_data, 1, 1, 1
end_scan

input_str rpar_separator, ")"
scan_test rpar_separator
	scan_token TK_RPAR, rpar_separator_input_data, 1, 1, 1
end_scan

input_str lbra_separator, "["
scan_test lbra_separator
	scan_token TK_LBRA, lbra_separator_input_data, 1, 1, 1
end_scan

input_str rbra_separator, "]"
scan_test rbra_separator
	scan_token TK_RBRA, rbra_separator_input_data, 1, 1, 1
end_scan

input_str lcur_separator, "{"
scan_test lcur_separator
	scan_token TK_LCUR, lcur_separator_input_data, 1, 1, 1
end_scan

input_str rcur_separator, "}"
scan_test rcur_separator
	scan_token TK_RCUR, rcur_separator_input_data, 1, 1, 1
end_scan

input_str semi_separator, ";"
scan_test semi_separator
	scan_token TK_SEMI, semi_separator_input_data, 1, 1, 1
end_scan

input_str comma_separator, ","
scan_test comma_separator
	scan_token TK_COMMA, comma_separator_input_data, 1, 1, 1
end_scan

input_str plus_operator, "+"
scan_test plus_operator
	scan_token TK_PLUS, plus_operator_input_data, 1, 1, 1
end_scan

input_str minus_operator, "-"
scan_test minus_operator
	scan_token TK_MINUS, minus_operator_input_data, 1, 1, 1
end_scan

input_str mult_operator, "*"
scan_test mult_operator
	scan_token TK_MULT, mult_operator_input_data, 1, 1, 1
end_scan

input_str div_operator, "/"
scan_test div_operator
	scan_token TK_DIV, div_operator_input_data, 1, 1, 1
end_scan

input_str addition, "x+y"
scan_test addition
	scan_token TK_ID, addition_input_data, 1, 1, 1
	scan_token TK_PLUS, addition_input_data + 1, 1, 1, 2
	scan_token TK_ID, addition_input_data + 2, 1, 1, 3
end_scan
