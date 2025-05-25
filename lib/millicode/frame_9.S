# ===========================================================================
# Millicode for procedure prologue and epilogue (9 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x30
#elif XLEN == 64
	#define FRAME_SIZE 0x60
#else
	#error invalid or undefined XLEN
#endif

.global prologue_9
prologue_9:
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
	jr t0
	.cfi_endproc

.global epilogue_9
epilogue_9:
	.cfi_startproc
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
