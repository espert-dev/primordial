# ===========================================================================
# Entrypoint for executables
# ===========================================================================

.section .text

.global _start
_start:
	.cfi_startproc

	# Prevent GDB from reporting a corrupt stack below _start.
	.cfi_undefined sp
	.cfi_undefined fp
	.cfi_undefined ra

	call main
	call "os/exit"

	.cfi_endproc

