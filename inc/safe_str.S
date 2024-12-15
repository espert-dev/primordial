# ===========================================================================
# Macros for safe string (slices)
# ===========================================================================

.macro safe_str name, value
\name\():
.ascii "\value"
.equiv \name\()_size, . - \name
.endm

.macro safe_str_slice name
.8byte \name
.8byte \name\()_size
.endm
