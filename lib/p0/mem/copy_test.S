# ===========================================================================
# Memory copy tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Read-only test data
# ===========================================================================

.section .rodata

.equiv nil_data, 0
.equiv nil_size, 0

Xalign
safe_str source, "abc"


# ===========================================================================
# Writeable test data
# ===========================================================================

.section .bss

Xalign
.lcomm destination, source_size


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Copy_nil_ok
	save_0

	li a0, nil_size
	li a1, nil_data
	li a2, nil_size
	li a3, nil_data
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_0_to_0
	save_0

	li a0, 0
	la a1, source_data
	li a2, 0
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_1_to_0
	save_0

	li a0, 1
	la a1, source_data
	li a2, 0
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_2_to_0
	save_0

	li a0, 2
	la a1, source_data
	li a2, 0
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_3_to_0
	save_0

	li a0, 3
	la a1, source_data
	li a2, 0
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_0_to_1
	save_0

	li a0, 0
	la a1, source_data
	li a2, 1
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_1_to_1
	save_0

	li a0, 1
	la a1, source_data
	li a2, 1
	la a3, destination
	call "mem.Copy"

	expect_eqi 1, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1

	restore_0
end_test

test_case Copy_2_to_1
	save_0

	li a0, 2
	la a1, source_data
	li a2, 1
	la a3, destination
	call "mem.Copy"

	expect_eqi 1, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1

	restore_0
end_test

test_case Copy_3_to_1
	save_0

	li a0, 3
	la a1, source_data
	li a2, 1
	la a3, destination
	call "mem.Copy"

	expect_eqi 1, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1

	restore_0
end_test

test_case Copy_0_to_2
	save_0

	li a0, 0
	la a1, source_data
	li a2, 2
	la a3, destination
	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_1_to_2
	save_0

	li a0, 2
	la a1, source_data
	li a2, 1
	la a3, destination
	call "mem.Copy"

	expect_eqi 1, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1

	restore_0
end_test

test_case Copy_2_to_2
	save_0

	li a0, 2
	la a1, source_data
	li a2, 2
	la a3, destination
	call "mem.Copy"

	expect_eqi 2, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1
	lbu t1, 1(t0)
	expect_eqi 'b', t1

	restore_0
end_test

test_case Copy_3_to_2
	save_0

	li a0, 3
	la a1, source_data
	li a2, 2
	la a3, destination
	call "mem.Copy"

	expect_eqi 2, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1
	lbu t1, 1(t0)
	expect_eqi 'b', t1

	restore_0
end_test

test_case Copy_0_to_3
	save_0

	li a0, 0
	la a1, source_data
	li a2, 3
	la a3, destination

	call "mem.Copy"

	expect_z a0

	restore_0
end_test

test_case Copy_1_to_3
	save_0

	li a0, 1
	la a1, source_data
	li a2, 3
	la a3, destination
	call "mem.Copy"

	expect_eqi 1, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1

	restore_0
end_test

test_case Copy_2_to_3
	save_0

	li a0, 2
	la a1, source_data
	li a2, 3
	la a3, destination
	call "mem.Copy"

	expect_eqi 2, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1
	lbu t1, 1(t0)
	expect_eqi 'b', t1

	restore_0
end_test

test_case Copy_3_to_3
	save_0

	li a0, 3
	la a1, source_data
	li a2, 3
	la a3, destination
	call "mem.Copy"

	expect_eqi 3, a0

	la t0, destination
	lbu t1, 0(t0)
	expect_eqi 'a', t1
	lbu t1, 1(t0)
	expect_eqi 'b', t1
	lbu t1, 2(t0)
	expect_eqi 'c', t1

	restore_0
end_test
