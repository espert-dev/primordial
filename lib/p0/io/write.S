# ===========================================================================
# Basic I/O functionality
# ===========================================================================

#include <syscall.S>

.section .text

# Write to a file descriptor.
#
# Input:
#   a0 fd:      File descriptor
#   a1 xs_size: Data size
#   a2 xs_data: Data pointer
#
# Output:
#   a0: Number of bytes written
#   a1: Error
.global "io.Write"
"io.Write":
	.cfi_startproc

	# Swap a1 and a2.
	mv t0, a1
	mv a1, a2
	mv a2, t0

	li a7, SYSCALL_WRITE
	ecall

	# After the syscall, x0 is an error if negative, or valid otherwise.
	blt a0, zero, .Lfail

	# Return (num_bytes, 0)
	li a1, 0
	ret

.Lfail:
	# Return (0, error)
	mv a1, a0
	li a0, 0
	ret

	.cfi_endproc
