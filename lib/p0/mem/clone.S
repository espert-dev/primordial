# ===========================================================================
# Memory cloning
# ===========================================================================

#include <millicode.S>


.section .text

# Clone memory.
#
# A nil value returns nil.
# Anything other value returns a fresh copy of the object. This copy is guaranteed
# not to overlap with any other allocated object.
#
# Input:
#   a0: original size
#   a1: original data
#
# Output:
#   a0: cloned size
#   a1: cloned data
.global "mem.Clone"
"mem.Clone":
	#define original_size s1
	#define original_data s2
	#define allocated   s3

	.cfi_startproc

	# Special fast case for nil.
	bnez a1, .LClone.clone
	bnez a0, .LClone.clone
	ret

.LClone.clone:
	save_3

	mv original_size, a0
	mv original_data, a1

	# a0 (original_size) already in place.
	call "forever.MustAllocate"
	mv allocated, a0

	mv a0, original_size
	mv a1, original_data
	mv a2, original_size
	mv a3, allocated
	call "mem.Copy"

	mv a0, original_size
	mv a1, allocated

	restore_3
	.cfi_endproc

	#undef original_size
	#undef original_data
	#undef allocated
