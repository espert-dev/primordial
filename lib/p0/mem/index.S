# ===========================================================================
# Memory manipulation tests
# ===========================================================================

#include <compat.S>
#include <millicode.S>
#include <slice.S>


.section .text

# Checks if a byte slice matches any of a slice of byte slices and returns
# its index.
#
# This is useful, for example, when comparing a string against a list of
# strings.
#
# Input:
#   a0 xs_size:  Size of the slice
#   a1 xs_data:  Pointer to the byte slice
#   a2 yss_size: Size of the slice of byte slices
#   a3 yss_data: Pointer to the slice of byte slices
#
# Output:
#   a0: Matched index (or -1 if none)
.global "mem.Index"
"mem.Index":
	# Callee-saved registers.
	#define pos      s1
	#define xs_size  s2
	#define xs_data  s3
	#define yss_data s4
	#define yss_end  s5

	.cfi_startproc
	save_5

	li pos, 0
	mv xs_size, a0
	mv xs_data, a1
	mv yss_data, a3

#if XLEN == 32
	sll yss_end, a2, 3  # Entries are 8 bytes.
#elif XLEN == 64
	sll yss_end, a2, 4  # Entries are 16 bytes.
#else
	#error invalid or unspecified XLEN
#endif

	add yss_end, yss_end, yss_data

.LIndex.loop:
	bgeu yss_data, yss_end, .LIndex.fail

	mv a0, xs_size
	mv a1, xs_data
	lx a2, slice.size(yss_data)
	lx a3, slice.data(yss_data)
	call "mem.Eq"
	bnez a0, .LIndex.ok

	add pos, pos, 1

#if XLEN == 32
	add yss_data, yss_data, 8
#elif XLEN == 64
	add yss_data, yss_data, 16
#else
	#error invalid or unspecified XLEN
#endif

	j .LIndex.loop

.LIndex.fail:
	li a0, -1
	j .LIndex.end

.LIndex.ok:
	mv a0, pos

.LIndex.end:
	restore_5
	.cfi_endproc
