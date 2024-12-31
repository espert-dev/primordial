# ===========================================================================
# Memory manipulation and comparison -- Shortlex
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test macros
# ===========================================================================

.macro expect_equal x, y
test_case Shortlex_\x\()_and_\y\()_return_equal
	save_0

	la a0, \x\()_data
	li a1, \x\()_size
	la a2, \y\()_data
	li a3, \y\()_size
	call "mem/Shortlex"

	expect_z a0

	restore_0
end_test
.endm

.macro expect_smaller x, y
test_case Shortlex_\x\()_and_\y\()_return_smaller
	save_0

	la a0, \x\()_data
	li a1, \x\()_size
	la a2, \y\()_data
	li a3, \y\()_size
	call "mem/Shortlex"

	expect_negative a0

	restore_0
end_test
.endm

.macro expect_bigger x, y
test_case Shortlex_\x\()_and_\y\()_return_bigger
	save_0

	la a0, \x\()_data
	li a1, \x\()_size
	la a2, \y\()_data
	li a3, \y\()_size
	call "mem/Shortlex"

	expect_positive a0

	restore_0
end_test
.endm


# ===========================================================================
# Test data
# ===========================================================================

.equiv nil_size, 0
.equiv nil_data, 0

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


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

expect_equal nil, nil

# Identical slices.
expect_equal str0, str0
expect_equal str1, str1
expect_equal str2, str2
expect_equal str3, str3

# Equal but not identical slices.
expect_equal str0, str0_copy
expect_equal str1, str1_copy
expect_equal str2, str2_copy
expect_equal str3, str3_copy

# Different slices of the same size, returning smaller.
expect_smaller str1, other_str1
expect_smaller str2, other_str2
expect_smaller str3, other_str3

# Different slices of the same size, returning bigger.
expect_bigger other_str1, str1
expect_bigger other_str2, str2
expect_bigger other_str3, str3

# Different but with a common prefix.
expect_smaller str2, different_but_same_prefix_2
expect_bigger different_but_same_prefix_2, str2

expect_smaller str3, different_but_same_prefix_3
expect_bigger different_but_same_prefix_3, str3

# The size decides against the lexicographical order.
expect_smaller other_str1, str2
expect_bigger str2, other_str1

expect_smaller other_str2, str3
expect_bigger str3, other_str2
