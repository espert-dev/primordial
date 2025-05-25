# ===========================================================================
# String formatting tests - Signed integer
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

# We use two macros, pcheck and ncheck, to distinguish positive and negative
# values, because we cannot simply include the value as '-' is not permitted.

.macro check name, value, buffer_size, idx, updated_idx, expected
	# Reserve 32 bytes regardless of intended buffer size to mitigate the
	# risk of buffer overruns affecting other test cases.
	.section .bss
	.p2align 3
	.lcomm "\name\()_buffer_data", 32

	.section .rodata
	.p2align 3
	safe_str "\name\()_expected", "\expected"

	.section .text
	test_case "\name"
		save_4

		# Call function under test.
		li a0, \buffer_size
		la a1, "\name\()_buffer_data"
		li a2, \idx
		li a3, \value
		call "format.Signed"

		# Check invariants (buffer data pointer and size).
		expect_eqi \buffer_size, a0
		expect_eqa "\name\()_buffer_data", a1

		# Check that the buffer index has been updated.
		expect_eqi \updated_idx, a2

		# Check that the string representation is as expected.
		li s1, "\name\()_expected_size"
		la s2, "\name\()_expected_data"
		li s3, \updated_idx - \idx
		la s4, "\name\()_buffer_data" + \idx

		mv a0, s1
		mv a1, s2
		mv a2, s3
		mv a3, s4
		call "mem.Eq"
		expect_eqi 1, a0

		lx t0, "testing_state.test_failed"(tp)
		beqz t0, ".L\name\().end"

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

	".L\name\().end":
		restore_4
	end_test
.endm

.macro pcheck value, buffer_size, idx, updated_idx, expected
	check \
		name="SignedP_\value\()_\buffer_size\()_\idx", \
		value="\value", \
		buffer_size="\buffer_size" \
		idx="\idx", \
		updated_idx="\updated_idx", \
		expected="\expected"
.endm

.macro ncheck value, buffer_size, idx, updated_idx, expected
	check \
		name="SignedN_\value\()_\buffer_size\()_\idx", \
		value="-\value", \
		buffer_size="\buffer_size" \
		idx="\idx", \
		updated_idx="\updated_idx", \
		expected="\expected"
.endm

# ===========================================================================
# Test cases for positive numbers
# ===========================================================================

.section .text

test_case Signed_does_not_write_to_nil_output
	save_0

	li a0, nil_size
	li a1, nil_data
	li a2, 0
	li a3, 0

	# May fault on failure.
	call "format.Signed"
	expect_eqi nil_size, a0
	expect_eqi nil_data, a1
	expect_eqi 0, a2

	restore_0
end_test

# Test all positive single digits (no space).
pcheck value=0, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=1, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=2, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=3, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=4, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=5, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=6, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=7, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=8, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=9, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test all positive single digits (exact space).
pcheck value=0, buffer_size=1, idx=0, updated_idx=1, expected="0"
pcheck value=1, buffer_size=1, idx=0, updated_idx=1, expected="1"
pcheck value=2, buffer_size=1, idx=0, updated_idx=1, expected="2"
pcheck value=3, buffer_size=1, idx=0, updated_idx=1, expected="3"
pcheck value=4, buffer_size=1, idx=0, updated_idx=1, expected="4"
pcheck value=5, buffer_size=1, idx=0, updated_idx=1, expected="5"
pcheck value=6, buffer_size=1, idx=0, updated_idx=1, expected="6"
pcheck value=7, buffer_size=1, idx=0, updated_idx=1, expected="7"
pcheck value=8, buffer_size=1, idx=0, updated_idx=1, expected="8"
pcheck value=9, buffer_size=1, idx=0, updated_idx=1, expected="9"

# Test all positive single digits (extra space).
pcheck value=0, buffer_size=2, idx=0, updated_idx=1, expected="0"
pcheck value=1, buffer_size=2, idx=0, updated_idx=1, expected="1"
pcheck value=2, buffer_size=2, idx=0, updated_idx=1, expected="2"
pcheck value=3, buffer_size=2, idx=0, updated_idx=1, expected="3"
pcheck value=4, buffer_size=2, idx=0, updated_idx=1, expected="4"
pcheck value=5, buffer_size=2, idx=0, updated_idx=1, expected="5"
pcheck value=6, buffer_size=2, idx=0, updated_idx=1, expected="6"
pcheck value=7, buffer_size=2, idx=0, updated_idx=1, expected="7"
pcheck value=8, buffer_size=2, idx=0, updated_idx=1, expected="8"
pcheck value=9, buffer_size=2, idx=0, updated_idx=1, expected="9"

