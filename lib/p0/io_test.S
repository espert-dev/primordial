# ===========================================================================
# write tests
# ===========================================================================

.include "inc/millicode.S"
.include "inc/safe_str.S"
.include "inc/testing.S"


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

.equiv valid_descriptor, 1
.equiv invalid_descriptor, 666

safe_str msg, "test message\n"


# ===========================================================================
# Test cases
# ===========================================================================

test_case write_ok
	save_0

	# Call function under test.
	li a0, valid_descriptor
	la a1, msg
	li a2, msg_size
	call "io.Write"

	expect_eq msg_size, a0
	expect_z a1

	restore_0
end_test

test_case write_fails_on_invalid_descriptor
	save_0

	# Call function under test.
	li a0, invalid_descriptor
	la a1, msg
	li a2, msg_size
	call "io.Write"

	expect_z a0
	expect_nz a1

	restore_0
end_test


# ===========================================================================
# Test suite
# ===========================================================================

test_suite
	run_test write_ok
	run_test write_fails_on_invalid_descriptor
end_suite

