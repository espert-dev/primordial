# ===========================================================================
# Macros for safe string (slices)
# ===========================================================================

.macro safe_str name, value
\name\()_data:
.ascii "\value"
.equiv \name\()_size, . - \name\()_data
.endm

.macro safe_str_slice name
.8byte \name\()_data
.8byte \name\()_size
.endm
