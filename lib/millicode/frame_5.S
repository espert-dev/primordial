# ===========================================================================
# Millicode for procedure prologue and epilogue (5 saved registers)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x40

.global prologue_5
prologue_5:
	.cfi_startproc
	.cfi_return_column t0
	addi sp, sp, -FRAME_SIZE
	sd fp, 0x00(sp)
	mv fp, sp
	sd ra, 0x08(fp)
	sd s1, 0x10(fp)
	sd s2, 0x18(fp)
	sd s3, 0x20(fp)
	sd s4, 0x28(fp)
	sd s5, 0x30(fp)
	jr t0
	.cfi_endproc

.global epilogue_5
epilogue_5:
	.cfi_startproc
	ld s5, 0x30(fp)
	ld s4, 0x28(fp)
	ld s3, 0x20(fp)
	ld s2, 0x18(fp)
	ld s1, 0x10(fp)
	ld ra, 0x08(fp)
	ld fp, 0x00(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc
