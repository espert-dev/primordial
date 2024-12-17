# ===========================================================================
# Memory manipulation and comparison tests -- Index
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

safe_str str0, ""
safe_str str1, "a"
safe_str str2, "ab"
safe_str str3, "abc"

safe_str str0_copy, ""
safe_str str1_copy, "a"
safe_str str2_copy, "ab"
safe_str str3_copy, "abc"

safe_str other_str1, "x"
safe_str other_str2, "xy"
safe_str other_str3, "xyz"

safe_str different_but_same_prefix_2, "ay"
safe_str different_but_same_prefix_3, "abz"

only_str0:
safe_str_slice str0
.equiv only_str0_size, 1

only_str1:
safe_str_slice str1
.equiv only_str1_size, 1

only_str2:
safe_str_slice str2
.equiv only_str2_size, 1

only_str3:
safe_str_slice str3
.equiv only_str3_size, 1

empty_slice:
.equiv empty_slice_size, 0

three_strings:
safe_str_slice str3
safe_str_slice other_str3
safe_str_slice different_but_same_prefix_2
.equiv three_strings_size, 3


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

not_found nil, nil

not_found str0, nil
not_found str1, nil
not_found str2, nil
not_found str3, nil

not_found str0_copy, nil
not_found str1_copy, nil
not_found str2_copy, nil
not_found str3_copy, nil

not_found str0, empty_slice
not_found str1, empty_slice
not_found str2, empty_slice
not_found str3, empty_slice

not_found str0_copy, empty_slice
not_found str1_copy, empty_slice
not_found str2_copy, empty_slice
not_found str3_copy, empty_slice

found str0, only_str0, 0
not_found str1, only_str0
not_found str2, only_str0
not_found str3, only_str0

found str0_copy, only_str0, 0
not_found str1_copy, only_str0
not_found str2_copy, only_str0
not_found str3_copy, only_str0

found str1, only_str1, 0
not_found str0, only_str1
not_found str2, only_str1
not_found str3, only_str1

found str1_copy, only_str1, 0
not_found str0_copy, only_str1
not_found str2_copy, only_str1
not_found str3_copy, only_str1

found str2, only_str2, 0
not_found str0, only_str2
not_found str1, only_str2
not_found str3, only_str2

found str2_copy, only_str2, 0
not_found str0_copy, only_str2
not_found str1_copy, only_str2
not_found str3_copy, only_str2

found str3, only_str3, 0
not_found str0, only_str3
not_found str1, only_str3
not_found str2, only_str3

found str3_copy, only_str3, 0
not_found str0_copy, only_str3
not_found str1_copy, only_str3
not_found str2_copy, only_str3

found str3_copy, three_strings, 0
not_found str0_copy, three_strings
not_found str1_copy, three_strings
not_found str2_copy, three_strings

found str3, three_strings, 0
found other_str3, three_strings, 1
found different_but_same_prefix_2, three_strings, 2
not_found different_but_same_prefix_3, three_strings
