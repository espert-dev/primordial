# ===========================================================================
# Millicode for procedure prologue and epilogue (2 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x10
#elif XLEN == 64
	#define FRAME_SIZE 0x20
#else
	#error invalid or undefined XLEN
#endif

.global prologue_2
prologue_2:
	.cfi_startproc
	.cfi_return_column t0
	addi sp, sp, -FRAME_SIZE
	sx fp, 0(sp)
	mv fp, sp
	sx ra, (1*XLEN_BYTES)(fp)
	sx s1, (2*XLEN_BYTES)(fp)
	sx s2, (3*XLEN_BYTES)(fp)
	jr t0
	.cfi_endproc

.global epilogue_2
epilogue_2:
	.cfi_startproc
	lx s2, (3*XLEN_BYTES)(fp)
	lx s1, (2*XLEN_BYTES)(fp)
	lx ra, (1*XLEN_BYTES)(fp)
	lx fp, 0(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc

#undef FRAME_SIZE