# Test all positive single digits (offset 1).
pcheck value=0, buffer_size=2, idx=1, updated_idx=2, expected="0"
pcheck value=1, buffer_size=2, idx=1, updated_idx=2, expected="1"
pcheck value=2, buffer_size=2, idx=1, updated_idx=2, expected="2"
pcheck value=3, buffer_size=2, idx=1, updated_idx=2, expected="3"
pcheck value=4, buffer_size=2, idx=1, updated_idx=2, expected="4"
pcheck value=5, buffer_size=2, idx=1, updated_idx=2, expected="5"
pcheck value=6, buffer_size=2, idx=1, updated_idx=2, expected="6"
pcheck value=7, buffer_size=2, idx=1, updated_idx=2, expected="7"
pcheck value=8, buffer_size=2, idx=1, updated_idx=2, expected="8"
pcheck value=9, buffer_size=2, idx=1, updated_idx=2, expected="9"

# Test 2 digits (no space).
pcheck value=10, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=19, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=20, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=29, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=30, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=39, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=40, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=49, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=50, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=59, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=60, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=69, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=70, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=79, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=80, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=89, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=90, buffer_size=0, idx=0, updated_idx=0, expected=""
pcheck value=99, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test 2 digits (truncated).
pcheck value=10, buffer_size=1, idx=0, updated_idx=1, expected="1"
pcheck value=19, buffer_size=1, idx=0, updated_idx=1, expected="1"
pcheck value=20, buffer_size=1, idx=0, updated_idx=1, expected="2"
pcheck value=29, buffer_size=1, idx=0, updated_idx=1, expected="2"
pcheck value=30, buffer_size=1, idx=0, updated_idx=1, expected="3"
pcheck value=39, buffer_size=1, idx=0, updated_idx=1, expected="3"
pcheck value=40, buffer_size=1, idx=0, updated_idx=1, expected="4"
pcheck value=49, buffer_size=1, idx=0, updated_idx=1, expected="4"
pcheck value=50, buffer_size=1, idx=0, updated_idx=1, expected="5"
pcheck value=59, buffer_size=1, idx=0, updated_idx=1, expected="5"
pcheck value=60, buffer_size=1, idx=0, updated_idx=1, expected="6"
pcheck value=69, buffer_size=1, idx=0, updated_idx=1, expected="6"
pcheck value=70, buffer_size=1, idx=0, updated_idx=1, expected="7"
pcheck value=79, buffer_size=1, idx=0, updated_idx=1, expected="7"
pcheck value=80, buffer_size=1, idx=0, updated_idx=1, expected="8"
pcheck value=89, buffer_size=1, idx=0, updated_idx=1, expected="8"
pcheck value=90, buffer_size=1, idx=0, updated_idx=1, expected="9"
pcheck value=99, buffer_size=1, idx=0, updated_idx=1, expected="9"

# Test 2 digits (exact space).
pcheck value=10, buffer_size=2, idx=0, updated_idx=2, expected="10"
pcheck value=19, buffer_size=2, idx=0, updated_idx=2, expected="19"
pcheck value=20, buffer_size=2, idx=0, updated_idx=2, expected="20"
pcheck value=29, buffer_size=2, idx=0, updated_idx=2, expected="29"
pcheck value=30, buffer_size=2, idx=0, updated_idx=2, expected="30"
pcheck value=39, buffer_size=2, idx=0, updated_idx=2, expected="39"
pcheck value=40, buffer_size=2, idx=0, updated_idx=2, expected="40"
pcheck value=49, buffer_size=2, idx=0, updated_idx=2, expected="49"
pcheck value=50, buffer_size=2, idx=0, updated_idx=2, expected="50"
pcheck value=59, buffer_size=2, idx=0, updated_idx=2, expected="59"
pcheck value=60, buffer_size=2, idx=0, updated_idx=2, expected="60"
pcheck value=69, buffer_size=2, idx=0, updated_idx=2, expected="69"
pcheck value=70, buffer_size=2, idx=0, updated_idx=2, expected="70"
pcheck value=79, buffer_size=2, idx=0, updated_idx=2, expected="79"
pcheck value=80, buffer_size=2, idx=0, updated_idx=2, expected="80"
pcheck value=89, buffer_size=2, idx=0, updated_idx=2, expected="89"
pcheck value=90, buffer_size=2, idx=0, updated_idx=2, expected="90"
pcheck value=99, buffer_size=2, idx=0, updated_idx=2, expected="99"

# Test 2 digits (extra space).
pcheck value=10, buffer_size=3, idx=0, updated_idx=2, expected="10"
pcheck value=19, buffer_size=3, idx=0, updated_idx=2, expected="19"
pcheck value=20, buffer_size=3, idx=0, updated_idx=2, expected="20"
pcheck value=29, buffer_size=3, idx=0, updated_idx=2, expected="29"
pcheck value=30, buffer_size=3, idx=0, updated_idx=2, expected="30"
pcheck value=39, buffer_size=3, idx=0, updated_idx=2, expected="39"
pcheck value=40, buffer_size=3, idx=0, updated_idx=2, expected="40"
pcheck value=49, buffer_size=3, idx=0, updated_idx=2, expected="49"
pcheck value=50, buffer_size=3, idx=0, updated_idx=2, expected="50"
pcheck value=59, buffer_size=3, idx=0, updated_idx=2, expected="59"
pcheck value=60, buffer_size=3, idx=0, updated_idx=2, expected="60"
pcheck value=69, buffer_size=3, idx=0, updated_idx=2, expected="69"
pcheck value=70, buffer_size=3, idx=0, updated_idx=2, expected="70"
pcheck value=79, buffer_size=3, idx=0, updated_idx=2, expected="79"
pcheck value=80, buffer_size=3, idx=0, updated_idx=2, expected="80"
pcheck value=89, buffer_size=3, idx=0, updated_idx=2, expected="89"
pcheck value=90, buffer_size=3, idx=0, updated_idx=2, expected="90"
pcheck value=99, buffer_size=3, idx=0, updated_idx=2, expected="99"

