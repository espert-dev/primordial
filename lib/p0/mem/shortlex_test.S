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
	
	la a0, \x
	li a1, \x\()_size
	la a2, \y
	li a3, \y\()_size
	call "mem/Shortlex"
	
	expect_z a0

	restore_0
end_test
.endm

.macro expect_smaller x, y
test_case Shortlex_\x\()_and_\y\()_return_smaller
	save_0
	
	la a0, \x
	li a1, \x\()_size
	la a2, \y
	li a3, \y\()_size
	call "mem/Shortlex"
	
	expect_negative a0

	restore_0
end_test
.endm

.macro expect_bigger x, y
test_case Shortlex_\x\()_and_\y\()_return_bigger
	save_0
	
	la a0, \x
	li a1, \x\()_size
	la a2, \y
	li a3, \y\()_size
	call "mem/Shortlex"
	
	expect_positive a0

	restore_0
end_test
.endm


# ===========================================================================
# Test data
# ===========================================================================

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


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

expect_equal nil, nil

# Identical slices.
expect_equal s0, s0
expect_equal s1, s1
expect_equal s2, s2
expect_equal s3, s3

# Equal but not identical slices.
expect_equal s0, s0_copy
expect_equal s1, s1_copy
expect_equal s2, s2_copy
expect_equal s3, s3_copy

# Different slices of the same size, returning smaller.
expect_smaller s1, other_s1
expect_smaller s2, other_s2
expect_smaller s3, other_s3

# Different slices of the same size, returning bigger.
expect_bigger other_s1, s1
expect_bigger other_s2, s2
expect_bigger other_s3, s3

# Different but with a common prefix.
expect_smaller s2, different_but_same_prefix_2
expect_bigger different_but_same_prefix_2, s2

expect_smaller s3, different_but_same_prefix_3
expect_bigger different_but_same_prefix_3, s3

# The size decides against the lexicographical order.
expect_smaller other_s1, s2
expect_bigger s2, other_s1

expect_smaller other_s2, s3
expect_bigger s3, other_s2
