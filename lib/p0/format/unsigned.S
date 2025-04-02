# ===========================================================================
# String formatting - Unsigned
# ===========================================================================

.section .text

# Format an unsigned number.
#
# Input:
#   a0 out_size: Output buffer size
#   a1 out_data: Output buffer data
#   a2 out_pos:  Output buffer position
#   a3 value:    Value to format
#
# Output:
#   a0 out_size: Output buffer size (preserved)
#   a1 out_data: Output buffer data (preserved)
#   a2 out_pos:  Output buffer position (updated)
.global "format.Unsigned"
"format.Unsigned":
	# Arguments.
	#define out_size a0
	#define out_data a1
	#define out_pos  a2
	#define value    a3

    .cfi_startproc

    # Nothing yet.
    ret

    .cfi_endproc
