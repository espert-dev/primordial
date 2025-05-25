# ===========================================================================
# Millicode for procedure prologue and epilogue (11 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x40
#elif XLEN == 64
	#define FRAME_SIZE 0x70
#else
	#error invalid or undefined XLEN
#endif

.global prologue_11
prologue_11:
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
	sx s6, (7*XLEN/8)(fp)
	sx s7, (8*XLEN/8)(fp)
	sx s8, (9*XLEN/8)(fp)
	sx s9, (10*XLEN/8)(fp)
	sx s10, (11*XLEN/8)(fp)
	sx s11, (12*XLEN/8)(fp)
	jr t0
	.cfi_endproc

.global epilogue_11
epilogue_11:
	.cfi_startproc
	lx s11, (12*XLEN/8)(fp)
	lx s10, (11*XLEN/8)(fp)
	lx s9, (10*XLEN/8)(fp)
	lx s8, (9*XLEN/8)(fp)
	lx s7, (8*XLEN/8)(fp)
	lx s6, (7*XLEN/8)(fp)
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
