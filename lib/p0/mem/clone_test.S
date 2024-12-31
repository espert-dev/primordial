# ===========================================================================
# Memory cloning tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Read-only test data
# ===========================================================================

.section .rodata

.equiv nil, 0
.equiv nil_size, 0

safe_str original, "abc"


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Clone_nil_returns_nil
	save_0

	li a0, nil_size
	li a1, nil
	call "mem.Clone"

	expect_z a0
	expect_z a1

	restore_0
end_test

test_case Clone_size_0
	save_0

	li a0, 0
	la a1, original_data
	call "mem.Clone"

	expect_z a0
	expect_nz a1

	la t0, original_data
	expect_ne t0, a1

	restore_0
end_test

test_case Clone_size_1
	save_0

	li a0, 1
	la a1, original_data
	call "mem.Clone"

	expect_eqi 1, a0
	expect_nz a1

	la t0, original_data
	expect_ne t0, a1

	restore_0
end_test

test_case Clone_size_2
	save_0

	li a0, 2
	la a1, original_data
	call "mem.Clone"

	expect_eqi 2, a0
	expect_nz a1

	la t0, original_data
	expect_ne t0, a1

	restore_0
end_test

test_case Clone_size_3
	save_0

	li a0, 3
	la a1, original_data
	call "mem.Clone"

	expect_eqi 3, a0
	expect_nz a1

	la t0, original_data
	expect_ne t0, a1

	restore_0
end_test
