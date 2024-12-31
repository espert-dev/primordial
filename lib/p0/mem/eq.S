# ===========================================================================
# Memory manipulation and comparison
# ===========================================================================

.section .text

# Tests if two memory slices contain the same values.
#
# Input:
#   a0 xs_size: Size of the first slice
#   a1 xs_data: Pointer to the first slice
#   a2 ys_size: Size of the second slice
#   a3 ys_data: Pointer to the second slice
#
# Output:
#   a0: 1 if equal, otherwise 0.
.global "mem.Eq"
"mem.Eq":
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

	# If the slices are different sizes, they cannot be equal.
	beq xs_size, ys_size, .LEq.check_ptrs

.LEq.returns_not_equal:
	li a0, 0
	ret

.LEq.check_ptrs:
	# We know that the sizes are equal.
	# Hence, if the base pointers are the same, they are equal.
	bne xs_data, ys_data, .LEq.check_contents

.LEq.returns_equal:
	li a0, 1
	ret

.LEq.check_contents:
	# This could easily be optimised by doing a first pass that
	# compares one or more dwords at a time. Maybe I'll come back
	# and revisit it at some point, if it's worth it.
	add xs_end, xs_size, xs_data

.LEq.loop:
	bgeu xs_data, xs_end, .LEq.returns_equal

	lbu x, 0(xs_data)
	lbu y, 0(ys_data)

	addi xs_data, xs_data, 1
	addi ys_data, ys_data, 1

	beq x, y, .LEq.loop
	j .LEq.returns_not_equal

	.cfi_endproc
