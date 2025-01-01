# ===========================================================================
# Memory manipulation and comparison -- Shortlex
# ===========================================================================

#include <millicode.S>


.section .text

# Compares two memory regions with the shortlex ordering.
#
# Input:
#   a0 xs_size: Size of the first slice
#   a1 xs_data: Pointer to the first slice
#   a2 ys_size: Size of the second slice
#   a3 ys_data: Pointer to the second slice
#
# Output:
#   a0: negative if x < y, 0 if x == y, positive if x > y
.global "mem/Shortlex"
"mem/Shortlex":
	# Arguments.
	#define xs_size a0
	#define xs_data a1
	#define ys_size a2
	#define ys_data a3

	# Temporary registers.
	#define xs_end t0
	#define x      t1
	#define y      t2

	.cfi_startproc
	# We try to optimise the fast case.

	# If the slices are different sizes, they cannot be equal.
	beq xs_size, ys_size, .LShortlex.check_ptrs

.LShortlex.different_sizes:
	# Will be negative if x1 < x3, positive if x1 > x3.
	# It cannot be x1 == x3 because of the branch above.
	sub a0, xs_size, ys_size
	ret

.LShortlex.check_ptrs:
	# We know that the sizes are equal.
	# Hence, if the base pointers are the same, they are equal.
	bne xs_data, ys_data, .LShortlex.check_contents

.LShortlex.equal:
	li a0, 0
	ret

.LShortlex.check_contents:
	# This could easily be optimised by doing a first pass that
	# compares one or more dwords at a time. Maybe I'll come back
	# and revisit it at some point, if it's worth it.
	add xs_end, xs_data, xs_size

.LShortlex.loop:
	bgeu xs_data, xs_end, .LShortlex.equal

	lbu x, 0(xs_data)
	lbu y, 0(ys_data)
	add xs_data, xs_data, 1
	add ys_data, ys_data, 1
	beq x, y, .LShortlex.loop

.LShortlex.different_content:
	sub a0, x, y
	ret

	.cfi_endproc
