# ===========================================================================
# ascii package tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

# Mnemonics:
#   s -> start
#   m -> middle
#   e -> end
safe_str char_list_0, ""
safe_str char_list_1, "s"
safe_str char_list_2, "se"
safe_str char_list_3, "sme"


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case IsLetter_accepts_lowercase_letters
	la a0, "ascii.IsLetter"
	li a1, 'a'
	li a2, 'z' + 1
	tail accept_range
end_test

test_case IsLetter_accepts_uppercase_letters
	la a0, "ascii.IsLetter"
	li a1, 'A'
	li a2, 'Z'
	tail accept_range
end_test

test_case IsLetter_rejects_lower_than_A
	la a0, "ascii.IsLetter"
	li a1, 0
	li a2, 'A' - 1
	tail reject_range
end_test

test_case IsLetter_rejects_higher_than_z
	la a0, "ascii.IsLetter"
	li a1, 'z' + 1
	li a2, 255
	tail reject_range
end_test

test_case IsLetter_rejects_between_Z_and_a
	la a0, "ascii.IsLetter"
	li a1, 'Z' + 1
	li a2, 'a' - 1
	tail reject_range
end_test

test_case IsLower_accepts_lowercase_letters
	la a0, "ascii.IsLower"
	li a1, 'a'
	li a2, 'z' + 1
	tail accept_range
end_test

test_case IsLower_rejects_uppercase_letters
	la a0, "ascii.IsLower"
	li a1, 'A'
	li a2, 'Z'
	tail reject_range
end_test

test_case IsUpper_accepts_uppercase_letters
	la a0, "ascii.IsUpper"
	li a1, 'A'
	li a2, 'Z'
	tail accept_range
end_test

test_case IsUpper_rejects_lowercase_letters
	la a0, "ascii.IsUpper"
	li a1, 'a'
	li a2, 'z' + 1
	tail reject_range
end_test

test_case IsDigit_accepts_digits
	la a0, "ascii.IsDigit"
	li a1, '0'
	li a2, '9'
	tail accept_range
end_test

test_case IsDigit_rejects_lower_than_0
	la a0, "ascii.IsDigit"
	li a1, 0
	li a2, '0' - 1
	tail reject_range
end_test

test_case IsDigit_rejects_higher_than_9
	la a0, "ascii.IsDigit"
	li a1, '9' + 1
	li a2, 255
	tail reject_range
end_test

test_case IsSpace_accepts_space
	la a0, "ascii.IsSpace"
	li a1, ' '
	tail accept_one
end_test

test_case IsSpace_accepts_form_feed
	la a0, "ascii.IsSpace"
	li a1, '\f'
	tail accept_one
end_test

test_case IsSpace_accepts_new_line
	la a0, "ascii.IsSpace"
	li a1, '\n'
	tail accept_one
end_test

test_case IsSpace_accepts_carriage_return
	la a0, "ascii.IsSpace"
	li a1, '\n'
	tail accept_one
end_test

test_case IsSpace_accepts_horizontal_tab
	la a0, "ascii.IsSpace"
	li a1, '\t'
	tail accept_one
end_test

test_case IsSpace_accepts_vertical_tab
	# Use 11 instead of '\v' because GNU as doesn't handle it correctly.
	la a0, "ascii.IsSpace"
	li a1, 11
	tail accept_one
end_test

test_case IsSpace_rejects_lowercase_letters
	la a0, "ascii.IsSpace"
	li a1, 'a'
	li a2, 'z'
	tail reject_range
end_test

test_case IsSpace_rejects_uppercase_letters
	la a0, "ascii.IsSpace"
	li a1, 'A'
	li a2, 'Z'
	tail reject_range
end_test

test_case IsSpace_rejects_range_0_to_8
	la a0, "ascii.IsSpace"
	li a1, 0
	li a2, 8
	tail reject_range
end_test

test_case IsSpace_rejects_range_14_to_31
	la a0, "ascii.IsSpace"
	li a1, 14
	li a2, 31
	tail reject_range
end_test

test_case IsSpace_rejects_range_33_to_255
	la a0, "ascii.IsSpace"
	li a1, 33
	li a2, 255
	tail reject_range
end_test

test_case Index_missing_0
	li a0, 'x'
	la a1, char_list_0_data
	li a2, char_list_0_size
	tail missing_Index
