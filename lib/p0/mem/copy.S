# ===========================================================================
# Memory copy
# ===========================================================================

.section .text

# Copy Memory
#
# Input:
#   a0: source size
#   a1: source data
#   a2: destination size
#   a3: destination data
#
# Output:
#   a0: num copied bytes
.global "mem.Copy"
"mem.Copy":
	ret
