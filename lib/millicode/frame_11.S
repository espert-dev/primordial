# ===========================================================================
# Millicode for procedure prologue and epilogue (11 saved registers)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x70

.global prologue_11
prologue_11:
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
	sd s6, 0x38(fp)
	sd s7, 0x40(fp)
	sd s8, 0x48(fp)
	sd s9, 0x50(fp)
	sd s10, 0x58(fp)
	sd s11, 0x60(fp)
	jr t0
	.cfi_endproc

.global epilogue_11
epilogue_11:
	.cfi_startproc
	ld s11, 0x60(fp)
	ld s10, 0x58(fp)
	ld s9, 0x50(fp)
	ld s8, 0x48(fp)
	ld s7, 0x40(fp)
	ld s6, 0x38(fp)
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
