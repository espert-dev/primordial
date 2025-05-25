# ===========================================================================
# Compatibility definitions to support both rv32 and rv64
# ===========================================================================

#ifndef COMPAT_S
#define COMPAT_S

# Define XLEN versions of the load/store operations.
#if XLEN == 32
	#define lx lw
	#define sx sw
#elif XLEN == 64
	#define lx ld
	#define sx sd
#else
	#error invalid or undefined XLEN
#endif

#endif
