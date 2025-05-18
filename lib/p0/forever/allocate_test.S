# ===========================================================================
# forever package tests
# ===========================================================================

#include <millicode.S>
#include <testing.S>


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case can_write_to_allocated_memory_16b
	save_0

	# Call function under test.
	li a0, 16
	call "forever.Allocate"
	call assert_allocation_ok

	# Try writing to the allocated memory.
	#
	# This will fault if the memory is not allocated.
	# We allocated 16 bytes, so let's write two qwords.
	sd zero, 0(a0)
	sd zero, 8(a0)

	restore_0
end_test

test_case can_write_to_allocated_memory_64kib
	#define allocated_size s1
	#define end t0

	save_0

	li allocated_size, 65536

	# Call function under test.
	mv a0, allocated_size
	call "forever.Allocate"
	call assert_allocation_ok

	# Try writing to the allocated memory.
	#
	# This will fault if the memory is not allocated.

	#define p a0
	add end, p, allocated_size
0:

	bgeu p, end, 1f
	sd zero, 0(p)
	addi p, p, 8

1:
	restore_0

	#undef p
	#undef end
	#undef allocated_size
end_test


test_case allocated_addresses_are_unique
	#define first_ptr  s1
	#define second_ptr s2

	save_2

	# First allocation.
	li a0, 16
	call "forever.Allocate"
	mv first_ptr, a0
	call assert_allocation_ok

	# Second allocation.
	li a0, 16
	call "forever.Allocate"
	mv second_ptr, a0
	call assert_allocation_ok

	# Check that the pointers are different.
	expect_ne first_ptr, second_ptr

	restore_2

	#undef first_ptr
	#undef second_ptr
end_test

test_case requests_of_zero_allocate_memory
	#define first_ptr  s1
	#define second_ptr s2

	save_2

	# First allocation.
	li a0, 0
	call "forever.Allocate"
	mv first_ptr, a0
	call assert_allocation_ok

	# Second allocation.
	li a0, 0
	call "forever.Allocate"
	li second_ptr, 0
	call assert_allocation_ok

	# Check that the pointers are different.
	expect_ne first_ptr, second_ptr

	restore_2

	#undef first_ptr
	#undef second_ptr
end_test


# ===========================================================================
# Test helpers
# ===========================================================================

assert_allocation_ok:
	.cfi_startproc

	# Check that the object is not null.
	expect_nz a0

	# Check that the allocation succeeded.
	expect_z a1

	ret
	.cfi_endproc
