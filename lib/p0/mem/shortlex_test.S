# ===========================================================================
# Memory manipulation and comparison -- Shortlex
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

# TODO minimise

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

# In case you're wondering, this stands for "byte slice slice".
bss_0:
.equiv bss_0_size, 0

bss_1:
.quad s3, s3_size
.equiv bss_1_size, 1

bss_2:
.quad s3, s3_size
.quad other_s3, other_s3_size
.equiv bss_2_size, 2

bss_3:
.quad s3, s3_size
.quad other_s3, other_s3_size
.quad different_but_same_prefix_2, different_but_same_prefix_2_size
.equiv bss_3_size, 3


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Shortlex_two_nil_slices
	li a0, 0
	li a1, 0
	la a2, 0
	li a3, 0
	j shortlexEq
end_test

test_case Shortlex_two_identical_slices_0
	la a0, s0
	li a1, s0_size
	la a2, s0
	li a3, s0_size
	j shortlexEq
end_test

test_case Shortlex_two_identical_slices_1
	la a0, s1
	li a1, s1_size
	la a2, s1
	li a3, s1_size
	j shortlexEq
end_test

test_case Shortlex_two_identical_slices_2
	la a0, s2
	li a1, s2_size
	la a2, s2
	li a3, s2_size
	j shortlexEq
end_test

test_case Shortlex_two_identical_slices_3
	la a0, s3
	li a1, s3_size
	la a2, s3
	li a3, s3_size
	j shortlexEq
end_test

test_case Shortlex_two_equal_slices_0
	la a0, s0
	li a1, s0_size
	la a2, copy_s0
	li a3, copy_s0_size
	j shortlexEq
end_test

test_case Shortlex_two_equal_slices_1
	la a0, s1
	li a1, s1_size
	la a2, copy_s1
	li a3, copy_s1_size
	j shortlexEq
end_test

test_case Shortlex_two_equal_slices_2
	la a0, s2
	li a1, s2_size
	la a2, copy_s2
	li a3, copy_s2_size
	j shortlexEq
end_test

test_case Shortlex_two_equal_slices_3
	la a0, s3
	li a1, s3_size
	la a2, copy_s3
	li a3, copy_s3_size
	j shortlexEq
end_test

test_case Shortlex_two_different_slices_1_lt
	la a0, s1
	li a1, s1_size
	la a2, other_s1
	li a3, other_s1_size
	j shortlexLt
end_test

test_case Shortlex_two_different_slices_2_lt
	la a0, s2
	li a1, s2_size
	la a2, other_s2
	li a3, other_s2_size
	j shortlexLt
end_test

test_case Shortlex_two_different_slices_3_lt
	la a0, s3
	li a1, s3_size
	la a2, other_s3
	li a3, other_s3_size
	j shortlexLt
end_test

test_case Shortlex_two_different_slices_1_gt
	la a0, other_s1
	li a1, other_s1_size
	la a2, s1
	li a3, s1_size
	j shortlexGt
end_test

test_case Shortlex_two_different_slices_2_gt
	la a0, other_s2
	li a1, other_s2_size
	la a2, s2
	li a3, s2_size
	j shortlexGt
end_test

test_case Shortlex_two_different_slices_3_gt
	la a0, other_s3
	li a1, other_s3_size
	la a2, s3
	li a3, s3_size
	j shortlexGt
end_test

test_case Shortlex_different_but_same_prefix_2_lt
	la a0, s2
	li a1, s2_size
	la a2, different_but_same_prefix_2
	li a3, different_but_same_prefix_2_size
	j shortlexLt
end_test

test_case Shortlex_different_but_same_prefix_3_lt
	la a0, s3
	li a1, s3_size
	la a2, different_but_same_prefix_3
	li a3, different_but_same_prefix_3_size
	j shortlexLt
end_test

test_case Shortlex_different_but_same_prefix_2_gt
	la a0, different_but_same_prefix_2
	li a1, different_but_same_prefix_2_size
	la a2, s2
	li a3, s2_size
	j shortlexGt
end_test

test_case Shortlex_different_but_same_prefix_3_gt
	la a0, different_but_same_prefix_3
	li a1, different_but_same_prefix_3_size
	la a2, s3
	li a3, s3_size
	j shortlexGt
end_test

test_case Shortlex_size_decides_2_lt
	la a0, other_s1
	li a1, other_s1_size
	la a2, s2
	li a3, s2_size
	j shortlexLt
end_test

test_case Shortlex_size_decides_3_lt
	la a0, other_s2
	li a1, other_s2_size
	la a2, s3
	li a3, s3_size
	j shortlexLt
end_test

test_case Shortlex_size_decides_2_gt
	la a0, s2
	li a1, s2_size
	la a2, other_s1
	li a3, other_s1_size
	j shortlexGt
end_test

test_case Shortlex_size_decides_3_gt
	la a0, s3
	li a1, s3_size
	la a2, other_s2
	li a3, other_s2_size
	j shortlexGt
end_test


# ===========================================================================
# Test helpers
# ===========================================================================

shortlexEq:
	.cfi_startproc
	save_0

	call "mem/Shortlex"
	expect_z a0

	restore_0
	.cfi_endproc

shortlexLt:
	.cfi_startproc
	save_0

	call "mem/Shortlex"
	expect_negative a0

	restore_0
	.cfi_endproc

shortlexGt:
	.cfi_startproc
	save_0

	call "mem/Shortlex"
	expect_positive a0

	restore_0
	.cfi_endproc
