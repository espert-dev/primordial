# ===========================================================================
# read tests
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

.section .rodata

.equiv valid_descriptor, 0
.equiv invalid_descriptor, 666

safe_str expected, "Well begun is half done.\n"


.section .bss

# Output buffer.
.equiv buffer_size, 64
.lcomm buffer_data, buffer_size


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case read_ok
	save_0

	# Call function under test.
	li a0, valid_descriptor
	li a1, 75
	la a2, buffer_data
	call "io.Read"

	expect_eqi expected_size, a0
	expect_z a1

	li t0, expected_size
	bne t0, a0, .Lok.fail

	mv a2, a0
	li a0, expected_size
	la a1, expected_data
	la a3, buffer_data
	call "mem.Eq"
	expect_eqi 1, a0

.Lok.fail:
	restore_0
end_test

test_case read_fails_on_invalid_descriptor
	save_0

	# Call function under test.
	li a0, invalid_descriptor
	li a1, buffer_size
	la a2, buffer_data
	call "io.Read"

	expect_z a0
	expect_nz a1

	restore_0
end_test
