# ===========================================================================
# Millicode for procedure prologue and epilogue (0 saved registers)
# ===========================================================================

#include <compat.S>


.section .text

#if XLEN == 32
	#define FRAME_SIZE 0x10
#elif XLEN == 64
	#define FRAME_SIZE 0x10
#else
	#error invalid or undefined XLEN
#endif

.global prologue_0
prologue_0:
	.cfi_startproc
	.cfi_return_column t0

	addi sp, sp, -FRAME_SIZE
	sx fp, 0(sp)
	mv fp, sp
	sx ra, (1*XLEN/8)(fp)
	jr t0
	.cfi_endproc

.global epilogue_0
epilogue_0:
	.cfi_startproc
	lx ra, (1*XLEN/8)(fp)
	lx fp, 0(fp)
	addi sp, sp, FRAME_SIZE
	ret
	.cfi_endproc

#undef FRAME_SIZE