# Test 2 digits (offset 1).
pcheck value=10, buffer_size=3, idx=1, updated_idx=3, expected="10"
pcheck value=19, buffer_size=3, idx=1, updated_idx=3, expected="19"
pcheck value=20, buffer_size=3, idx=1, updated_idx=3, expected="20"
pcheck value=29, buffer_size=3, idx=1, updated_idx=3, expected="29"
pcheck value=30, buffer_size=3, idx=1, updated_idx=3, expected="30"
pcheck value=39, buffer_size=3, idx=1, updated_idx=3, expected="39"
pcheck value=40, buffer_size=3, idx=1, updated_idx=3, expected="40"
pcheck value=49, buffer_size=3, idx=1, updated_idx=3, expected="49"
pcheck value=50, buffer_size=3, idx=1, updated_idx=3, expected="50"
pcheck value=59, buffer_size=3, idx=1, updated_idx=3, expected="59"
pcheck value=60, buffer_size=3, idx=1, updated_idx=3, expected="60"
pcheck value=69, buffer_size=3, idx=1, updated_idx=3, expected="69"
pcheck value=70, buffer_size=3, idx=1, updated_idx=3, expected="70"
pcheck value=79, buffer_size=3, idx=1, updated_idx=3, expected="79"
pcheck value=80, buffer_size=3, idx=1, updated_idx=3, expected="80"
pcheck value=89, buffer_size=3, idx=1, updated_idx=3, expected="89"
pcheck value=90, buffer_size=3, idx=1, updated_idx=3, expected="90"
pcheck value=99, buffer_size=3, idx=1, updated_idx=3, expected="99"

# Test 3 digits (exact space).
pcheck value=150, buffer_size=3, idx=0, updated_idx=3, expected="150"
pcheck value=159, buffer_size=3, idx=0, updated_idx=3, expected="159"
pcheck value=250, buffer_size=3, idx=0, updated_idx=3, expected="250"
pcheck value=259, buffer_size=3, idx=0, updated_idx=3, expected="259"
pcheck value=350, buffer_size=3, idx=0, updated_idx=3, expected="350"
pcheck value=359, buffer_size=3, idx=0, updated_idx=3, expected="359"
pcheck value=450, buffer_size=3, idx=0, updated_idx=3, expected="450"
pcheck value=459, buffer_size=3, idx=0, updated_idx=3, expected="459"
pcheck value=550, buffer_size=3, idx=0, updated_idx=3, expected="550"
pcheck value=559, buffer_size=3, idx=0, updated_idx=3, expected="559"
pcheck value=650, buffer_size=3, idx=0, updated_idx=3, expected="650"
pcheck value=659, buffer_size=3, idx=0, updated_idx=3, expected="659"
pcheck value=750, buffer_size=3, idx=0, updated_idx=3, expected="750"
pcheck value=759, buffer_size=3, idx=0, updated_idx=3, expected="759"
pcheck value=850, buffer_size=3, idx=0, updated_idx=3, expected="850"
pcheck value=859, buffer_size=3, idx=0, updated_idx=3, expected="859"
pcheck value=950, buffer_size=3, idx=0, updated_idx=3, expected="950"
pcheck value=959, buffer_size=3, idx=0, updated_idx=3, expected="959"

# Maximum value in 32-bit (exact space).
pcheck value=2147483647, buffer_size=10, idx=0, updated_idx=10, expected="2147483647"

# Maximum value in 32-bit (truncated).
pcheck value=2147483647, buffer_size=9, idx=0, updated_idx=9, expected="214748364"
pcheck value=2147483647, buffer_size=8, idx=0, updated_idx=8, expected="21474836"
pcheck value=2147483647, buffer_size=7, idx=0, updated_idx=7, expected="2147483"
pcheck value=2147483647, buffer_size=6, idx=0, updated_idx=6, expected="214748"
pcheck value=2147483647, buffer_size=5, idx=0, updated_idx=5, expected="21474"
pcheck value=2147483647, buffer_size=4, idx=0, updated_idx=4, expected="2147"
pcheck value=2147483647, buffer_size=3, idx=0, updated_idx=3, expected="214"
pcheck value=2147483647, buffer_size=2, idx=0, updated_idx=2, expected="21"
pcheck value=2147483647, buffer_size=1, idx=0, updated_idx=1, expected="2"
pcheck value=2147483647, buffer_size=0, idx=0, updated_idx=0, expected=""

