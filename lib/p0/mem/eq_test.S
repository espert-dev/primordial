# ===========================================================================
# Memory manipulation and comparison tests - Eq
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test macros
# ===========================================================================

.macro accept x, y
test_case Eq_accepts_\x\()_and_\y
	save_0
	la a0, \x
	li a1, \x\()_size
	la a2, \y
	li a3, \y\()_size
	call "mem.Eq"
	expect_nz a0
	restore_0
end_test
.endm

.macro reject x, y
test_case Eq_rejects_\x\()_and_\y
	save_0
	la a0, \x
	li a1, \x\()_size
	la a2, \y
	li a3, \y\()_size
	call "mem.Eq"
	expect_z a0
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

accept nil, nil

# Identical slices.
accept s0, s0
accept s1, s1
accept s2, s2
accept s3, s3

# Equal but not identical slices.
accept s0, copy_s0
accept s1, copy_s1
accept s2, copy_s2
accept s3, copy_s3

# Different slices.
reject s1, other_s1
reject s2, other_s2
reject s3, other_s3

# Different slices with a shared prefix.
reject s2, different_but_same_prefix_2
reject s3, different_but_same_prefix_3
