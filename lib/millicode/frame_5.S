# ===========================================================================
# Millicode for procedure prologue and epilogue (5 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#define FRAME_SIZE 0x40

.global prologue_5
prologue_5:
	.cfi_startproc
	.cfi_return_column t0
	addi sp, sp, -FRAME_SIZE
	sx fp, 0(sp)
	mv fp, sp
	sx ra, (1*XLEN/8)(fp)
	sx s1, (2*XLEN/8)(fp)
	sx s2, (3*XLEN/8)(fp)
	sx s3, (4*XLEN/8)(fp)
	sx s4, (5*XLEN/8)(fp)
	sx s5, (6*XLEN/8)(fp)
	jr t0
	.cfi_endproc

.global epilogue_5
epilogue_5:
	.cfi_startproc
	lx s5, (6*XLEN/8)(fp)
	lx s4, (5*XLEN/8)(fp)
	lx s3, (4*XLEN/8)(fp)
	lx s2, (3*XLEN/8)(fp)
	lx s1, (2*XLEN/8)(fp)
	lx ra, (1*XLEN/8)(fp)
	lx fp, 0(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc

#undef FRAME_SIZE
