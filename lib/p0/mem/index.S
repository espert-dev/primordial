# ===========================================================================
# Memory manipulation tests
# ===========================================================================

#include <millicode.S>


.section .text

# Checks if a byte slice matches any of a slice of byte slices and returns
# its index.
#
# This is useful, for example, when comparing a string against a list of
# strings.
#
# Inputs:
#   a0: Pointer to the byte slice
#   a1: Size of the slice
#   a2: Pointer to the slice of byte slices
#   a3: Size of the slice of byte slices
#
# Outputs:
#   a0: Matched index (or -1 if none)
.global "mem.Index"
"mem.Index":
	# Callee-saved registers.
	#define s_ptr    s1
	#define s_size   s2
	#define ss_ptr   s3
	#define ss_end   s4
	#define ss_pos   s5

	.cfi_startproc
	save_5

	li ss_pos,  0
	mv s_ptr,   a0
	mv s_size,  a1
	mv ss_ptr,  a2
	sll ss_end, a3, 4  # ss_size * 16
	add ss_end, ss_end, ss_ptr

.LIndex.loop:
	bgeu ss_ptr, ss_end, .LIndex.fail

	mv a0, s_size
	mv a1, s_ptr
	ld a2, 8(ss_ptr)
	ld a3, 0(ss_ptr)
	call "mem.Eq"
	bnez a0, .LIndex.ok

	add ss_pos, ss_pos, 1
	add ss_ptr, ss_ptr, 16
	j .LIndex.loop

.LIndex.fail:
	li a0, -1
	j .LIndex.end

.LIndex.ok:
	mv a0, ss_pos

.LIndex.end:
	restore_5
	.cfi_endproc
