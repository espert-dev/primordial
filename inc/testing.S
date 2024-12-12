# ===========================================================================
# Testing macros
#
# Note that the register s1 is reserved to store `failed` and the register
# `t6` will be used to implement assertions.
# ===========================================================================

#define failed s1

# ===========================================================================
# Test case macros
# ===========================================================================

# Start a test case definition.
.macro test_case t
.section .rodata
test_\t\()_name:
.ascii "\t"
.equiv test_\t\()_name_size , . - test_\t\()_name

.section .text
test_\t:
	.cfi_startproc
.endm

# End a test case definition.
.macro end_test
	.cfi_endproc
.endm

# Run a test case. Call from within a test suite.
.macro run_test t
	la a0, test_\t
	la a1, test_\t\()_name
	li a2, test_\t\()_name_size
	call run_test
.endm


# ===========================================================================
# Test suite macros
# ===========================================================================

# Start a test suite. Acts as a main function for tests.
.macro test_suite
.global main
main:
	.cfi_startproc
	save_0
.endm

# End a test suite.
.macro end_suite
	# Return 0 if no tests failed, 1 if any did.
	la t0, "testing.failed"
	ld a0, 0(t0)
	snez a0, a0

	restore_0
	.cfi_endproc
.endm


# ===========================================================================
# Assertions
# ===========================================================================

.macro expect_eq expected, actual
	addi t6, \actual, -\expected
	or s1, s1, t6
.endm

.macro expect_ne forbidden, actual
	addi t6, \actual, -\forbidden
	seqz t6, t6
	or s1, s1, t6
.endm

.macro expect_z actual
	or s1, s1, \actual
.endm

.macro expect_nz actual
	seqz t6, \actual
	or s1, s1, t6
.endm

