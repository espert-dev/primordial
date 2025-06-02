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

.macro scan_test name, input
.section .text
test_case \name
	.section .rodata
	safe_str "\name\()_input", "\input"

	.section .text

	# The saved registers store input_size and input_data.
	save_2

	# Make input_size and input_data implicitly available to scan_token.
	# This improves the readability of the tests a bit.
	li s1, "\name\()_input_size"
        la s2, "\name\()_input_data"

        # Initialise the scanner.
	mv a0, s1
	mv a1, s2
	call "compile/scanner.Init"
.endm

.macro end_scan
	.section .text
	scan_eof

	# The saved registers store input_size and input_data.
	restore_2
end_test
.endm


# ===========================================================================
# Test cases
# ===========================================================================

.equiv nil_input_data, 0
.equiv nil_input_size, 0

# This test is different to the rest because it doesn't use an input.
test_case scan_nil
	save_0

	# Initialise scanner.
	li a0, 0
	li a1, 0
	call "compile/scanner.Init"

	# No tokens are found in the nil input.
	scan_eof

	restore_0
end_test

scan_test empty, ""
end_scan

scan_test whitespace, "\n\t "
end_scan

scan_test single_identifier, "foo"
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
end_scan

scan_test comments_stop_at_the_end_of_the_line, "foo # comment\nfoo"
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
	scan_token type=TK_ID, start=14, size=3, line=2, column=1
end_scan

scan_test TK_BAD_CHAR_is_discarded, "foo \xff bar"
	scan_token type=TK_ID, start=0, size=3, line=1, column=1
	scan_token type=TK_BAD_CHAR, start=4, size=1, line=1, column=5
	scan_token type=TK_ID, start=6, size=3, line=1, column=7
end_scan

scan_test if_keyword, "if"
	scan_token type=TK_IF, start=0, size=2, line=1, column=1
end_scan

scan_test for_keyword, "for"
	scan_token type=TK_FOR, start=0, size=3, line=1, column=1
end_scan

scan_test func_keyword, "func"
	scan_token type=TK_FUNC, start=0, size=4, line=1, column=1
end_scan

scan_test lpar_separator, "("
	scan_token type=TK_LPAR, start=0, size=1, line=1, column=1
end_scan

scan_test rpar_separator, ")"
	scan_token type=TK_RPAR, start=0, size=1, line=1, column=1
end_scan

scan_test lbra_separator, "["
	scan_token type=TK_LBRA, start=0, size=1, line=1, column=1
end_scan

scan_test rbra_separator, "]"
	scan_token type=TK_RBRA, start=0, size=1, line=1, column=1
end_scan

scan_test lcur_separator, "{"
	scan_token type=TK_LCUR, start=0, size=1, line=1, column=1
end_scan

scan_test rcur_separator, "}"
	scan_token type=TK_RCUR, start=0, size=1, line=1, column=1
end_scan

scan_test semi_separator, ";"
	scan_token type=TK_SEMI, start=0, size=1, line=1, column=1
end_scan

scan_test comma_separator, ","
	scan_token type=TK_COMMA, start=0, size=1, line=1, column=1
end_scan

scan_test plus_operator, "+"
	scan_token type=TK_PLUS, start=0, size=1, line=1, column=1
end_scan

scan_test minus_operator, "-"
	scan_token type=TK_MINUS, start=0, size=1, line=1, column=1
end_scan

scan_test mult_operator, "*"
	scan_token type=TK_MULT, start=0, size=1, line=1, column=1
end_scan

scan_test div_operator, "/"
	scan_token type=TK_DIV, start=0, size=1, line=1, column=1
end_scan

scan_test addition, "x+y"
	scan_token type=TK_ID, start=0, size=1, line=1, column=1
	scan_token type=TK_PLUS, start=1, size=1, line=1, column=2
	scan_token type=TK_ID, start=2, size=1, line=1, column=3
end_scan
