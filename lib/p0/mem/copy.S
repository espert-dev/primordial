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
.global "mem.Copy"
"mem.Copy":
	ret
