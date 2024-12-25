# ===========================================================================
# Package forever allocates memory until the process terminates.
#
# While this allocation strategy is not suitable to all problems,
# it fits some common application patterns and is both fast and
# easy to implement.
# ===========================================================================

#include <millicode.S>
#include <io.S>
#include <syscall.S>
#include <safe_str.S>


# ===========================================================================
# Definitions
# ===========================================================================

# Allocator state type.
.struct 0
state:
state.limit: .space 8
state.next: .space 8
.equiv state_size, . - state

# Constants
.equiv PAGE_SIZE, 4096


# ===========================================================================
# Constants
# ===========================================================================

.section .rodata

safe_str allocation_panic, "PANIC: allocation failed!"


# ===========================================================================
# Global variables
# ===========================================================================

.section .bss

# Global variable that store the state of the allocator.
.lcomm "forever.state", state_size


# ===========================================================================
# Functions
# ===========================================================================

.section .text

# Allocate memory until the process terminates.
#
# - A request size of zero will always allocate memory.
# - All returned memory is aligned to 16 bytes.
#
# Input:
#   a0: requested memory size in bytes
#
# Output:
#   a0: allocated memory
#   a1: error
.global "forever.MustAllocate"
"forever.MustAllocate":
	.cfi_startproc

	save_0
	call "forever.Allocate"
	bltz a1, .LMustAllocate.panic
	restore_0

.LMustAllocate.panic:
	# This will have to do until we have a better panic handler.
	li a0, STDLOG
	la a1, allocation_panic
	li a2, allocation_panic_size
	call "io.Write"

	li a0, 1
	call "os.Exit"

	.cfi_endproc


# Allocate memory until the process terminates.
#
# - A request size of zero will always allocate memory.
# - All returned memory is aligned to 16 bytes.
#
# Input:
#   a0: requested memory size in bytes
#
# Output:
#   a0: allocated memory
#   a1: error
.global "forever.Allocate"
"forever.Allocate":
	# Temporary registers.
	#define state_ptr    t0
	#define state_limit  t1
	#define state_next   t2
	#define aligned_size t3
	#define new_next     t4
	#define new_limit    t5

	.cfi_startproc

	# Load current state.
	la state_ptr, "forever.state"
	ld state_limit, state.limit(state_ptr)
	ld state_next, state.next(state_ptr)

	# Coerce to a minimum request_size of 1 so that every allocated
	# object has a unique memory address.
	#
	# Correctness: the addition cannot overflow.
	seqz aligned_size, a0
	add aligned_size, aligned_size, a0

	# Align request to 16 bytes, with a minimum of 16 bytes.
	# Because we align all requests, we do not need to align state_next.
	#
	# align(value, alignment) = (value + (alignment-1)) & ~alignment
	#
	# The & bit clears the lower 4 bits. The addition will ensure that
	# the initial and final value are only the same if the lower 4 bits
	# are all zero.
	addi aligned_size, aligned_size, 15
	andi aligned_size, aligned_size, -16

	# If the current limit is zero, it hasn't been initalised yet.
	#
	# Invalidated aliases:
	#   - requested_size: will be overwritten by syscall arguments.
	beqz state_limit, .Linit

.Lcheck_brk:
	# Do we have enough space left below the limit?
	add new_next, state_next, aligned_size
	bgtu new_next, state_limit, .Lincrease_brk

.Lallocate:
	mv a0, state_next
	li a1, 0
	sd new_next, state.next(state_ptr)

	ret

.Lincrease_brk:
	# This section is only called when we go over the limit, so put it out
	# of the hot path.

	# Work out how much extra memory is needed and round it up to pages.
	#
	# Note: using a0 and a7 as scratch registers.
	li a0, PAGE_SIZE - 1
	li a7, -PAGE_SIZE
	sub new_limit, new_next, state_limit
	add new_limit, new_limit, a0
	and new_limit, new_limit, a7

	# Request extra memory from the operating system.
	add a0, state_limit, new_limit
	li a7, SYSCALL_BRK
	ecall

	# The syscall failed if the returned limit is the original limit.
	beq a0, state_limit, .Lfail

	sd a0, state.limit(state_ptr)
	j .Lallocate

.Lfail:
	li a0, 0
	li a1, 1
	ret

.Linit:
	# The allocator has not been initialised yet. We can only enter this
	# block once, so it makes sense to put it at the end out of the hot
	# path.

	# Call brk with an invalid value (0) to get the current break.
	li a0, 0
	li a7, SYSCALL_BRK
	ecall

	# If we get zero back from the kernel, the syscall failed.
	# In that case, return an error to the caller.
	beqz a0, .Lfail

	# Set the current break as the starting value for next and limit.
	# This makes it compatible with the control flow that jumps over
	# this init step.
	mv state_next, a0
	mv state_limit, a0

	j .Lcheck_brk

	.cfi_endproc
