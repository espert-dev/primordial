# ===========================================================================
# Millicode for procedure prologue and epilogue (0 saved registers)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x10

.global prologue_0
prologue_0:
	.cfi_startproc
	addi sp, sp, -FRAME_SIZE
	sd fp, 0x00(sp)
	.cfi_return_column t0
	mv fp, sp
	sd ra, 0x08(fp)
	jr t0
	.cfi_endproc

.global epilogue_0
epilogue_0:
	.cfi_startproc
	ld ra, 0x08(fp)
	ld fp, 0x00(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc
