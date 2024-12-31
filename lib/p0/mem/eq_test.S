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
	la a0, \x\()_data
	li a1, \x\()_size
	la a2, \y\()_data
	li a3, \y\()_size
	call "mem.Eq"
	expect_nz a0
	restore_0
end_test
.endm

.macro reject x, y
test_case Eq_rejects_\x\()_and_\y
	save_0
	la a0, \x\()_data
	li a1, \x\()_size
	la a2, \y\()_data
	li a3, \y\()_size
	call "mem.Eq"
	expect_z a0
	restore_0
end_test
.endm


# ===========================================================================
# Test data
# ===========================================================================

.equiv nil_data, 0
.equiv nil_size, 0

.section .rodata

safe_str str0, ""
safe_str str1, "a"
safe_str str2, "ab"
safe_str str3, "abc"

safe_str copy_str0, ""
safe_str copy_str1, "a"
safe_str copy_str2, "ab"
safe_str copy_str3, "abc"

safe_str other_str1, "x"
safe_str other_str2, "xy"
safe_str other_str3, "xyz"

safe_str different_but_same_prefix_2, "ay"
safe_str different_but_same_prefix_3, "abz"


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

accept nil, nil

# Identical slices.
accept str0, str0
accept str1, str1
accept str2, str2
accept str3, str3

# Equal but not identical slices.
accept str0, copy_str0
accept str1, copy_str1
accept str2, copy_str2
accept str3, copy_str3

# Different slices.
reject str1, other_str1
reject str2, other_str2
reject str3, other_str3

# Different slices with a shared prefix.
reject str2, different_but_same_prefix_2
reject str3, different_but_same_prefix_3
