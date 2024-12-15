# ===========================================================================
# Memory manipulation and comparison -- Shortlex
# ===========================================================================

#include <millicode.S>


.section .text

# Compares two memory regions with the shortlex ordering.
#
# Input:
#   a0: Pointer to the first slice
#   a1: Size of the first slice
#   a2: Pointer to the second slice
#   a3: Size of the second slice
#
# Output:
#   a0: negative if x < y, 0 if x == y, positive if x > y
.global "mem/Shortlex"
"mem/Shortlex":
	# We try to optimise the fast case.

	# Temporary registers.
	#define x_end t0
	#define x_ch  t1
	#define y_ch  t2

	.cfi_startproc

	# If the slices are different sizes, they cannot be equal.
	beq a1, a3, .LShortlex.check_ptrs

.LShortlex.different_sizes:
	# Will be negative if x1 < x3, positive if x1 > x3.
	# It cannot be x1 == x3 because of the branch above.
	sub a0, a1, a3
	ret

.LShortlex.check_ptrs:
	# We know that the sizes are equal.
	# Hence, if the base pointers are the same, they are equal.
	bne a0, a2, .LShortlex.check_contents

.LShortlex.equal:
	li a0, 0
	ret

.LShortlex.check_contents:
	# This could easily be optimised by doing a first pass that
	# compares one or more dwords at a time. Maybe I'll come back
	# and revisit it at some point, if it's worth it.
	add x_end, a0, a1

.LShortlex.loop:
	bgeu a0, x_end, .LShortlex.equal

	lbu x_ch, 0(a0)
	lbu y_ch, 0(a2)
	add a0, a0, 1
	add a2, a2, 1
	beq x_ch, y_ch, .LShortlex.loop

.LShortlex.different_content:
	sub a0, x_ch, y_ch
	ret

	.cfi_endproc
