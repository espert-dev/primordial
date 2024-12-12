# ===========================================================================
# Macros for safe string (slices)
# ===========================================================================

.macro safe_str name, value
\name\():
.ascii "\value"
.equiv \name\()_size, . - \name
.endm

