# ===========================================================================
# Hello, world!
#
# A classic. Also useful to check that basic IO and safe_str work.
# ===========================================================================

#include <millicode.S>
#include <io.S>
#include <safe_str.S>

.section .rodata

safe_str greeting, "Hello, primordial world!\n"

.section .text

.global main
main:
	.cfi_startproc
	save_0

	li a0, STDOUT
	li a1, greeting_size
	la a2, greeting_data
	call "io.Write"

	# Return error from io.Write.
	mv a0, a1

	restore_0
	.cfi_endproc
