# ===========================================================================
# Memory manipulation and comparison
# ===========================================================================

.section .text

# Returns if two memory slices contain the same values.
#
# Inputs:
#   a0: Pointer to the first slice
#   a1: Size of the first slice
#   a2: Pointer to the second slice
#   a3: Size of the second slice
#
# Outputs:
#   a0: 1 if equal, otherwise 0.
.global "mem.Eq"
"mem.Eq":
	# We try to optimise the fast case.

	# Temporary registers.
	#define x_end t0
	#define x_ch  t1
	#define y_ch  t2

	.cfi_startproc

	# If the slices are different sizes, they cannot be equal.
	beq a1, a3, .LEq.check_ptrs

.LEq.returns_not_equal:
	li a0, 0
	ret

.LEq.check_ptrs:
	# We know that the sizes are equal.
	# Hence, if the base pointers are the same, they are equal.
	bne a0, a2, .LEq.check_contents

.LEq.returns_equal:
	li a0, 1
	ret

.LEq.check_contents:
	# This could easily be optimised by doing a first pass that
	# compares one or more dwords at a time. Maybe I'll come back

	# and revisit it at some point, if it's worth it.
	add x_end, a0, a1

.LEq.loop:
	bgeu a0, x_end, .LEq.returns_equal

	lbu x_ch, 0(a0)
	lbu y_ch, 0(a2)

	addi a0, a0, 1
	addi a2, a2, 1

	beq x_ch, y_ch, .LEq.loop
	j .LEq.returns_not_equal

	.cfi_endproc
