# ===========================================================================
# String formatting tests - Unsigned integer
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


# ===========================================================================
# Test macros
# ===========================================================================

.macro check value, buffer_size, idx, updated_idx, expected
	# Reserve 32 bytes regardless of intended buffer size to mitigate the
	# risk of buffer overruns affecting other test cases.
	.section .bss
	Xalign
	.lcomm Unsigned_\value\()_\buffer_size\()_\idx\()_buffer_data, 32

	.section .rodata
	Xalign
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

		lx t0, "testing_state.test_failed"(tp)
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

# Test 2 digits (no space).
check value=10, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=19, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=20, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=29, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=30, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=39, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=40, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=49, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=50, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=59, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=60, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=69, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=70, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=79, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=80, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=89, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=90, buffer_size=0, idx=0, updated_idx=0, expected=""
check value=99, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test 2 digits (truncated).
check value=10, buffer_size=1, idx=0, updated_idx=1, expected="1"
check value=19, buffer_size=1, idx=0, updated_idx=1, expected="1"
check value=20, buffer_size=1, idx=0, updated_idx=1, expected="2"
check value=29, buffer_size=1, idx=0, updated_idx=1, expected="2"
check value=30, buffer_size=1, idx=0, updated_idx=1, expected="3"
check value=39, buffer_size=1, idx=0, updated_idx=1, expected="3"
check value=40, buffer_size=1, idx=0, updated_idx=1, expected="4"
check value=49, buffer_size=1, idx=0, updated_idx=1, expected="4"
check value=50, buffer_size=1, idx=0, updated_idx=1, expected="5"
check value=59, buffer_size=1, idx=0, updated_idx=1, expected="5"
check value=60, buffer_size=1, idx=0, updated_idx=1, expected="6"
check value=69, buffer_size=1, idx=0, updated_idx=1, expected="6"
check value=70, buffer_size=1, idx=0, updated_idx=1, expected="7"
check value=79, buffer_size=1, idx=0, updated_idx=1, expected="7"
check value=80, buffer_size=1, idx=0, updated_idx=1, expected="8"
check value=89, buffer_size=1, idx=0, updated_idx=1, expected="8"
check value=90, buffer_size=1, idx=0, updated_idx=1, expected="9"
check value=99, buffer_size=1, idx=0, updated_idx=1, expected="9"

# Test 2 digits (exact space).
check value=10, buffer_size=2, idx=0, updated_idx=2, expected="10"
check value=19, buffer_size=2, idx=0, updated_idx=2, expected="19"
check value=20, buffer_size=2, idx=0, updated_idx=2, expected="20"
check value=29, buffer_size=2, idx=0, updated_idx=2, expected="29"
check value=30, buffer_size=2, idx=0, updated_idx=2, expected="30"
check value=39, buffer_size=2, idx=0, updated_idx=2, expected="39"
check value=40, buffer_size=2, idx=0, updated_idx=2, expected="40"
check value=49, buffer_size=2, idx=0, updated_idx=2, expected="49"
check value=50, buffer_size=2, idx=0, updated_idx=2, expected="50"
check value=59, buffer_size=2, idx=0, updated_idx=2, expected="59"
check value=60, buffer_size=2, idx=0, updated_idx=2, expected="60"
check value=69, buffer_size=2, idx=0, updated_idx=2, expected="69"
check value=70, buffer_size=2, idx=0, updated_idx=2, expected="70"
check value=79, buffer_size=2, idx=0, updated_idx=2, expected="79"
check value=80, buffer_size=2, idx=0, updated_idx=2, expected="80"
check value=89, buffer_size=2, idx=0, updated_idx=2, expected="89"
check value=90, buffer_size=2, idx=0, updated_idx=2, expected="90"
check value=99, buffer_size=2, idx=0, updated_idx=2, expected="99"

# Test 2 digits (extra space).
check value=10, buffer_size=3, idx=0, updated_idx=2, expected="10"
check value=19, buffer_size=3, idx=0, updated_idx=2, expected="19"
check value=20, buffer_size=3, idx=0, updated_idx=2, expected="20"
check value=29, buffer_size=3, idx=0, updated_idx=2, expected="29"
check value=30, buffer_size=3, idx=0, updated_idx=2, expected="30"
check value=39, buffer_size=3, idx=0, updated_idx=2, expected="39"
check value=40, buffer_size=3, idx=0, updated_idx=2, expected="40"
check value=49, buffer_size=3, idx=0, updated_idx=2, expected="49"
check value=50, buffer_size=3, idx=0, updated_idx=2, expected="50"
check value=59, buffer_size=3, idx=0, updated_idx=2, expected="59"
check value=60, buffer_size=3, idx=0, updated_idx=2, expected="60"
check value=69, buffer_size=3, idx=0, updated_idx=2, expected="69"
check value=70, buffer_size=3, idx=0, updated_idx=2, expected="70"
check value=79, buffer_size=3, idx=0, updated_idx=2, expected="79"
check value=80, buffer_size=3, idx=0, updated_idx=2, expected="80"
check value=89, buffer_size=3, idx=0, updated_idx=2, expected="89"
check value=90, buffer_size=3, idx=0, updated_idx=2, expected="90"
check value=99, buffer_size=3, idx=0, updated_idx=2, expected="99"

