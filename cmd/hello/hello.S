# ===========================================================================
# Hello, world!
#
# A classic. Also useful to check that basic IO and safe_str work.
# ===========================================================================

.include "inc/millicode.S"
.include "inc/io.S"
.include "inc/safe_str.S"

.section .rodata

safe_str greeting, "Hello, primordial world!\n"

.section .text

.global main
main:
	.cfi_startproc
	save_0

	li a0, STDOUT
	la a1, greeting
	li a2, greeting_size
	call "io.Write"

	# Return error from io.Write.
	mv a0, a1

	restore_0
	.cfi_endproc

