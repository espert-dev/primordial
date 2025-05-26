# ===========================================================================
# Macros and definitions for slices
# ===========================================================================

#include <compat.S>


.struct 0
slice:
slice.size: .space XLEN_BYTES
slice.data: .space XLEN_BYTES
.equiv slice_size, . - slice

.macro safe_str_slice name
Xbyte \name\()_size
Xbyte \name\()_data
.endm
