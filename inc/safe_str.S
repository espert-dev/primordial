# ===========================================================================
# Macros for safe string (slices)
# ===========================================================================

.macro safe_str name, value
"\name\()_data":
.ascii "\value"
.equiv "\name\()_size", . - "\name\()_data"
.endm