# Test 2 digits (offset 1).
check value=10, buffer_size=3, idx=1, updated_idx=3, expected="10"
check value=19, buffer_size=3, idx=1, updated_idx=3, expected="19"
check value=20, buffer_size=3, idx=1, updated_idx=3, expected="20"
check value=29, buffer_size=3, idx=1, updated_idx=3, expected="29"
check value=30, buffer_size=3, idx=1, updated_idx=3, expected="30"
check value=39, buffer_size=3, idx=1, updated_idx=3, expected="39"
check value=40, buffer_size=3, idx=1, updated_idx=3, expected="40"
check value=49, buffer_size=3, idx=1, updated_idx=3, expected="49"
check value=50, buffer_size=3, idx=1, updated_idx=3, expected="50"
check value=59, buffer_size=3, idx=1, updated_idx=3, expected="59"
check value=60, buffer_size=3, idx=1, updated_idx=3, expected="60"
check value=69, buffer_size=3, idx=1, updated_idx=3, expected="69"
check value=70, buffer_size=3, idx=1, updated_idx=3, expected="70"
check value=79, buffer_size=3, idx=1, updated_idx=3, expected="79"
check value=80, buffer_size=3, idx=1, updated_idx=3, expected="80"
check value=89, buffer_size=3, idx=1, updated_idx=3, expected="89"
check value=90, buffer_size=3, idx=1, updated_idx=3, expected="90"
check value=99, buffer_size=3, idx=1, updated_idx=3, expected="99"

# Test 3 digits (exact space).
check value=150, buffer_size=3, idx=0, updated_idx=3, expected="150"
check value=159, buffer_size=3, idx=0, updated_idx=3, expected="159"
check value=250, buffer_size=3, idx=0, updated_idx=3, expected="250"
check value=259, buffer_size=3, idx=0, updated_idx=3, expected="259"
check value=350, buffer_size=3, idx=0, updated_idx=3, expected="350"
check value=359, buffer_size=3, idx=0, updated_idx=3, expected="359"
check value=450, buffer_size=3, idx=0, updated_idx=3, expected="450"
check value=459, buffer_size=3, idx=0, updated_idx=3, expected="459"
check value=550, buffer_size=3, idx=0, updated_idx=3, expected="550"
check value=559, buffer_size=3, idx=0, updated_idx=3, expected="559"
check value=650, buffer_size=3, idx=0, updated_idx=3, expected="650"
check value=659, buffer_size=3, idx=0, updated_idx=3, expected="659"
check value=750, buffer_size=3, idx=0, updated_idx=3, expected="750"
check value=759, buffer_size=3, idx=0, updated_idx=3, expected="759"
check value=850, buffer_size=3, idx=0, updated_idx=3, expected="850"
check value=859, buffer_size=3, idx=0, updated_idx=3, expected="859"
check value=950, buffer_size=3, idx=0, updated_idx=3, expected="950"
check value=959, buffer_size=3, idx=0, updated_idx=3, expected="959"

# Maximum value in 32-bit (exact space).
check value=4294967295, buffer_size=10, idx=0, updated_idx=10, expected="4294967295"

# Maximum value in 32-bit (truncated).
check value=4294967295, buffer_size=9, idx=0, updated_idx=9, expected="429496729"
check value=4294967295, buffer_size=8, idx=0, updated_idx=8, expected="42949672"
check value=4294967295, buffer_size=7, idx=0, updated_idx=7, expected="4294967"
check value=4294967295, buffer_size=6, idx=0, updated_idx=6, expected="429496"
check value=4294967295, buffer_size=5, idx=0, updated_idx=5, expected="42949"
check value=4294967295, buffer_size=4, idx=0, updated_idx=4, expected="4294"
check value=4294967295, buffer_size=3, idx=0, updated_idx=3, expected="429"
check value=4294967295, buffer_size=2, idx=0, updated_idx=2, expected="42"
check value=4294967295, buffer_size=1, idx=0, updated_idx=1, expected="4"
check value=4294967295, buffer_size=0, idx=0, updated_idx=0, expected=""

# Maximum value in 32-bit (offset, truncation in all but first).
check value=4294967295, buffer_size=11, idx=1, updated_idx=11, expected="4294967295"
check value=4294967295, buffer_size=10, idx=1, updated_idx=10, expected="429496729"
check value=4294967295, buffer_size=9, idx=1, updated_idx=9, expected="42949672"
check value=4294967295, buffer_size=8, idx=1, updated_idx=8, expected="4294967"
check value=4294967295, buffer_size=7, idx=1, updated_idx=7, expected="429496"
check value=4294967295, buffer_size=6, idx=1, updated_idx=6, expected="42949"
check value=4294967295, buffer_size=5, idx=1, updated_idx=5, expected="4294"
check value=4294967295, buffer_size=4, idx=1, updated_idx=4, expected="429"
check value=4294967295, buffer_size=3, idx=1, updated_idx=3, expected="42"
check value=4294967295, buffer_size=2, idx=1, updated_idx=2, expected="4"
check value=4294967295, buffer_size=1, idx=1, updated_idx=1, expected=""

