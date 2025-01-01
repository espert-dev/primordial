# ===========================================================================
# Macros and definitions for slices
# ===========================================================================

.struct 0
slice:
slice.size: .space 8
slice.data: .space 8
.equiv slice_size, . - slice

.macro safe_str_slice name
.8byte \name\()_size
.8byte \name\()_data
.endm
