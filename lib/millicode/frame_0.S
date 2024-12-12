# ===========================================================================
# Millicode for procedure prologue and epilogue (0 saved registers)
# ===========================================================================

.section .text

#define FRAME_SIZE 0x10

.global prologue_0
prologue_0:
	# Do NOT add CFI declarations. They go in macros.
	addi sp, sp, -FRAME_SIZE
	sd fp, 0x00(sp)
	mv fp, sp
	sd ra, 0x08(fp)
	jr t0

.global epilogue_0
epilogue_0:
	# Do NOT add CFI declarations. They go in macros.
	ld ra, 0x08(fp)
	ld fp, 0x00(fp)
	addi sp, sp, FRAME_SIZE
	ret
