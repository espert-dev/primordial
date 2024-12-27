# ===========================================================================
# Memory cloning
# ===========================================================================

#include <millicode.S>


.section .text

# Clone memory.
#
# A nil value returns nil.
#
# Input:
#   a0: source size
#   a1: source data
#
# Output:
#   a0: cloned size
#   a1: cloned data
.global "mem.Clone"
"mem.Clone":
	.cfi_startproc
	save_0
	restore_0
	.cfi_endproc