# Maximum value in 32-bit (offset, truncation in all but first).
pcheck value=2147483647, buffer_size=11, idx=1, updated_idx=11, expected="2147483647"
pcheck value=2147483647, buffer_size=10, idx=1, updated_idx=10, expected="214748364"
pcheck value=2147483647, buffer_size=9, idx=1, updated_idx=9, expected="21474836"
pcheck value=2147483647, buffer_size=8, idx=1, updated_idx=8, expected="2147483"
pcheck value=2147483647, buffer_size=7, idx=1, updated_idx=7, expected="214748"
pcheck value=2147483647, buffer_size=6, idx=1, updated_idx=6, expected="21474"
pcheck value=2147483647, buffer_size=5, idx=1, updated_idx=5, expected="2147"
pcheck value=2147483647, buffer_size=4, idx=1, updated_idx=4, expected="214"
pcheck value=2147483647, buffer_size=3, idx=1, updated_idx=3, expected="21"
pcheck value=2147483647, buffer_size=2, idx=1, updated_idx=2, expected="2"
pcheck value=2147483647, buffer_size=1, idx=1, updated_idx=1, expected=""

# if XLEN >= 64

# Maximum value in 64-bit (exact space).
pcheck value=9223372036854775807, buffer_size=19, idx=0, updated_idx=19, expected="9223372036854775807"

# Maximum value in 64-bit (truncated).
pcheck value=9223372036854775807, buffer_size=18, idx=0, updated_idx=18, expected="922337203685477580"
pcheck value=9223372036854775807, buffer_size=17, idx=0, updated_idx=17, expected="92233720368547758"
pcheck value=9223372036854775807, buffer_size=16, idx=0, updated_idx=16, expected="9223372036854775"
pcheck value=9223372036854775807, buffer_size=15, idx=0, updated_idx=15, expected="922337203685477"
pcheck value=9223372036854775807, buffer_size=14, idx=0, updated_idx=14, expected="92233720368547"
pcheck value=9223372036854775807, buffer_size=13, idx=0, updated_idx=13, expected="9223372036854"
pcheck value=9223372036854775807, buffer_size=12, idx=0, updated_idx=12, expected="922337203685"
pcheck value=9223372036854775807, buffer_size=11, idx=0, updated_idx=11, expected="92233720368"
pcheck value=9223372036854775807, buffer_size=10, idx=0, updated_idx=10, expected="9223372036"
pcheck value=9223372036854775807, buffer_size=9, idx=0, updated_idx=9, expected="922337203"
pcheck value=9223372036854775807, buffer_size=8, idx=0, updated_idx=8, expected="92233720"
pcheck value=9223372036854775807, buffer_size=7, idx=0, updated_idx=7, expected="9223372"
pcheck value=9223372036854775807, buffer_size=6, idx=0, updated_idx=6, expected="922337"
pcheck value=9223372036854775807, buffer_size=5, idx=0, updated_idx=5, expected="92233"
pcheck value=9223372036854775807, buffer_size=4, idx=0, updated_idx=4, expected="9223"
pcheck value=9223372036854775807, buffer_size=3, idx=0, updated_idx=3, expected="922"
pcheck value=9223372036854775807, buffer_size=2, idx=0, updated_idx=2, expected="92"
pcheck value=9223372036854775807, buffer_size=1, idx=0, updated_idx=1, expected="9"
pcheck value=9223372036854775807, buffer_size=0, idx=0, updated_idx=0, expected=""

# Maximum value in 64-bit (offset, truncation in all but first).
pcheck value=9223372036854775807, buffer_size=20, idx=1, updated_idx=20, expected="9223372036854775807"
pcheck value=9223372036854775807, buffer_size=19, idx=1, updated_idx=19, expected="922337203685477580"
pcheck value=9223372036854775807, buffer_size=18, idx=1, updated_idx=18, expected="92233720368547758"
pcheck value=9223372036854775807, buffer_size=17, idx=1, updated_idx=17, expected="9223372036854775"
pcheck value=9223372036854775807, buffer_size=16, idx=1, updated_idx=16, expected="922337203685477"
pcheck value=9223372036854775807, buffer_size=15, idx=1, updated_idx=15, expected="92233720368547"
pcheck value=9223372036854775807, buffer_size=14, idx=1, updated_idx=14, expected="9223372036854"
pcheck value=9223372036854775807, buffer_size=13, idx=1, updated_idx=13, expected="922337203685"
pcheck value=9223372036854775807, buffer_size=12, idx=1, updated_idx=12, expected="92233720368"
pcheck value=9223372036854775807, buffer_size=11, idx=1, updated_idx=11, expected="9223372036"
pcheck value=9223372036854775807, buffer_size=10, idx=1, updated_idx=10, expected="922337203"
pcheck value=9223372036854775807, buffer_size=9, idx=1, updated_idx=9, expected="92233720"
pcheck value=9223372036854775807, buffer_size=8, idx=1, updated_idx=8, expected="9223372"
pcheck value=9223372036854775807, buffer_size=7, idx=1, updated_idx=7, expected="922337"
pcheck value=9223372036854775807, buffer_size=6, idx=1, updated_idx=6, expected="92233"
pcheck value=9223372036854775807, buffer_size=5, idx=1, updated_idx=5, expected="9223"
pcheck value=9223372036854775807, buffer_size=4, idx=1, updated_idx=4, expected="922"
pcheck value=9223372036854775807, buffer_size=3, idx=1, updated_idx=3, expected="92"
pcheck value=9223372036854775807, buffer_size=2, idx=1, updated_idx=2, expected="9"
pcheck value=9223372036854775807, buffer_size=1, idx=1, updated_idx=1, expected=""

