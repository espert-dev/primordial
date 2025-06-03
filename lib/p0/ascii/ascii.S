# ===========================================================================
# ASCII character testing functions
# ===========================================================================

# Matches [a-zA-Z]
.global "ascii.IsLetter"
"ascii.IsLetter":
	.cfi_startproc

	# c >= 'a' && c <= 'z'
	addi t0, a0, -'a'
	sltiu t0, t0, 'z' - 'a' + 1

	# c >= 'A' && c <= 'Z'
	addi t1, a0, -'A'
	sltiu t1, t1, 'Z' - 'A' + 1

	or a0, t0, t1
	ret

	.cfi_endproc

# Matches [a-z]
.global "ascii.IsLower"
"ascii.IsLower":
	.cfi_startproc

	# c >= 'A' && c <= 'Z'
	addi a0, a0, -'a'
	sltiu a0, a0, 'z' - 'a' + 1

	ret

	.cfi_endproc

# Matches [A-Z]
.global "ascii.IsUpper"
"ascii.IsUpper":
	.cfi_startproc

	# c >= 'A' && c <= 'Z'
	addi a0, a0, -'A'
	sltiu a0, a0, 'Z' - 'A' + 1

	ret

	.cfi_endproc

# Matches [0-9]
.global "ascii.IsDigit"
"ascii.IsDigit":
	.cfi_startproc

	# c >= '0' && c <= '9'
	addi a0, a0, -'0'
	sltiu a0, a0, '9' - '0' + 1
	ret

	.cfi_endproc


# Matches [ \f\n\r\t\v]
.global "ascii.IsSpace"
"ascii.IsSpace":
	.cfi_startproc

	# Contiguous range: "\t\n\v\f\r"
	addi t0, a0, -'\t'
	sltiu t0, t0, '\r' - '\t' + 1

	# Special case: ' '
	addi t1, a0, -' '
	seqz t1, t1

	or a0, t0, t1
	ret

	.cfi_endproc


# Matches any of the characters and returns its index.
#
# This function returns -1 on failure rather than a separate ok value because
# it's safer when bounds are checked (-1 is never a valid slice index), and
# because it generates more blatant failures when ignored. As an added bonus,
# it's also slightly faster.
#
# Inputs:
#   a0: Character
#   a1: Slice of characters
#   a2: Size of the slice
#
# Output:
#   a0: Matched index (-1 if none).
.global "ascii.Index"
"ascii.Index":
	.cfi_startproc

	# Temporary variables.
	#define p t0
	#define end t1
	#define candidate t2

	mv p, a1
	add end, a1, a2

	j .LIndex.loop_cond

.LIndex.loop:
	lbu candidate, 0(p)
	beq candidate, a0, .LIndex.found

	addi p, p, 1

.LIndex.loop_cond:
	bltu p, end, .LIndex.loop

.LIndex.missing:
	li a0, -1
	ret

.LIndex.found:
	sub a0, p, a1
	ret

	.cfi_endproc
