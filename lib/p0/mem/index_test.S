# ===========================================================================
# memory manipulation tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

# TODO minimise
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

test_case Index_nil_and_nil
	save_0

	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	call "mem.Index"

	expect_eqi -1, a0

	restore_0
end_test

test_case Index_s3_and_nil
	save_0

	la a0, s3
	li a1, s3_size
	li a2, 0
	li a3, 0
	call "mem.Index"

	expect_eqi -1, a0

	restore_0
end_test

test_case Index_s3_and_bss_0
	save_0

	la a0, s3
	li a1, s3_size
	la a2, bss_0
	li a3, bss_0_size
	call "mem.Index"

	expect_eqi -1, a0

	restore_0
end_test

test_case Index_s3_and_bss_1
	save_0

	la a0, s3
	li a1, s3_size
	la a2, bss_1
	li a3, bss_1_size
	call "mem.Index"

	expect_z a0

	restore_0
end_test

test_case Index_s3_and_bss_2
	save_0

	la a0, s3
	li a1, s3_size
	la a2, bss_2
	li a3, bss_2_size
	call "mem.Index"

	expect_z a0

	restore_0
end_test

test_case Index_other_s3_and_bss_2
	save_0

	la a0, other_s3
	li a1, other_s3_size
	la a2, bss_2
	li a3, bss_2_size
	call "mem.Index"

	expect_eqi 1, a0

	restore_0
end_test

test_case Index_s3_and_bss_3
	save_0

	la a0, s3
	li a1, s3_size
	la a2, bss_3
	li a3, bss_3_size
	call "mem.Index"

	expect_z a0

	restore_0
end_test

test_case Index_other_s3_and_bss_3
	save_0

	la a0, other_s3
	li a1, other_s3_size
	la a2, bss_3
	li a3, bss_3_size
	call "mem.Index"

	expect_eqi 1, a0

	restore_0
end_test

test_case Index_different_but_same_prefix_2_and_bss_3
	save_0

	la a0, different_but_same_prefix_2
	li a1, different_but_same_prefix_2_size
	la a2, bss_3
	li a3, bss_3_size
	call "mem.Index"

	expect_eqi 2, a0

	restore_0
end_test

test_case Index_different_but_same_prefix_3_and_bss_3
	save_0

	la a0, different_but_same_prefix_3
	li a1, different_but_same_prefix_3_size
	la a2, bss_3
	li a3, bss_3_size
	call "mem.Index"

	expect_eqi -1, a0
	restore_0
end_test