#endif


# ===========================================================================
# Test cases for negative numbers
# ===========================================================================

# Test all negative single digits (no space).
ncheck value=1, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=2, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=3, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=4, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=5, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=6, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=7, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=8, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=9, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test all negative single digits (truncated at sign).
ncheck value=1, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=2, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=3, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=4, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=5, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=6, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=7, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=8, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=9, buffer_size=1, idx=0, updated_idx=1, expected="-"

# Test all negative single digits (exact space).
ncheck value=1, buffer_size=2, idx=0, updated_idx=2, expected="-1"
ncheck value=2, buffer_size=2, idx=0, updated_idx=2, expected="-2"
ncheck value=3, buffer_size=2, idx=0, updated_idx=2, expected="-3"
ncheck value=4, buffer_size=2, idx=0, updated_idx=2, expected="-4"
ncheck value=5, buffer_size=2, idx=0, updated_idx=2, expected="-5"
ncheck value=6, buffer_size=2, idx=0, updated_idx=2, expected="-6"
ncheck value=7, buffer_size=2, idx=0, updated_idx=2, expected="-7"
ncheck value=8, buffer_size=2, idx=0, updated_idx=2, expected="-8"
ncheck value=9, buffer_size=2, idx=0, updated_idx=2, expected="-9"

# Test all negative single digits (extra space).
ncheck value=1, buffer_size=3, idx=0, updated_idx=2, expected="-1"
ncheck value=2, buffer_size=3, idx=0, updated_idx=2, expected="-2"
ncheck value=3, buffer_size=3, idx=0, updated_idx=2, expected="-3"
ncheck value=4, buffer_size=3, idx=0, updated_idx=2, expected="-4"
ncheck value=5, buffer_size=3, idx=0, updated_idx=2, expected="-5"
ncheck value=6, buffer_size=3, idx=0, updated_idx=2, expected="-6"
ncheck value=7, buffer_size=3, idx=0, updated_idx=2, expected="-7"
ncheck value=8, buffer_size=3, idx=0, updated_idx=2, expected="-8"
ncheck value=9, buffer_size=3, idx=0, updated_idx=2, expected="-9"

# Test all negative single digits (offset 1).
ncheck value=1, buffer_size=3, idx=1, updated_idx=3, expected="-1"
ncheck value=2, buffer_size=3, idx=1, updated_idx=3, expected="-2"
ncheck value=3, buffer_size=3, idx=1, updated_idx=3, expected="-3"
ncheck value=4, buffer_size=3, idx=1, updated_idx=3, expected="-4"
ncheck value=5, buffer_size=3, idx=1, updated_idx=3, expected="-5"
ncheck value=6, buffer_size=3, idx=1, updated_idx=3, expected="-6"
ncheck value=7, buffer_size=3, idx=1, updated_idx=3, expected="-7"
ncheck value=8, buffer_size=3, idx=1, updated_idx=3, expected="-8"
ncheck value=9, buffer_size=3, idx=1, updated_idx=3, expected="-9"

# Test 2 digits (no space).
ncheck value=10, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=19, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=20, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=29, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=30, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=39, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=40, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=49, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=50, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=59, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=60, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=69, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=70, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=79, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=80, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=89, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=90, buffer_size=0, idx=0, updated_idx=0, expected=""
ncheck value=99, buffer_size=0, idx=0, updated_idx=0, expected=""

# Test 2 digits (truncated at sign).
ncheck value=10, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=19, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=20, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=29, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=30, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=39, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=40, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=49, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=50, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=59, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=60, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=69, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=70, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=79, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=80, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=89, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=90, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=99, buffer_size=1, idx=0, updated_idx=1, expected="-"

# Test 2 digits (truncated).
ncheck value=10, buffer_size=2, idx=0, updated_idx=2, expected="-1"
ncheck value=19, buffer_size=2, idx=0, updated_idx=2, expected="-1"
ncheck value=20, buffer_size=2, idx=0, updated_idx=2, expected="-2"
ncheck value=29, buffer_size=2, idx=0, updated_idx=2, expected="-2"
ncheck value=30, buffer_size=2, idx=0, updated_idx=2, expected="-3"
ncheck value=39, buffer_size=2, idx=0, updated_idx=2, expected="-3"
ncheck value=40, buffer_size=2, idx=0, updated_idx=2, expected="-4"
ncheck value=49, buffer_size=2, idx=0, updated_idx=2, expected="-4"
ncheck value=50, buffer_size=2, idx=0, updated_idx=2, expected="-5"
ncheck value=59, buffer_size=2, idx=0, updated_idx=2, expected="-5"
ncheck value=60, buffer_size=2, idx=0, updated_idx=2, expected="-6"
ncheck value=69, buffer_size=2, idx=0, updated_idx=2, expected="-6"
ncheck value=70, buffer_size=2, idx=0, updated_idx=2, expected="-7"
ncheck value=79, buffer_size=2, idx=0, updated_idx=2, expected="-7"
ncheck value=80, buffer_size=2, idx=0, updated_idx=2, expected="-8"
ncheck value=89, buffer_size=2, idx=0, updated_idx=2, expected="-8"
ncheck value=90, buffer_size=2, idx=0, updated_idx=2, expected="-9"
ncheck value=99, buffer_size=2, idx=0, updated_idx=2, expected="-9"

# Test 2 digits (exact space).
ncheck value=10, buffer_size=3, idx=0, updated_idx=3, expected="-10"
ncheck value=19, buffer_size=3, idx=0, updated_idx=3, expected="-19"
ncheck value=20, buffer_size=3, idx=0, updated_idx=3, expected="-20"
ncheck value=29, buffer_size=3, idx=0, updated_idx=3, expected="-29"
ncheck value=30, buffer_size=3, idx=0, updated_idx=3, expected="-30"
ncheck value=39, buffer_size=3, idx=0, updated_idx=3, expected="-39"
ncheck value=40, buffer_size=3, idx=0, updated_idx=3, expected="-40"
ncheck value=49, buffer_size=3, idx=0, updated_idx=3, expected="-49"
ncheck value=50, buffer_size=3, idx=0, updated_idx=3, expected="-50"
ncheck value=59, buffer_size=3, idx=0, updated_idx=3, expected="-59"
ncheck value=60, buffer_size=3, idx=0, updated_idx=3, expected="-60"
ncheck value=69, buffer_size=3, idx=0, updated_idx=3, expected="-69"
ncheck value=70, buffer_size=3, idx=0, updated_idx=3, expected="-70"
ncheck value=79, buffer_size=3, idx=0, updated_idx=3, expected="-79"
ncheck value=80, buffer_size=3, idx=0, updated_idx=3, expected="-80"
ncheck value=89, buffer_size=3, idx=0, updated_idx=3, expected="-89"
ncheck value=90, buffer_size=3, idx=0, updated_idx=3, expected="-90"
ncheck value=99, buffer_size=3, idx=0, updated_idx=3, expected="-99"

# Test 2 digits (extra space).
ncheck value=10, buffer_size=4, idx=0, updated_idx=3, expected="-10"
ncheck value=19, buffer_size=4, idx=0, updated_idx=3, expected="-19"
ncheck value=20, buffer_size=4, idx=0, updated_idx=3, expected="-20"
ncheck value=29, buffer_size=4, idx=0, updated_idx=3, expected="-29"
ncheck value=30, buffer_size=4, idx=0, updated_idx=3, expected="-30"
ncheck value=39, buffer_size=4, idx=0, updated_idx=3, expected="-39"
ncheck value=40, buffer_size=4, idx=0, updated_idx=3, expected="-40"
ncheck value=49, buffer_size=4, idx=0, updated_idx=3, expected="-49"
ncheck value=50, buffer_size=4, idx=0, updated_idx=3, expected="-50"
ncheck value=59, buffer_size=4, idx=0, updated_idx=3, expected="-59"
ncheck value=60, buffer_size=4, idx=0, updated_idx=3, expected="-60"
ncheck value=69, buffer_size=4, idx=0, updated_idx=3, expected="-69"
ncheck value=70, buffer_size=4, idx=0, updated_idx=3, expected="-70"
ncheck value=79, buffer_size=4, idx=0, updated_idx=3, expected="-79"
ncheck value=80, buffer_size=4, idx=0, updated_idx=3, expected="-80"
ncheck value=89, buffer_size=4, idx=0, updated_idx=3, expected="-89"
ncheck value=90, buffer_size=4, idx=0, updated_idx=3, expected="-90"
ncheck value=99, buffer_size=4, idx=0, updated_idx=3, expected="-99"

