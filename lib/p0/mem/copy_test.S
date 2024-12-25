# ===========================================================================
# Memory copy tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

.equiv nil, 0
.equiv nil_size, 0

safe_str empty_src, ""

.section .data

empty_dst:
.equiv empty_dst_size, 0


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Copy_nil_ok
	save_0

	li a0, nil_size
	li a1, nil
	li a2, nil_size
	li a3, nil
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_empty_ok
	save_0

	li a0, empty_src_size
	la a1, empty_src
	li a2, empty_dst_size
	la a3, empty_dst
	call "mem.Copy"

	expect_z a0

	restore_0
end_test
