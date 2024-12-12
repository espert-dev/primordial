# ===========================================================================
# Common operating system functionality
# ===========================================================================

.section .text

.include "inc/syscall.S"

# Terminates the application. This function does NOT return.
#
# Input:
#   a0: Exit code
.global "os/exit"
"os/exit":
	.cfi_startproc
	li a7, SYSCALL_EXIT
	ecall
	.cfi_endproc
