# ===========================================================================
# String formatting - Unsigned
# ===========================================================================

#include <safe_str.S>
#include <io.S>


# ===========================================================================
# Constants
# ===========================================================================

.section .rodata

safe_str negative_buffer_size_panic, "PANIC: negative buffer size!"
safe_str negative_buffer_pos_panic, "PANIC: negative buffer position!"


# ===========================================================================
# Functions
# ===========================================================================

.section .text

# Format an unsigned number.
#
# Input:
#   a0 out_size: Output buffer sizallocation_panic_datae
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

	bge a2, a0, .LUnsigned.BufferFull
	bltz a0, .LUnsigned.Panic.NegativeBufferSize
	bltz a2, .LUnsigned.Panic.NegativeBufferPos

	# Nothing yet.
	ret

.LUnsigned.BufferFull:
	# Nothing to do: the buffer is full.
	ret

.LUnsigned.Panic.NegativeBufferSize:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_size_panic_size
	la a2, negative_buffer_size_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

.LUnsigned.Panic.NegativeBufferPos:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_pos_panic_size
	la a2, negative_buffer_pos_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

	.cfi_endproc
