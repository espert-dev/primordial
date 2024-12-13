# ===========================================================================
# Millicode for procedure prologue and epilogue (1 saved register)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x20

.global prologue_1
prologue_1:
	.cfi_startproc
	.cfi_return_column t0
	addi sp, sp, -FRAME_SIZE
	sd fp, 0x00(sp)
	mv fp, sp
	sd ra, 0x08(fp)
	sd s1, 0x10(fp)
	jr t0
	.cfi_endproc

.global epilogue_1
epilogue_1:
	.cfi_startproc
	ld s1, 0x10(fp)
	ld ra, 0x08(fp)
	ld fp, 0x00(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc
