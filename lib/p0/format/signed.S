# ===========================================================================
# String formatting - Signed integer
# ===========================================================================

#include <millicode.S>
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

# Format a signed number.
#
# Input:
#   a0 out_size: Output buffer sizallocation_panic_datae
#   a1 out_data: Output buffer data
#   a2 out_idx:  Output buffer current index
#   a3 value:    Value to format
#
# Output:
#   a0 out_size: Output buffer size (preserved)
#   a1 out_data: Output buffer data (preserved)
#   a2 out_idx:  Output buffer updated index
.global "format.Signed"
"format.Signed":
	.cfi_startproc

	# Optimisation: no-op if the buffer is full.
	bge a2, a0, .LSigned.BufferFull

	# Sanity checks.
	bltz a0, .LSigned.Panic.NegativeBufferSize
	bltz a2, .LSigned.Panic.NegativeBufferPos

	# Positive numbers can be formatted as unsigned numbers.
	tail "format.Unsigned"

.LSigned.BufferFull:
	# Nothing to do: the buffer is full.
	ret

.LSigned.Panic.NegativeBufferSize:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_size_panic_size
	la a2, negative_buffer_size_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

.LSigned.Panic.NegativeBufferPos:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_pos_panic_size
	la a2, negative_buffer_pos_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

	.cfi_endproc
