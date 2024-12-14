# ===========================================================================
# Memory manipulation and comparison tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

safe_str s0, ""
safe_str s1, "a"
safe_str s2, "ab"
safe_str s3, "abc"

safe_str copy_s0, ""
safe_str copy_s1, "a"
safe_str copy_s2, "ab"
safe_str copy_s3, "abc"

safe_str other_s1, "x"
safe_str other_s2, "xy"
safe_str other_s3, "xyz"

safe_str different_but_same_prefix_2, "ay"
safe_str different_but_same_prefix_3, "abz"


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Eq_two_nil_slices
	li a0, 0
	li a1, 0
	la a2, 0
	li a3, 0
	j acceptEq
end_test

test_case Eq_two_identical_slices_0
	la a0, s0
	li a1, s0_size
	la a2, s0
	li a3, s0_size
	j acceptEq
end_test

test_case Eq_two_identical_slices_1
	la a0, s1
	li a1, s1_size
	la a2, s1
	li a3, s1_size
	j acceptEq
end_test

test_case Eq_two_identical_slices_2
	la a0, s2
	li a1, s2_size
	la a2, s2
	li a3, s2_size
	j acceptEq
end_test

test_case Eq_two_identical_slices_3
	la a0, s3
	li a1, s3_size
	la a2, s3
	li a3, s3_size
	j acceptEq
end_test

test_case Eq_two_equal_slices_0
	la a0, s0
	li a1, s0_size
	la a2, copy_s0
	li a3, copy_s0_size
	j acceptEq
end_test

test_case Eq_two_equal_slices_1
	la a0, s1
	li a1, s1_size
	la a2, copy_s1
	li a3, copy_s1_size
	j acceptEq
end_test

test_case Eq_two_equal_slices_2
	la a0, s2
	li a1, s2_size
	la a2, copy_s2
	li a3, copy_s2_size
	j acceptEq
end_test

test_case Eq_two_equal_slices_3
	la a0, s3
	li a1, s3_size
	la a2, copy_s3
	li a3, copy_s3_size
	j acceptEq
end_test

test_case Eq_two_different_slices_1
	la a0, s1
	li a1, s1_size
	la a2, other_s1
	li a3, other_s1_size
	j rejectEq
end_test

test_case Eq_two_different_slices_2
	la a0, s2
	li a1, s2_size
	la a2, other_s2
	li a3, other_s2_size
	j rejectEq
end_test

test_case Eq_two_different_slices_3
	la a0, s3
	li a1, s3_size
	la a2, other_s3
	li a3, other_s3_size
	j rejectEq
end_test

test_case Eq_different_but_same_prefix_2
	la a0, s2
	li a1, s2_size
	la a2, different_but_same_prefix_2
	li a3, different_but_same_prefix_2_size
	j rejectEq
end_test

test_case Eq_different_but_same_prefix_3
	la a0, s3
	li a1, s3_size
	la a2, different_but_same_prefix_3
	li a3, different_but_same_prefix_3_size
	j rejectEq
end_test


# ===========================================================================
# Test helpers
# ===========================================================================

acceptEq:
	.cfi_startproc
	save_0

	call "mem.Eq"
	expect_nz a0

	restore_0
	.cfi_endproc

rejectEq:
	.cfi_startproc
	save_0

	call "mem.Eq"
	expect_z a0

	restore_0
	.cfi_endproc
