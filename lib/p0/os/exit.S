# ===========================================================================
# Common operating system functionality
# ===========================================================================

.section .text

#include "syscall.S"

# Terminates the application. This function does NOT return.
#
# Input:
#   a0: Exit code
.global "os.Exit"
"os.Exit":
	.cfi_startproc
	li a7, SYSCALL_EXIT
	ecall
	.cfi_endproc