end_test

test_case Index_missing_1
	li a0, 'x'
	la a1, char_list_1_data
	li a2, char_list_1_size
	tail missing_Index
end_test

test_case Index_missing_2
	li a0, 'x'
	la a1, char_list_2_data
	li a2, char_list_2_size
	tail missing_Index
end_test

test_case Index_missing_3
	li a0, 'x'
	la a1, char_list_3_data
	li a2, char_list_3_size
	tail missing_Index
end_test

test_case Index_found_1
	li a0, 's'
	la a1, char_list_1_data
	li a2, char_list_1_size
	li a3, 0
	tail found_Index
end_test

test_case Index_found_2_start
	li a0, 's'
	la a1, char_list_2_data
	li a2, char_list_2_size
	li a3, 0
	tail found_Index
end_test

test_case Index_found_3_start
	li a0, 's'
	la a1, char_list_3_data
	li a2, char_list_3_size
	li a3, 0
	tail found_Index
end_test

test_case Index_found_2_end
	li a0, 'e'
	la a1, char_list_2_data
	li a2, char_list_2_size
	li a3, 1
	tail found_Index
end_test

test_case Index_found_3_end
	li a0, 'e'
	la a1, char_list_3_data
	li a2, char_list_3_size
	li a3, 2
	tail found_Index
end_test

test_case Index_found_3_middle
	li a0, 'm'
	la a1, char_list_3_data
	li a2, char_list_3_size
	li a3, 1
	tail found_Index
end_test


# ===========================================================================
# Test helpers
# ===========================================================================

# Inputs:
#   a0: function to test
#   a1: input value
accept_one:
	.cfi_startproc
	li a2, 1
	tail test_one
	.cfi_endproc

# Inputs:
#   a0: function to test
#   a1: input value
reject_one:
	.cfi_startproc
	li a2, 0
	tail test_one
	.cfi_endproc

# Inputs:
#   a0: function to test
#   a1: input value
#   a2: expected result
test_one:
	#define fn       s1
	#define expected s2

	.cfi_startproc
	save_2

	mv fn, a0
	mv expected, a2

	mv a0, a1
	jalr fn

	expect_eq expected, a0

	restore_2
	.cfi_endproc

	#undef fn
	#undef expected

# Inputs:
#   a0: function to test
#   a1: start of range (inclusive)
#   a2: end of range (inclusive)
accept_range:
	.cfi_startproc
	li a3, 1
	tail test_range
	.cfi_endproc

# Inputs:
#   a0: function to test
#   a1: start of range (inclusive)
#   a2: end of range (inclusive)
reject_range:
	.cfi_startproc
	li a3, 0
	tail test_range
	.cfi_endproc

# Inputs:
#   a0: function to test
#   a1: start of range (inclusive)
#   a2: end of range (inclusive)
#   a3: expected result (0 or 1)
test_range:
	#define fn           s1
	#define expected     s2
	#define ch           s3
	#define last_ch      s4

	.cfi_startproc
	save_4

	mv fn, a0
	mv ch, a1
	mv last_ch, a2
	mv expected, a3

	tail .Ltest_range.loop_cond

.Ltest_range.loop:
	# Call function under test.
	mv a0, ch
	jalr fn

	expect_eq expected, a0

	addi ch, ch, 1

.Ltest_range.loop_cond:
	bltu ch, last_ch, .Ltest_range.loop

	restore_4
	.cfi_endproc

	#undef fn
	#undef expected
	#undef ch
	#undef last_ch

# Inputs:
#   a0: char
#   a1: slice of characters
#   a2: size of slize
#   a3: expected index
found_Index:
	.cfi_startproc
	tail test_Index
	.cfi_endproc

# Inputs:
#   a0: char
#   a1: slice of characters
#   a2: size of slize
missing_Index:
	.cfi_startproc
	li a3, -1
	tail test_Index
	.cfi_endproc

# Inputs:
#   a0: char
#   a1: slice of characters
#   a2: size of slize
#   a3: expected index
test_Index:
	#define expected_idx s1

	.cfi_startproc
	save_1
	mv expected_idx, a3

	call "ascii.Index"
	expect_eq expected_idx, a0

	restore_1
	.cfi_endproc

	#undef expected_idx