# Test 2 digits (offset 1).
ncheck value=10, buffer_size=4, idx=1, updated_idx=4, expected="-10"
ncheck value=19, buffer_size=4, idx=1, updated_idx=4, expected="-19"
ncheck value=20, buffer_size=4, idx=1, updated_idx=4, expected="-20"
ncheck value=29, buffer_size=4, idx=1, updated_idx=4, expected="-29"
ncheck value=30, buffer_size=4, idx=1, updated_idx=4, expected="-30"
ncheck value=39, buffer_size=4, idx=1, updated_idx=4, expected="-39"
ncheck value=40, buffer_size=4, idx=1, updated_idx=4, expected="-40"
ncheck value=49, buffer_size=4, idx=1, updated_idx=4, expected="-49"
ncheck value=50, buffer_size=4, idx=1, updated_idx=4, expected="-50"
ncheck value=59, buffer_size=4, idx=1, updated_idx=4, expected="-59"
ncheck value=60, buffer_size=4, idx=1, updated_idx=4, expected="-60"
ncheck value=69, buffer_size=4, idx=1, updated_idx=4, expected="-69"
ncheck value=70, buffer_size=4, idx=1, updated_idx=4, expected="-70"
ncheck value=79, buffer_size=4, idx=1, updated_idx=4, expected="-79"
ncheck value=80, buffer_size=4, idx=1, updated_idx=4, expected="-80"
ncheck value=89, buffer_size=4, idx=1, updated_idx=4, expected="-89"
ncheck value=90, buffer_size=4, idx=1, updated_idx=4, expected="-90"
ncheck value=99, buffer_size=4, idx=1, updated_idx=4, expected="-99"

# Test 3 digits (exact space).
ncheck value=150, buffer_size=4, idx=0, updated_idx=4, expected="-150"
ncheck value=159, buffer_size=4, idx=0, updated_idx=4, expected="-159"
ncheck value=250, buffer_size=4, idx=0, updated_idx=4, expected="-250"
ncheck value=259, buffer_size=4, idx=0, updated_idx=4, expected="-259"
ncheck value=350, buffer_size=4, idx=0, updated_idx=4, expected="-350"
ncheck value=359, buffer_size=4, idx=0, updated_idx=4, expected="-359"
ncheck value=450, buffer_size=4, idx=0, updated_idx=4, expected="-450"
ncheck value=459, buffer_size=4, idx=0, updated_idx=4, expected="-459"
ncheck value=550, buffer_size=4, idx=0, updated_idx=4, expected="-550"
ncheck value=559, buffer_size=4, idx=0, updated_idx=4, expected="-559"
ncheck value=650, buffer_size=4, idx=0, updated_idx=4, expected="-650"
ncheck value=659, buffer_size=4, idx=0, updated_idx=4, expected="-659"
ncheck value=750, buffer_size=4, idx=0, updated_idx=4, expected="-750"
ncheck value=759, buffer_size=4, idx=0, updated_idx=4, expected="-759"
ncheck value=850, buffer_size=4, idx=0, updated_idx=4, expected="-850"
ncheck value=859, buffer_size=4, idx=0, updated_idx=4, expected="-859"
ncheck value=950, buffer_size=4, idx=0, updated_idx=4, expected="-950"
ncheck value=959, buffer_size=4, idx=0, updated_idx=4, expected="-959"

# Minimum value in 32-bit (exact space).
ncheck value=2147483648, buffer_size=11, idx=0, updated_idx=11, expected="-2147483648"

# Minimum value in 32-bit (truncated).
ncheck value=2147483648, buffer_size=10, idx=0, updated_idx=10, expected="-214748364"
ncheck value=2147483648, buffer_size=9, idx=0, updated_idx=9, expected="-21474836"
ncheck value=2147483648, buffer_size=8, idx=0, updated_idx=8, expected="-2147483"
ncheck value=2147483648, buffer_size=7, idx=0, updated_idx=7, expected="-214748"
ncheck value=2147483648, buffer_size=6, idx=0, updated_idx=6, expected="-21474"
ncheck value=2147483648, buffer_size=5, idx=0, updated_idx=5, expected="-2147"
ncheck value=2147483648, buffer_size=4, idx=0, updated_idx=4, expected="-214"
ncheck value=2147483648, buffer_size=3, idx=0, updated_idx=3, expected="-21"
ncheck value=2147483648, buffer_size=2, idx=0, updated_idx=2, expected="-2"
ncheck value=2147483648, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=2147483648, buffer_size=0, idx=0, updated_idx=0, expected=""

# Minimum value in 32-bit (offset, truncation in all but first).
ncheck value=2147483648, buffer_size=12, idx=1, updated_idx=12, expected="-2147483648"
ncheck value=2147483648, buffer_size=11, idx=1, updated_idx=11, expected="-214748364"
ncheck value=2147483648, buffer_size=10, idx=1, updated_idx=10, expected="-21474836"
ncheck value=2147483648, buffer_size=9, idx=1, updated_idx=9, expected="-2147483"
ncheck value=2147483648, buffer_size=8, idx=1, updated_idx=8, expected="-214748"
ncheck value=2147483648, buffer_size=7, idx=1, updated_idx=7, expected="-21474"
ncheck value=2147483648, buffer_size=6, idx=1, updated_idx=6, expected="-2147"
ncheck value=2147483648, buffer_size=5, idx=1, updated_idx=5, expected="-214"
ncheck value=2147483648, buffer_size=4, idx=1, updated_idx=4, expected="-21"
ncheck value=2147483648, buffer_size=3, idx=1, updated_idx=3, expected="-2"
ncheck value=2147483648, buffer_size=2, idx=1, updated_idx=2, expected="-"
ncheck value=2147483648, buffer_size=1, idx=1, updated_idx=1, expected=""

