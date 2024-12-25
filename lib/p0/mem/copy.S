# ===========================================================================
# Memory copy
# ===========================================================================

.section .text

# Copy Memory
#
# Input:
#   a0: source size
#   a1: source data
#   a2: destination size
#   a3: destination data
#
# Output:
#   a0: number of copied bytes
.global "mem.Copy"
"mem.Copy":
	#define end t0
	#define x   t1

	# a0 := min(a0, a2)
	blt a2, a0, .LCopy.adjust_size

.LCopy.calculate_end:
	# Pre-condition: a0 = min(a0, a2)
	add end, a1, a0
	bgeu a1, end, .LCopy.loop_end

.LCopy.loop:
	# Copy byte by byte because it's the simplest way.
	lbu x, 0(a1)
	sb x, 0(a3)

	# Advance pointers.
	addi a1, a1, 1
	addi a3, a3, 1

.LCopy.loop_cond:
	bltu a1, end, .LCopy.loop

.LCopy.loop_end:
	ret

.LCopy.adjust_size:
	# This is out of the way because in common usage it is more likely
	# that the sizes are equal or the source is smaller. This keeps the
	# common path a bit faster.
	mv a0, a2
	j .LCopy.calculate_end

	#undef end
	#undef x
