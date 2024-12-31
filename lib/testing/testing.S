# ===========================================================================
# Test runner for arm64/linux
# ===========================================================================

# ===========================================================================
# Design
#
# This program runs test suites for assembly functions, including the
# standard library. In order to minimise the risk of jeopardising the
# correctness of the test runner by having it rely on the libraries
# that it is testing, we have written it with no external dependencies.
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>

# Standard IO.
.equiv STDIN,  0
.equiv STDOUT, 1
.equiv STDLOG, 2

# Syscalls.
.equiv SYSCALL_WRITE, 64


# ===========================================================================
# Data
# ===========================================================================

.section .rodata

safe_str test_header_start, "[TEST: "
safe_str test_header_end, "]\n"
safe_str pass_header, "[PASS: "
safe_str fail_header, "[FAIL: "
safe_str test_result_trailer, "]\n\n"


# ===========================================================================
# Functions
# ===========================================================================

.section .text

# Test main. Runs the test cases.
.global main
main:
	# Callee-saved registers.
	#define next s1
	#define end  s2

	.cfi_startproc
	save_2

	# We will appropriate the thread pointer as the "test pointer".
	la tp, "testing.state"

	# Load the test information from the custom .test_cases section.
	la next, __start_test_cases
	la end, __end_test_cases

	j .Lmain.loop_cond

.Lmain.loop:
	ld a0, "test_case_entry.fn"(next)
	ld a1, "test_case_entry.name"(next)
	ld a2, "test_case_entry.name_size"(next)
	call run_test

	addi next, next, test_case_entry_size

.Lmain.loop_cond:
	bltu next, end, .Lmain.loop

	# Return 0 if no tests failed, 1 if any did.
	ld a0, "testing_state.suite_failed"(tp)

	restore_2
	.cfi_endproc


# Runs a test case.
#
# Input:
#   * a0: test function
#   * a1: test name
#   * a2: test name size
#
# Output:
#   * a0: 0 if OK, nonzero if not OK
.global run_test
run_test:
	# Callee-saved registers.
	#define test_fn        s1
	#define test_name_data s2
	#define test_name_size s3

	# Temporary registers.
	#define test_failed  t0
	#define suite_failed t1

	.cfi_startproc
	save_3

	# Preserve arguments and initialise saved variables.
	mv test_fn, a0
	mv test_name_data, a1
	mv test_name_size, a2

	# Print test header.
	li a0, STDLOG
	la a1, test_header_start_data
	li a2, test_header_start_size
	li a7, SYSCALL_WRITE
	ecall

	# Print test name.
	li a0, STDLOG
	mv a1, test_name_data
	mv a2, test_name_size
	li a7, SYSCALL_WRITE
	ecall

	# Print new line.
	li a0, STDLOG
	la a1, test_header_end_data
	li a2, test_header_end_size
	li a7, SYSCALL_WRITE
	ecall

	# Clear the failed state.
	sd zero, "testing_state.test_failed"(tp)

	# Run the test case.
	jalr test_fn

	# Accumulate test case failures into test suite failures.
	ld test_failed, "testing_state.test_failed"(tp)
	ld suite_failed, "testing_state.suite_failed"(tp)
	or suite_failed, suite_failed, test_failed
	sd suite_failed, "testing_state.suite_failed"(tp)

	# Check if the test passed.
	bnez test_failed, .Lfail

	# Show pass message.
	li a0, STDLOG
	la a1, pass_header_data
	li a2, pass_header_size
	li a7, SYSCALL_WRITE
	ecall

	# Fall through.

.Lend:
	li a0, STDLOG
	mv a1, test_name_data
	mv a2, test_name_size
	li a7, SYSCALL_WRITE
	ecall

	li a0, STDLOG
	la a1, test_result_trailer_data
	li a2, test_result_trailer_size
	li a7, SYSCALL_WRITE
	ecall

	restore_3

.Lfail:
	# Show fail message.
	li a0, STDLOG
	la a1, fail_header_data
	li a2, fail_header_size
	li a7, SYSCALL_WRITE
	ecall

	j .Lend

	.cfi_endproc


# ===========================================================================
# Global variables
# ===========================================================================

.section .bss

# When a test fails, this variable will be set to 1.
# It will normally be returned as the exit code of the test suite.
.global "testing.state"
.lcomm "testing.state", testing_state_size