#if XLEN >= 64

# Maximum value in 64-bit (exact space).
check value=18446744073709551615, buffer_size=20, idx=0, updated_idx=20, expected="18446744073709551615"

# Maximum value in 64-bit (truncated).
check value=18446744073709551615, buffer_size=19, idx=0, updated_idx=19, expected="1844674407370955161"
check value=18446744073709551615, buffer_size=18, idx=0, updated_idx=18, expected="184467440737095516"
check value=18446744073709551615, buffer_size=17, idx=0, updated_idx=17, expected="18446744073709551"
check value=18446744073709551615, buffer_size=16, idx=0, updated_idx=16, expected="1844674407370955"
check value=18446744073709551615, buffer_size=15, idx=0, updated_idx=15, expected="184467440737095"
check value=18446744073709551615, buffer_size=14, idx=0, updated_idx=14, expected="18446744073709"
check value=18446744073709551615, buffer_size=13, idx=0, updated_idx=13, expected="1844674407370"
check value=18446744073709551615, buffer_size=12, idx=0, updated_idx=12, expected="184467440737"
check value=18446744073709551615, buffer_size=11, idx=0, updated_idx=11, expected="18446744073"
check value=18446744073709551615, buffer_size=10, idx=0, updated_idx=10, expected="1844674407"
check value=18446744073709551615, buffer_size=9, idx=0, updated_idx=9, expected="184467440"
check value=18446744073709551615, buffer_size=8, idx=0, updated_idx=8, expected="18446744"
check value=18446744073709551615, buffer_size=7, idx=0, updated_idx=7, expected="1844674"
check value=18446744073709551615, buffer_size=6, idx=0, updated_idx=6, expected="184467"
check value=18446744073709551615, buffer_size=5, idx=0, updated_idx=5, expected="18446"
check value=18446744073709551615, buffer_size=4, idx=0, updated_idx=4, expected="1844"
check value=18446744073709551615, buffer_size=3, idx=0, updated_idx=3, expected="184"
check value=18446744073709551615, buffer_size=2, idx=0, updated_idx=2, expected="18"
check value=18446744073709551615, buffer_size=1, idx=0, updated_idx=1, expected="1"
check value=18446744073709551615, buffer_size=0, idx=0, updated_idx=0, expected=""

# Maximum value in 64-bit (offset, truncation in all but first).
check value=18446744073709551615, buffer_size=21, idx=1, updated_idx=21, expected="18446744073709551615"
check value=18446744073709551615, buffer_size=20, idx=1, updated_idx=20, expected="1844674407370955161"
check value=18446744073709551615, buffer_size=19, idx=1, updated_idx=19, expected="184467440737095516"
check value=18446744073709551615, buffer_size=18, idx=1, updated_idx=18, expected="18446744073709551"
check value=18446744073709551615, buffer_size=17, idx=1, updated_idx=17, expected="1844674407370955"
check value=18446744073709551615, buffer_size=16, idx=1, updated_idx=16, expected="184467440737095"
check value=18446744073709551615, buffer_size=15, idx=1, updated_idx=15, expected="18446744073709"
check value=18446744073709551615, buffer_size=14, idx=1, updated_idx=14, expected="1844674407370"
check value=18446744073709551615, buffer_size=13, idx=1, updated_idx=13, expected="184467440737"
check value=18446744073709551615, buffer_size=12, idx=1, updated_idx=12, expected="18446744073"
check value=18446744073709551615, buffer_size=11, idx=1, updated_idx=11, expected="1844674407"
check value=18446744073709551615, buffer_size=10, idx=1, updated_idx=10, expected="184467440"
check value=18446744073709551615, buffer_size=9, idx=1, updated_idx=9, expected="18446744"
check value=18446744073709551615, buffer_size=8, idx=1, updated_idx=8, expected="1844674"
check value=18446744073709551615, buffer_size=7, idx=1, updated_idx=7, expected="184467"
check value=18446744073709551615, buffer_size=6, idx=1, updated_idx=6, expected="18446"
check value=18446744073709551615, buffer_size=5, idx=1, updated_idx=5, expected="1844"
check value=18446744073709551615, buffer_size=4, idx=1, updated_idx=4, expected="184"
check value=18446744073709551615, buffer_size=3, idx=1, updated_idx=3, expected="18"
check value=18446744073709551615, buffer_size=2, idx=1, updated_idx=2, expected="1"
check value=18446744073709551615, buffer_size=1, idx=1, updated_idx=1, expected=""

#endif
