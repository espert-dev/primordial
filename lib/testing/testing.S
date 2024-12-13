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

#include "millicode.S"
#include "safe_str.S"

# Must be kept in sync with "inc/testing.S"
# Abuse the thread pointer, since p0 is single threaded.
#define failed tp

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
safe_str pass_msg, "[TEST: PASS]\n\n"
safe_str fail_msg, "[TEST: FAIL]\n\n"


# ===========================================================================
# Functions
# ===========================================================================

.section .text

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
	#define failed_backup  s1
	#define test_fn        s2
	#define test_name      s3
	#define test_name_size s4

	# Temporary registers.
	#define failed_ptr        t0
	#define failed_previously t1

	.cfi_startproc
	save_4
	mv failed_backup, failed

	# Preserve arguments and initialise saved variables.
	li failed, 0
	mv test_fn, a0
	mv test_name, a1
	mv test_name_size, a2

	# Print test header.
	li a0, STDLOG
	la a1, test_header_start
	li a2, test_header_start_size
	li a7, SYSCALL_WRITE
	ecall

	# Print test name.
	li a0, STDLOG
	mv a1, test_name
	mv a2, test_name_size
	li a7, SYSCALL_WRITE
	ecall

	# Print new line.
	li a0, STDLOG
	la a1, test_header_end
	li a2, test_header_end_size
	li a7, SYSCALL_WRITE
	ecall

	# Clear the failures.
	li failed, 0

	# Run the test case.
	jalr test_fn

	# a0 now contains the number of failed tests.
	# Accumulate and save the test status.
	la failed_ptr, "testing.failed"
	ld failed_previously, 0(failed_ptr)
	or failed_previously, failed, failed_previously
	sd failed_previously, 0(failed_ptr)

	# Check if the test passed.
	bnez failed, .Lfail

	# Select pass message.
	# a0 and a7 will be set by .end.
	la a1, pass_msg
	li a2, pass_msg_size

	# Fall through.

.Lend:
	li a0, STDLOG
	li a7, SYSCALL_WRITE
	ecall

	restore_4

.Lfail:
	# Select fail message.
	# a0 and a7 will be set by .end.
	la a1, fail_msg
	li a2, fail_msg_size
	j .Lend

	.cfi_endproc


# ===========================================================================
# Global variables
# ===========================================================================

.section .bss

# When a test fails, this variable will be set to 1.
# It will normally be returned as the exit code of the test suite.
.global "testing.failed"
.lcomm "testing.failed", 8

