# ===========================================================================
# String interning tests
# ===========================================================================

# Include the source directly because this is an internal test.
#include "strintern.S"

#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

safe_str str0, "bb"
safe_str str0_copy, "bb"

safe_str smaller_1, "a"
safe_str smaller_1_copy, "a"

safe_str bigger_1, "zzz"
safe_str bigger_1_copy, "zzz"

safe_str strs, "abcdefghijklmnopqrstuvwxyz"
safe_str strs_copy, "abcdefghijklmnopqrstuvwxyz"


# ===========================================================================
# Test cases
# ===========================================================================

test_case sentinel_has_expected_size
	li t0, "strintern.sentinel_size"
	li t1, "strintern.node_size"
	expect_eq t0, t1
	ret
end_test

test_case sentinel_left_and_right_point_to_itself
	#define sentinel t0
	#define l        t1
	#define r        t2

	la sentinel, "strintern.sentinel"

	lx l, "strintern.node.left"(sentinel)
	expect_eq sentinel, l

	lx r, "strintern.node.right"(sentinel)
	expect_eq sentinel, r

	ret

	#undef sentinel
	#undef l
	#undef r
end_test

test_case Intern_first_string
	save_0
	call cleanSlate

	li a0, str0_size
	la a1, str0_data
	mv a2, a0
	mv a3, a1
	call expectIntern

	restore_0
end_test

test_case Intern_first_string_twice
	save_0
	call cleanSlate

	li a0, str0_size
	la a1, str0_data
	mv a2, a0
	mv a3, a1
	call expectIntern

	li a0, str0_copy_size
	la a1, str0_copy_data
	li a2, str0_size
	la a3, str0_data
	call expectIntern

	restore_0
end_test

test_case Intern_smaller
	save_0
	call cleanSlate

	li a0, str0_size
	la a1, str0_data
	mv a2, a0
	mv a3, a1
	call expectIntern

	li a0, smaller_1_size
	la a1, smaller_1_data
	li a2, smaller_1_size
	la a3, smaller_1_data
	call expectIntern

	li a0, smaller_1_copy_size
	la a1, smaller_1_copy_data
	li a2, smaller_1_size
	la a3, smaller_1_data
	call expectIntern

	restore_0
end_test

test_case Intern_bigger
	save_0
	call cleanSlate

	li a0, str0_size
	la a1, str0_data
	mv a2, a0
	mv a3, a1
	call expectIntern

	li a0, bigger_1_size
	la a1, bigger_1_data
	li a2, bigger_1_size
	la a3, bigger_1_data
	call expectIntern

	li a0, bigger_1_copy_size
	la a1, bigger_1_copy_data
	li a2, bigger_1_size
	la a3, bigger_1_data
	call expectIntern

	restore_0
end_test

test_case Intern_many
	# Callee-saved registers.
	#define p   s1
	#define end s2

	save_2
	call cleanSlate

	la p, strs_data
	addi end, p, strs_size

.LIntern_many_loop:
	li a0, 1
	mv a1, p
	mv a2, a0
	mv a3, a1
	call expectIntern

	add p, p, 1
	bltu p, end, .LIntern_many_loop

	restore_2

	#undef p
	#undef end
end_test

test_case Intern_many_twice
	# Callee-saved registers.
	#define p   s1
	#define end s2

	# Inserts a lot of size-1 strings.
	save_2
	call cleanSlate

	la p, strs_data
	add end, p, strs_size

.LIntern_many_loop_1:
	li a0, 1
	mv a1, p
	mv a2, a0
	mv a3, a1
	call expectIntern

	addi p, p, 1
	bltu p, end, .LIntern_many_loop_1

	la p, strs_data

.LIntern_many_loop_2:
	li a0, 1
	mv a1, p
	mv a2, a0
	mv a3, a1
	call expectIntern

	add p, p, 1
	bltu p, end, .LIntern_many_loop_2

	restore_2

	#undef p
	#undef end
end_test

test_case Intern_many_and_copies
	# Callee-saved registers.
	#define p      s1
	#define end    s2
	#define p_copy s3

	# Inserts a lot of size-1 strings.
	save_3
	call cleanSlate

	la p, strs_data
	add end, p, strs_size

.LIntern_many_and_copies_loop_1:
	li a0, 1
	mv a1, p
	mv a2, a0
	mv a3, a1
	call expectIntern

	addi p, p, 1
	bltu p, end, .LIntern_many_and_copies_loop_1

	la p_copy, strs_copy_data
	la p, strs_data
	add end, p, strs_size

.LIntern_many_and_copies_loop_2:
	li a0, 1
	mv a1, p_copy
	li a2, 1
	mv a3, p
	call expectIntern

	addi p, p, 1
	addi p_copy, p_copy, 1
	bltu p, end, .LIntern_many_and_copies_loop_2

	restore_3

	#undef p
	#undef end
	#undef p_copy
end_test


# ===========================================================================
# Test helpers
# ===========================================================================

.section .text

# Clean the interned string set.
#
# Leaks memory. Only for use in tests.
cleanSlate:
	#define sentinel t0
	#define root     t1

	.cfi_startproc
	la sentinel, "strintern.sentinel"
	la root, "strintern.root"
	sx sentinel, 0(root)
	ret
	.cfi_endproc

	#undef sentinel
	#undef root


# Inputs:
#   a0: input string data
#   a1: input string size
#   a2: expected string data
#   a3: expected string size
expectIntern:
	#define expected_size s1
	#define expected_data s2

	.cfi_startproc
	save_2

	mv expected_size, a2
	mv expected_data, a3

	# a0 and a1 are already set.
	call "strintern.Intern"

	mv a2, expected_size
	mv a3, expected_data
	call "mem.Eq"

	expect_eqi 1, a0

	restore_2
	.cfi_endproc

	#undef expected_date
	#undef expected_size
