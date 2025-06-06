# ===========================================================================
# Millicode for procedure prologue and epilogue (6 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x20
#elif XLEN == 64
	#define FRAME_SIZE 0x40
#else
	#error invalid or undefined XLEN
#endif

.global prologue_6
prologue_6:
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
	jr t0
	.cfi_endproc

.global epilogue_6
epilogue_6:
	.cfi_startproc
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
