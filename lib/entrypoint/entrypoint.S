# ===========================================================================
# Entrypoint for executables
# ===========================================================================

#include <syscall.S>

.section .text

.global _start
_start:
	.cfi_startproc

	# Prevent GDB from reporting a corrupt stack below _start.
	.cfi_undefined sp
	.cfi_undefined fp
	.cfi_undefined ra

	call main

	li a7, SYSCALL_EXIT
	ecall

	.cfi_endproc

