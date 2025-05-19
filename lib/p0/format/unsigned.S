# ===========================================================================
# String formatting - Unsigned integer
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

# Format an unsigned number.
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
.global "format.Unsigned"
"format.Unsigned":
	# Arguments.
	#define out_size a0
	#define out_data a1
	#define out_idx  a2
	#define value    a3

	# Temporaries.
	#define out_ptr    t0
	#define ch         t1
	#define ten	   t2
	#define remainder  t4
	#define out_end    t5
	#define buffer_ptr t6

	# Constants.
	#define buffer_size 32
	#define stack_size (buffer_size)

	# Stack locations relative to sp.
	#define buffer_data 0

	.cfi_startproc

	# Optimisation: no-op if the buffer is full.
	bge a2, a0, .LUnsigned.BufferFull

	# Sanity checks.
	bltz a0, .LUnsigned.Panic.NegativeBufferSize
	bltz a2, .LUnsigned.Panic.NegativeBufferPos

	# The digit extraction algorithm returns the digits in reverse order
	# to what we want to print. We store them in a temporary buffer and
	# then copy them to the output in reverse order.
	.cfi_def_cfa_offset buffer_size
	addi sp, sp, -buffer_size

	li ten, 10
	addi buffer_ptr, sp, buffer_data

.LUnsigned.ExtractNextDigit:
	remu remainder, value, ten

	addi ch, remainder, '0'
	sb ch, 0(buffer_ptr)
	addi buffer_ptr, buffer_ptr, 1

	divu value, value, ten
	bnez value, .LUnsigned.ExtractNextDigit

.LUnsigned.ReverseCopy:
	add out_ptr, out_data, out_idx
	add out_end, out_data, out_size

.LUnsigned.ReverseCopyNextDigit:
	# We do not need the initial check for out_ptr >= out_end because we
	# already have a special case for when the buffer is initially full;
	# hence we know that at least one byte is available.
	#
	# We also know that the buffer always contains at least one character.
	lb ch, -1(buffer_ptr)
	sb ch, 0(out_ptr)
	addi buffer_ptr, buffer_ptr, -1
	addi out_ptr, out_ptr, 1

	beq buffer_ptr, sp, .LUnsigned.Done # Pre: buffer_data == 0
	bge out_ptr, out_end, .LUnsigned.Done
	j .LUnsigned.ReverseCopyNextDigit

.LUnsigned.Done:
	sub out_idx, out_ptr, out_data

	# De-allocate stack variables.
	addi sp, sp, stack_size
	.cfi_def_cfa_offset 0
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
