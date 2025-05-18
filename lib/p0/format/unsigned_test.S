# ===========================================================================
# String formatting tests - Unsigned
# ===========================================================================

#include <io.S>
#include <millicode.S>
#include <safe_str.S>
#include <testing.S>



# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

# An attempt to write here will fault.
.equiv nil_data, 0
.equiv nil_size, 0

safe_str expected_label, "Expected:  "
safe_str actual_label,   "Actual:    "
safe_str quote_start, "\""
safe_str quote_end, "\"\n"


# ===========================================================================
# Test macros
# ===========================================================================

.macro check value, buffer_size, idx, updated_idx, expected
	# Reserve 32 bytes regardless of intended buffer size to mitigate the
	# risk of buffer overruns affecting other test cases.
	.section .bss
	.p2align 3
	.lcomm Unsigned_\value\()_\buffer_size\()_\idx\()_buffer_data, 32

	.section .rodata
	.p2align 3
	safe_str Unsigned_\value\()_\buffer_size\()_\idx\()_expected, "\expected"

	.section .text
	test_case Unsigned_\value\()_\buffer_size\()_\idx
		save_4

		# Call function under test.
		la a0, \buffer_size
		la a1, Unsigned_\value\()_\buffer_size\()_\idx\()_buffer_data
		li a2, \idx
		li a3, \value
		call "format.Unsigned"

		# Check invariants (buffer data pointer and size).
		expect_eqi \buffer_size, a0
		expect_eqa Unsigned_\value\()_\buffer_size\()_\idx\()_buffer_data, a1

		# Check that the buffer index has been updated.
		expect_eqi \updated_idx, a2

		# Check that the string representation is as expected.
		li s1, Unsigned_\value\()_\buffer_size\()_\idx\()_expected_size
		la s2, Unsigned_\value\()_\buffer_size\()_\idx\()_expected_data
		li s3, \updated_idx - \idx
		la s4, Unsigned_\value\()_\buffer_size\()_\idx\()_buffer_data + \idx

		mv a0, s1
		mv a1, s2
		mv a2, s3
		mv a3, s4
		call "mem.Eq"
		expect_eqi 1, a0

		ld t0, "testing_state.test_failed"(tp)
		beqz t0, .LUnsigned_\value\()_\buffer_size\()_\idx\().end

		li a0, STDLOG
		li a1, expected_label_size
		la a2, expected_label_data
		call "io.Write"

		li a0, STDLOG
		li a1, quote_start_size
		la a2, quote_start_data
		call "io.Write"

		li a0, STDLOG
		mv a1, s1
		mv a2, s2
		call "io.Write"

		li a0, STDLOG
		li a1, quote_end_size
		la a2, quote_end_data
		call "io.Write"

		li a0, STDLOG
		li a1, actual_label_size
		la a2, actual_label_data
		call "io.Write"

		li a0, STDLOG
		li a1, quote_start_size
		la a2, quote_start_data
		call "io.Write"

		li a0, STDLOG
		mv a1, s3
		mv a2, s4
		call "io.Write"

		li a0, STDLOG
		li a1, quote_end_size
		la a2, quote_end_data
		call "io.Write"

	.LUnsigned_\value\()_\buffer_size\()_\idx\().end:
		restore_4
	end_test
.endm


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Unsigned_does_not_write_to_nil_output
	save_0

	li a0, nil_size
	li a1, nil_data
	li a2, 0
	li a3, 0

	# May fault on failure.
	call "format.Unsigned"
	expect_eqi nil_size, a0
	expect_eqi nil_data, a1
	expect_eqi 0, a2

	restore_0
end_test

# Test all single digits (no space).
check value=0, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=1, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=2, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=3, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=4, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=5, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=6, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=7, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=8, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=9, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test all single digits (exact space).
check value=0, buffer_size=1, idx=0, updated_idx=1, expected="0"
check value=1, buffer_size=1, idx=0, updated_idx=1, expected="1"
check value=2, buffer_size=1, idx=0, updated_idx=1, expected="2"
check value=3, buffer_size=1, idx=0, updated_idx=1, expected="3"
check value=4, buffer_size=1, idx=0, updated_idx=1, expected="4"
check value=5, buffer_size=1, idx=0, updated_idx=1, expected="5"
check value=6, buffer_size=1, idx=0, updated_idx=1, expected="6"
check value=7, buffer_size=1, idx=0, updated_idx=1, expected="7"
check value=8, buffer_size=1, idx=0, updated_idx=1, expected="8"
check value=9, buffer_size=1, idx=0, updated_idx=1, expected="9"

# Test all single digits (extra space).
check value=0, buffer_size=2, idx=0, updated_idx=1, expected="0"
check value=1, buffer_size=2, idx=0, updated_idx=1, expected="1"
check value=2, buffer_size=2, idx=0, updated_idx=1, expected="2"
check value=3, buffer_size=2, idx=0, updated_idx=1, expected="3"
check value=4, buffer_size=2, idx=0, updated_idx=1, expected="4"
check value=5, buffer_size=2, idx=0, updated_idx=1, expected="5"
check value=6, buffer_size=2, idx=0, updated_idx=1, expected="6"
check value=7, buffer_size=2, idx=0, updated_idx=1, expected="7"
check value=8, buffer_size=2, idx=0, updated_idx=1, expected="8"
check value=9, buffer_size=2, idx=0, updated_idx=1, expected="9"

# Test all single digits (offset 1).
check value=0, buffer_size=2, idx=1, updated_idx=2, expected="0"
check value=1, buffer_size=2, idx=1, updated_idx=2, expected="1"
check value=2, buffer_size=2, idx=1, updated_idx=2, expected="2"
check value=3, buffer_size=2, idx=1, updated_idx=2, expected="3"
check value=4, buffer_size=2, idx=1, updated_idx=2, expected="4"
check value=5, buffer_size=2, idx=1, updated_idx=2, expected="5"
check value=6, buffer_size=2, idx=1, updated_idx=2, expected="6"
check value=7, buffer_size=2, idx=1, updated_idx=2, expected="7"
check value=8, buffer_size=2, idx=1, updated_idx=2, expected="8"
check value=9, buffer_size=2, idx=1, updated_idx=2, expected="9"
