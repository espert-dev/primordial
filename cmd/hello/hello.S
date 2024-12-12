# ===========================================================================
# Hello, world!
#
# A classic. Also useful to check that basic IO and safe_str work.
# ===========================================================================

.include "inc/io.S"
.include "inc/safe_str.S"

.section .rodata

safe_str greeting, "Hello, primordial world!\n"

.section .text

.global main
main:
	.cfi_startproc
	addi sp, sp, -16
	sd fp, 0(sp)
	mv fp, sp
	sd ra, 8(fp)

	li a0, STDOUT
	la a1, greeting
	li a2, greeting_size
	call "io.Write"

	# Return error from io.Write.
	mv a0, a1

	ld ra, 8(fp)
	ld fp, 0(fp)
	addi sp, sp, 16
	ret
	.cfi_endproc

