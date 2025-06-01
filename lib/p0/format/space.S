# ===========================================================================
# String formatting - append a number of spaces to a buffer
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

# Append a number of spaces to the buffer.
#
# Input:
#   a0 out_size:    Output buffer sizallocation_panic_data
#   a1 out_data:    Output buffer data
#   a2 out_idx:     Output buffer current index
#   a3 num_chars:   Number of space characters to append.
#
# Output:
#   a0 out_size: Output buffer size (preserved)
#   a1 out_data: Output buffer data (preserved)
#   a2 out_idx:  Output buffer updated index
.global "format.Space"
"format.Space":
	# Arguments.
	#define out_size   a0
	#define out_data   a1
	#define out_idx    a2
	#define num_chars  a3

	# Temporaries.
	#define out_ptr    t0
	#define out_end    t1
	#define ch         t2

	.cfi_startproc

	# Optimisation: no-op if the buffer is full.
	blt out_idx, out_size, .LSanityCheck
	ret

.LSanityCheck:
	# Sanity checks.
	bltz out_size, .LPanic.NegativeBufferSize
	bltz out_idx, .LPanic.NegativeBufferPos

	add out_end, out_idx, num_chars
	blt out_end, out_size, .LDone
	mv out_end, out_size

.LPrepare:
	add out_end, out_data, out_end
	add out_ptr, out_data, out_idx
	li ch, ' '

.LNextChar:
	sb ch, 0(out_ptr)
	addi out_ptr, out_ptr, 1
	blt out_ptr, out_end, .LNextChar

.LComputeIdx:
	sub out_idx, out_ptr, out_data

.LDone:
	ret

.LPanic.NegativeBufferSize:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_size_panic_size
	la a2, negative_buffer_size_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

.LPanic.NegativeBufferPos:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	li a1, negative_buffer_pos_panic_size
	la a2, negative_buffer_pos_panic_data
	call "io.Write"

	li a0, 1
	call "os.Exit"

	.cfi_endproc
