# ===========================================================================
# Millicode for procedure prologue and epilogue (8 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x30
#elif XLEN == 64
	#define FRAME_SIZE 0x50
#else
	#error invalid or undefined XLEN
#endif

.global prologue_8
prologue_8:
	.cfi_startproc
	.cfi_return_column t0
	addi sp, sp, -FRAME_SIZE
	sx fp, 0(sp)
	mv fp, sp
	sx ra, (1*XLEN_BYTES)(fp)
	sx s1, (2*XLEN_BYTES)(fp)
	sx s2, (3*XLEN_BYTES)(fp)
	sx s3, (4*XLEN_BYTES)(fp)
	sx s4, (5*XLEN_BYTES)(fp)
	sx s5, (6*XLEN_BYTES)(fp)
	sx s6, (7*XLEN_BYTES)(fp)
	sx s7, (8*XLEN_BYTES)(fp)
	sx s8, (9*XLEN_BYTES)(fp)
	jr t0
	.cfi_endproc

.global epilogue_8
epilogue_8:
	.cfi_startproc
	lx s8, (9*XLEN_BYTES)(fp)
	lx s7, (8*XLEN_BYTES)(fp)
	lx s6, (7*XLEN_BYTES)(fp)
	lx s5, (6*XLEN_BYTES)(fp)
	lx s4, (5*XLEN_BYTES)(fp)
	lx s3, (4*XLEN_BYTES)(fp)
	lx s2, (3*XLEN_BYTES)(fp)
	lx s1, (2*XLEN_BYTES)(fp)
	lx ra, (1*XLEN_BYTES)(fp)
	lx fp, 0(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc

#undef FRAME_SIZE
