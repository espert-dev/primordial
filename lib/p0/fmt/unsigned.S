# ===========================================================================
# Format unsigned number
# ===========================================================================

#include <millicode.S>

.section .text

# Format an unsigned integer.
#
# Input:
#   a0 buffer_size: size of the output buffer
#   a1 buffer_data: pointer to output buffer
#   a2 value:       value to format
#
# Output:
#   a0 written_size:  number of bytes written
#   a1 written_data:  same as original buffer_data
#   a2 required_size: number of bytes required for full output
.global "fmt/Unsigned"
"fmt/Unsigned":
    # Argument registers.
    #define buffer_size a0
    #define buffer_data a1
    #define value       a2

    # Temporary registers.
    #define written_size t0

    .cfi_startproc
    save_0

    li written_size, 0
    beqz buffer_data, .LUnsigned.end_truncate

.LUnsigned.end_truncate:

.LUnsigned.end_ok:
    mv a0, written_size
    restore_0
    .cfi_endproc
