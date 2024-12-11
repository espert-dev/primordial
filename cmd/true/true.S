# A program that returns an exit code of 0.
#
# Useful to check that the build works.

.section .text

.global _start
_start:
	li a0, 0
	jal "os/exit"

