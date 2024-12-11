
.section .text

# Terminates the application. This function does NOT return.
#
# Inputs:
#   a0: Exit code
.global "os/exit"
"os/exit":
	.cfi_startproc
	.equiv SYSCALL_EXIT, 93
	li a7, SYSCALL_EXIT
	ecall
	.cfi_endproc
