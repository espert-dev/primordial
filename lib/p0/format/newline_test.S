# ===========================================================================
# Space formatting tests - append a number of spaces to a buffer
# ===========================================================================

#include <compat.S>
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

.macro check repeats, buffer_size, idx, updated_idx, expected
	# Reserve 32 bytes regardless of intended buffer size to mitigate the
	# risk of buffer overruns affecting other test cases.
	.section .bss
	Xalign
	.lcomm "NewLine_\repeats\()_\buffer_size\()_\idx\()_buffer_data", 32

	.section .rodata
	Xalign
	safe_str NewLine_\repeats\()_\buffer_size\()_\idx\()_expected, "\expected"

	.section .text
	test_case "NewLine_\repeats\()_\buffer_size\()_\idx"
		save_4

		# Call function under test.
		li a0, \buffer_size
		la a1, "NewLine_\repeats\()_\buffer_size\()_\idx\()_buffer_data"
		li a2, \idx
		li a3, \repeats
		call "format.NewLine"

		# Check invariants (buffer data pointer and size).
		expect_eqi \buffer_size, a0
		expect_eqa "NewLine_\repeats\()_\buffer_size\()_\idx\()_buffer_data", a1

		# Check that the buffer index has been updated.
		expect_eqi \updated_idx, a2

		# Check that the string representation is as expected.
		li s1, "NewLine_\repeats\()_\buffer_size\()_\idx\()_expected_size"
		la s2, "NewLine_\repeats\()_\buffer_size\()_\idx\()_expected_data"
		li s3, \updated_idx - \idx
		la s4, "NewLine_\repeats\()_\buffer_size\()_\idx\()_buffer_data" + \idx

		mv a0, s1
		mv a1, s2
		mv a2, s3
		mv a3, s4
		call "mem.Eq"
		expect_eqi 1, a0

		lx t0, "testing_state.test_failed"(tp)
		beqz t0, ".LNewLine_\repeats\()_\buffer_size\()_\idx\().end"

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

	.LNewLine_\repeats\()_\buffer_size\()_\idx\().end:
		restore_4
	end_test
.endm


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case NewLine_does_not_write_to_nil_output
	save_0

	li a0, nil_size
	li a1, nil_data
	li a2, 0
	li a3, empty_string_size
	la a4, empty_string_data

	# May fault on failure.
	call "format.NewLine"
	expect_eqi nil_size, a0
	expect_eqi nil_data, a1
	expect_eqi 0, a2

	restore_0
end_test

# Exact size.
check repeats=0, buffer_size=0, idx=0, updated_idx=0, expected=""
check repeats=0, buffer_size=1, idx=0, updated_idx=0, expected=""
check repeats=1, buffer_size=1, idx=0, updated_idx=1, expected="\n"
check repeats=2, buffer_size=2, idx=0, updated_idx=2, expected="\n\n"
check repeats=3, buffer_size=3, idx=0, updated_idx=3, expected="\n\n\n"

# Truncated by 1.
check repeats=1, buffer_size=0, idx=0, updated_idx=0, expected=""
check repeats=2, buffer_size=1, idx=0, updated_idx=1, expected="\n"
check repeats=3, buffer_size=2, idx=0, updated_idx=2, expected="\n\n"
check repeats=4, buffer_size=3, idx=0, updated_idx=3, expected="\n\n\n"
check repeats=5, buffer_size=4, idx=0, updated_idx=4, expected="\n\n\n\n"

# Truncated by 2.
check repeats=2, buffer_size=0, idx=0, updated_idx=0, expected=""
check repeats=3, buffer_size=1, idx=0, updated_idx=1, expected="\n"
check repeats=4, buffer_size=2, idx=0, updated_idx=2, expected="\n\n"
check repeats=5, buffer_size=3, idx=0, updated_idx=3, expected="\n\n\n"
check repeats=6, buffer_size=4, idx=0, updated_idx=4, expected="\n\n\n\n"

# Exact size, offset 1.
check repeats=0, buffer_size=1, idx=1, updated_idx=1, expected=""
check repeats=0, buffer_size=2, idx=1, updated_idx=1, expected=""
check repeats=1, buffer_size=2, idx=1, updated_idx=2, expected="\n"
check repeats=2, buffer_size=3, idx=1, updated_idx=3, expected="\n\n"
check repeats=3, buffer_size=4, idx=1, updated_idx=4, expected="\n\n\n"

# Exact size, offset 2.
check repeats=0, buffer_size=2, idx=2, updated_idx=2, expected=""
check repeats=0, buffer_size=3, idx=2, updated_idx=2, expected=""
check repeats=1, buffer_size=3, idx=2, updated_idx=3, expected="\n"
check repeats=2, buffer_size=4, idx=2, updated_idx=4, expected="\n\n"
check repeats=3, buffer_size=5, idx=2, updated_idx=5, expected="\n\n\n"

# Truncated by 1, offset 1.
check repeats=1, buffer_size=1, idx=1, updated_idx=1, expected=""
check repeats=2, buffer_size=2, idx=1, updated_idx=2, expected="\n"
check repeats=3, buffer_size=3, idx=1, updated_idx=3, expected="\n\n"
check repeats=4, buffer_size=4, idx=1, updated_idx=4, expected="\n\n\n"
check repeats=5, buffer_size=5, idx=1, updated_idx=5, expected="\n\n\n\n"

# Truncated by 1, offset 2.
check repeats=1, buffer_size=2, idx=2, updated_idx=2, expected=""
check repeats=2, buffer_size=3, idx=2, updated_idx=3, expected="\n"
check repeats=3, buffer_size=4, idx=2, updated_idx=4, expected="\n\n"
check repeats=4, buffer_size=5, idx=2, updated_idx=5, expected="\n\n\n"
check repeats=5, buffer_size=6, idx=2, updated_idx=6, expected="\n\n\n\n"