#if XLEN >= 64

# Minimum value in 64-bit (exact space).
ncheck value=9223372036854775808, buffer_size=20, idx=0, updated_idx=20, expected="-9223372036854775808"

# Minimum value in 64-bit (truncated).
ncheck value=9223372036854775808, buffer_size=19, idx=0, updated_idx=19, expected="-922337203685477580"
ncheck value=9223372036854775808, buffer_size=18, idx=0, updated_idx=18, expected="-92233720368547758"
ncheck value=9223372036854775808, buffer_size=17, idx=0, updated_idx=17, expected="-9223372036854775"
ncheck value=9223372036854775808, buffer_size=16, idx=0, updated_idx=16, expected="-922337203685477"
ncheck value=9223372036854775808, buffer_size=15, idx=0, updated_idx=15, expected="-92233720368547"
ncheck value=9223372036854775808, buffer_size=14, idx=0, updated_idx=14, expected="-9223372036854"
ncheck value=9223372036854775808, buffer_size=13, idx=0, updated_idx=13, expected="-922337203685"
ncheck value=9223372036854775808, buffer_size=12, idx=0, updated_idx=12, expected="-92233720368"
ncheck value=9223372036854775808, buffer_size=11, idx=0, updated_idx=11, expected="-9223372036"
ncheck value=9223372036854775808, buffer_size=10, idx=0, updated_idx=10, expected="-922337203"
ncheck value=9223372036854775808, buffer_size=9, idx=0, updated_idx=9, expected="-92233720"
ncheck value=9223372036854775808, buffer_size=8, idx=0, updated_idx=8, expected="-9223372"
ncheck value=9223372036854775808, buffer_size=7, idx=0, updated_idx=7, expected="-922337"
ncheck value=9223372036854775808, buffer_size=6, idx=0, updated_idx=6, expected="-92233"
ncheck value=9223372036854775808, buffer_size=5, idx=0, updated_idx=5, expected="-9223"
ncheck value=9223372036854775808, buffer_size=4, idx=0, updated_idx=4, expected="-922"
ncheck value=9223372036854775808, buffer_size=3, idx=0, updated_idx=3, expected="-92"
ncheck value=9223372036854775808, buffer_size=2, idx=0, updated_idx=2, expected="-9"
ncheck value=9223372036854775808, buffer_size=1, idx=0, updated_idx=1, expected="-"
ncheck value=9223372036854775808, buffer_size=0, idx=0, updated_idx=0, expected=""

# Minimum value in 64-bit (offset, truncation in all but first).
ncheck value=9223372036854775808, buffer_size=21, idx=1, updated_idx=21, expected="-9223372036854775808"
ncheck value=9223372036854775808, buffer_size=20, idx=1, updated_idx=20, expected="-922337203685477580"
ncheck value=9223372036854775808, buffer_size=19, idx=1, updated_idx=19, expected="-92233720368547758"
ncheck value=9223372036854775808, buffer_size=18, idx=1, updated_idx=18, expected="-9223372036854775"
ncheck value=9223372036854775808, buffer_size=17, idx=1, updated_idx=17, expected="-922337203685477"
ncheck value=9223372036854775808, buffer_size=16, idx=1, updated_idx=16, expected="-92233720368547"
ncheck value=9223372036854775808, buffer_size=15, idx=1, updated_idx=15, expected="-9223372036854"
ncheck value=9223372036854775808, buffer_size=14, idx=1, updated_idx=14, expected="-922337203685"
ncheck value=9223372036854775808, buffer_size=13, idx=1, updated_idx=13, expected="-92233720368"
ncheck value=9223372036854775808, buffer_size=12, idx=1, updated_idx=12, expected="-9223372036"
ncheck value=9223372036854775808, buffer_size=11, idx=1, updated_idx=11, expected="-922337203"
ncheck value=9223372036854775808, buffer_size=10, idx=1, updated_idx=10, expected="-92233720"
ncheck value=9223372036854775808, buffer_size=9, idx=1, updated_idx=9, expected="-9223372"
ncheck value=9223372036854775808, buffer_size=8, idx=1, updated_idx=8, expected="-922337"
ncheck value=9223372036854775808, buffer_size=7, idx=1, updated_idx=7, expected="-92233"
ncheck value=9223372036854775808, buffer_size=6, idx=1, updated_idx=6, expected="-9223"
ncheck value=9223372036854775808, buffer_size=5, idx=1, updated_idx=5, expected="-922"
ncheck value=9223372036854775808, buffer_size=4, idx=1, updated_idx=4, expected="-92"
ncheck value=9223372036854775808, buffer_size=3, idx=1, updated_idx=3, expected="-9"
ncheck value=9223372036854775808, buffer_size=2, idx=1, updated_idx=2, expected="-"
ncheck value=9223372036854775808, buffer_size=1, idx=1, updated_idx=1, expected=""

#endif
