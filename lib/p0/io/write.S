# ===========================================================================
# Basic I/O functionality
# ===========================================================================

#include "syscall.S"

.section .text

# Write to a file descriptor.
#
# Input:
#   a0: File descriptor
#   a1: Data pointer
#   a2: Data size
#
# Output:
#   a0: Number of bytes written
#   a1: Error
.global "io.Write"
"io.Write":
	.cfi_startproc

	li a7, SYSCALL_WRITE
	ecall

	# After the syscall, x0 is an error if negative, or valid otherwise.
	blt a0, x0, .Lfail

	# Return (num_bytes, 0)
	li a1, 0
	ret

.Lfail:
	# Return (0, error)
	mv a1, a0
	li a0, 0
	ret

	.cfi_endproc
