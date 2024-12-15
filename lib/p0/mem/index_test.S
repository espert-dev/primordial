# ===========================================================================
# memory manipulation tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test macros
# ===========================================================================

.macro found str, slice, position
test_case Index_\str\()_found_in_\slice\()_at_\position
	save_0

	la a0, \str
	li a1, \str\()_size
	la a2, \slice
	li a3, \slice\()_size
	call "mem.Index"

	expect_eqi \position a0

	restore_0
end_test
.endm

.macro not_found s, ss
test_case Index_\s\()_not_found_in_\ss\()
	save_0

	la a0, \s
	li a1, \s\()_size
	la a2, \ss
	li a3, \ss\()_size
	call "mem.Index"

	expect_eqi -1, a0

	restore_0
end_test
.endm


# ===========================================================================
# Test data
# ===========================================================================

# Nil string or slice with address and size 0. Useful to reuse macros.
.struct 0
nil:
.equiv nil_size, 0

.section .rodata

safe_str s0, ""
safe_str s1, "a"
safe_str s2, "ab"
safe_str s3, "abc"

safe_str s0_copy, ""
safe_str s1_copy, "a"
safe_str s2_copy, "ab"
safe_str s3_copy, "abc"

safe_str other_s1, "x"
safe_str other_s2, "xy"
safe_str other_s3, "xyz"

safe_str different_but_same_prefix_2, "ay"
safe_str different_but_same_prefix_3, "abz"

only_s0:
safe_str_slice s0
.equiv only_s0_size, 1

only_s1:
safe_str_slice s1
.equiv only_s1_size, 1

only_s2:
safe_str_slice s2
.equiv only_s2_size, 1

only_s3:
safe_str_slice s3
.equiv only_s3_size, 1

empty_slice:
.equiv empty_slice_size, 0

three_strings:
safe_str_slice s3
safe_str_slice other_s3
safe_str_slice different_but_same_prefix_2
.equiv three_strings_size, 3


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

not_found nil, nil

not_found s0, nil
not_found s1, nil
not_found s2, nil
not_found s3, nil

not_found s0_copy, nil
not_found s1_copy, nil
not_found s2_copy, nil
not_found s3_copy, nil

not_found s0, empty_slice
not_found s1, empty_slice
not_found s2, empty_slice
not_found s3, empty_slice

not_found s0_copy, empty_slice
not_found s1_copy, empty_slice
not_found s2_copy, empty_slice
not_found s3_copy, empty_slice

found s0, only_s0, 0
not_found s1, only_s0
not_found s2, only_s0
not_found s3, only_s0

found s0_copy, only_s0, 0
not_found s1_copy, only_s0
not_found s2_copy, only_s0
not_found s3_copy, only_s0

found s1, only_s1, 0
not_found s0, only_s1
not_found s2, only_s1
not_found s3, only_s1

found s1_copy, only_s1, 0
not_found s0_copy, only_s1
not_found s2_copy, only_s1
not_found s3_copy, only_s1

found s2, only_s2, 0
not_found s0, only_s2
not_found s1, only_s2
not_found s3, only_s2

found s2_copy, only_s2, 0
not_found s0_copy, only_s2
not_found s1_copy, only_s2
not_found s3_copy, only_s2

found s3, only_s3, 0
not_found s0, only_s3
not_found s1, only_s3
not_found s2, only_s3

found s3_copy, only_s3, 0
not_found s0_copy, only_s3
not_found s1_copy, only_s3
not_found s2_copy, only_s3

found s3_copy, three_strings, 0
not_found s0_copy, three_strings
not_found s1_copy, three_strings
not_found s2_copy, three_strings

found s3, three_strings, 0
found other_s3, three_strings, 1
found different_but_same_prefix_2, three_strings, 2
not_found different_but_same_prefix_3, three_strings
