# ===========================================================================
# Millicode for procedure prologue and epilogue (2 saved registers)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x20

.global prologue_2
prologue_2:
	.cfi_startproc
	addi sp, sp, -FRAME_SIZE
	sd fp, 0x00(sp)
	mv fp, sp
	sd ra, 0x08(fp)
	sd s1, 0x10(fp)
	sd s2, 0x18(fp)
	jr t0
	.cfi_endproc

.global epilogue_2
epilogue_2:
	.cfi_startproc
	ld s2, 0x18(fp)
	ld s1, 0x10(fp)
	ld ra, 0x08(fp)
	ld fp, 0x00(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc
