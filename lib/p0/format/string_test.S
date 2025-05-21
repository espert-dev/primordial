# ===========================================================================
# String formatting tests - append string to buffer
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
safe_str empty_string, ""

# ===========================================================================
# Test macros
# ===========================================================================

.macro check value, buffer_size, idx, updated_idx, expected
	# Reserve 32 bytes regardless of intended buffer size to mitigate the
	# risk of buffer overruns affecting other test cases.
	.section .bss
	.p2align 3
	.lcomm String_\value\()_\buffer_size\()_\idx\()_buffer_data, 32

	.section .rodata
	.p2align 3
	safe_str String_\value\()_\buffer_size\()_\idx\()_input, "\value"

	.section .rodata
	.p2align 3
	safe_str String_\value\()_\buffer_size\()_\idx\()_expected, "\expected"

	.section .text
	test_case String_\value\()_\buffer_size\()_\idx
		save_4

		# Call function under test.
		li a0, \buffer_size
		la a1, "String_\value\()_\buffer_size\()_\idx\()_buffer_data"
		li a2, \idx
		li a3, "String_\value\()_\buffer_size\()_\idx\()_input_size"
		la a4, "String_\value\()_\buffer_size\()_\idx\()_input_data"
		call "format.String"

		# Check invariants (buffer data pointer and size).
		expect_eqi \buffer_size, a0
		expect_eqa String_\value\()_\buffer_size\()_\idx\()_buffer_data, a1

		# Check that the buffer index has been updated.
		expect_eqi \updated_idx, a2

		# Check that the string representation is as expected.
		li s1, String_\value\()_\buffer_size\()_\idx\()_expected_size
		la s2, String_\value\()_\buffer_size\()_\idx\()_expected_data
		li s3, \updated_idx - \idx
		la s4, String_\value\()_\buffer_size\()_\idx\()_buffer_data + \idx

		mv a0, s1
		mv a1, s2
		mv a2, s3
		mv a3, s4
		call "mem.Eq"
		expect_eqi 1, a0

		ld t0, "testing_state.test_failed"(tp)
		beqz t0, .LString_\value\()_\buffer_size\()_\idx\().end

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

	.LString_\value\()_\buffer_size\()_\idx\().end:
		restore_4
	end_test
.endm


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case String_does_not_write_to_nil_output
	save_0

	li a0, nil_size
	li a1, nil_data
	li a2, 0
	li a3, empty_string_size
	la a4, empty_string_data

	# May fault on failure.
	call "format.String"
	expect_eqi nil_size, a0
	expect_eqi nil_data, a1
	expect_eqi 0, a2

	restore_0
end_test

# Exact size.
check value="", buffer_size=0, idx=0, updated_idx=0, expected=""
check value="a", buffer_size=1, idx=0, updated_idx=1, expected="a"
check value="ab", buffer_size=2, idx=0, updated_idx=2, expected="ab"
check value="abc", buffer_size=3, idx=0, updated_idx=3, expected="abc"
