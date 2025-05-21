# ===========================================================================
# String formatting - append string to buffer
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

# Format a string (append to buffer).
#
# Input:
#   a0 out_size:    Output buffer sizallocation_panic_data
#   a1 out_data:    Output buffer data
#   a2 out_idx:     Output buffer current index
#   a3 value_size:  String size
#   a4 value_data:  String data
#
# Output:
#   a0 out_size: Output buffer size (preserved)
#   a1 out_data: Output buffer data (preserved)
#   a2 out_idx:  Output buffer updated index
.global "format.String"
"format.String":
	# Arguments.
	#define out_size   a0
	#define out_data   a1
	#define out_idx    a2
	#define value_size a3
	#define value_data a4

	# Temporaries.
	#define out_ptr   t0
	#define out_end   t1
	#define ch        t2
	#define value_ptr t3

	.cfi_startproc

	# Optimisation: no-op if the buffer is full.
	blt out_idx, out_size, .LString.SanityCheck
	ret

.LString.SanityCheck:
	# Sanity checks.
	bltz out_size, .LSigned.Panic.NegativeBufferSize
	bltz out_idx, .LSigned.Panic.NegativeBufferPos

.LString.MinLength:
	# min(value_size, out_size - out_idx)
	sub out_end, out_size, out_idx
	blt out_end, value_size, .LString.Prepare
	mv out_end, value_size

.LString.Prepare:
	# out_end = out_data + min(value_size, out_size - out_idx)
	add out_end, out_end, out_data
	add out_ptr, out_data, out_idx
	mv value_ptr, value_data
	bge out_ptr, out_end, .LString.Done

.LString.NextByte:
	lbu ch, 0(value_ptr)
	sb ch, 0(out_ptr)
	addi value_ptr, value_ptr, 1
	addi out_ptr, out_ptr, 1
	blt out_ptr, out_end, .LString.NextByte

.LString.Done:
	sub out_idx, out_end, out_data
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
