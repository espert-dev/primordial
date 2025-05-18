# ===========================================================================
# true: exits with 0
#
# Useful to check that the build works.
# ===========================================================================

.section .text

.global main
main:
	.cfi_startproc
	li a0, 0
	ret
	.cfi_endproc
