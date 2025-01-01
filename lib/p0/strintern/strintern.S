# ===========================================================================
# String interning
# ===========================================================================

# Design
#
# String interning reduces string comparison to pointer comparison, which is
# both simpler and faster than comparing the memory contents.
#
# The design of this data structure is tailored to the compiler needs:
#
#   - String comparison is frequent and should be made as simple as possible.
#     Therefore, rather than comparing the slice (pointer and size), it
#     clones the string value to ensure that it cannot be aliased by any
#     other interned string. As a result, it is sufficient to compare the
#     pointer, which reduces comparison to a single BEQ/BNE instruction.
#
#   - Despite the above, we return the full slice as a value rather than a
#     handle. This eliminates the need to implement a mechanism to resolve
#     handles into strings and simplifies debugging because the string is
#     trivial to resolve.
#
#   - Memory is allocated, but never freed. Therefore, we can rely on the
#     `forever` allocator for simplicity, and obviate removal operations.
#
#   - Sublinear operation cost is not necessary, but it is desirable.
#     We have chosen AA trees because they are very easy to implement but
#     guarantee good asymptotic behaviour.
#
#   - It only needs to support reasonable identifiers. In particular, this
#     means that it does not need to support extremely long strings. We
#     exploit this to reduce the size of the AA node size without resorting
#     to tricks like packing the colour in the LSB of the pointers.
#
#   - It uses shortlex to compare strings. It's faster than dictionary order,
#     and the ordering itself doesn't matter, as long as there's one.

#include <millicode.S>


# Tree node.
.struct 0
"strintern.node":
"strintern.node.left":      .space 8
"strintern.node.right":     .space 8
"strintern.node.level":     .space 4
"strintern.node.str_size":  .space 4
"strintern.node.str_data":  .space 8
.equiv "strintern.node_size", . - "strintern.node"


# ===========================================================================
# Constants
# ===========================================================================

.section .rodata

# Type: TreeNode
#
# The sentinel node has level 0, so no extra work is necessary to encode it.
.align 4
"strintern.sentinel":
.8byte "strintern.sentinel" # left
.8byte "strintern.sentinel" # right
.4byte 0 # level
.4byte 0 # str_size
.8byte 0 # str_data
.equiv "strintern.sentinel_size", . - "strintern.sentinel"


# ===========================================================================
# Global variables
# ===========================================================================

.section .data

# Stores a pointer to the tree root.
"strintern.root":
.8byte "strintern.sentinel"


# ===========================================================================
# Public interface
# ===========================================================================

.section .text

# Intern a string.
#
# Inputs:
#   a0 xs_size: size of string
#   a1 xs_data: pointer to string data
#
# Outputs:
#   a0: size of string
#   a1: pointer to interned string data
.global "strintern.Intern"
"strintern.Intern":
	#define sentinel_backup s1
	#define root_ptr        s2

	# Shared registers.
	#define sentinel        s11

	.cfi_startproc
	save_2
	mv sentinel_backup, sentinel

	la sentinel, "strintern.sentinel"
	la root_ptr, "strintern.root"

	# a0-1 already have the values.
	ld a2, 0(root_ptr)
	call "strintern.findOrInsert"

	# The root pointer may have been modified.
	sd a2, 0(root_ptr)

	mv sentinel, sentinel_backup
	restore_2
	.cfi_endproc

	#undefine sentinel_backup
	#undefine root_ptr


# ===========================================================================
# Private functions
# ===========================================================================

# Find or insert a string in the interned set.
#
# Shared (from Intern):
#   sentinel
#
# Inputs:
#   a0 str_size: size of string
#   a1 str_data: pointer to string data
#   a2 tree:    tree that stores the interned string set
#
# Outputs:
#   a0: size of string
#   a1: pointer to interned string data
#   a2: updated tree
"strintern.findOrInsert":
	#define str_size s1
	#define str_data s2
	#define tree     s3

	.cfi_startproc
	save_3
	mv str_size, a0
	mv str_data, a1
	mv tree, a2

	# Allocation should be rarer, so put it last.
	beq tree, sentinel, .LfindOrInsert.allocate

	# a0 and a1 are ready.
	lw a2, "strintern.node.str_size"(tree)
	ld a3, "strintern.node.str_data"(tree)
	call "mem/Shortlex"

	bltz a0, .LfindOrUpdate.left
	bgtz a0, .LfindOrUpdate.right

.LfindOrUpdate.found:
	# Return interned value.
	ld str_data, "strintern.node.str_data"(tree)
	lw str_size, "strintern.node.str_size"(tree)

	j .LfindOrInsert.end

.LfindOrUpdate.left:
	mv a0, str_size
	mv a1, str_data
	ld a2, "strintern.node.left"(tree)
	call "strintern.findOrInsert"

	j .LfindOrUpdate.rebalance

.LfindOrUpdate.right:
	mv a0, str_size
	mv a1, str_data
	ld a2, "strintern.node.right"(tree)
	call "strintern.findOrInsert"

	# Fall through.

.LfindOrUpdate.rebalance:
	mv str_size, a0
	mv str_data, a1
	mv a0, a2

	# skew and split modify and return a0.
	call "strintern.skew"
	call "strintern.split"
	mv tree, a0

	# Fall through.

.LfindOrInsert.end:
	mv a0, str_size
	mv a1, str_data
	mv a2, tree
	restore_3

.LfindOrInsert.allocate:
	li a0, "strintern.node_size"
	call "forever.MustAllocate"
	mv tree, a0

	sd sentinel, "strintern.node.left"(tree)
	sd sentinel, "strintern.node.right"(tree)

	li t0, 1
	sd t0, "strintern.node.level"(tree)

	# Store a clone of the string that is guaranteed not to alias with
	# anything, removing the need to compare string lengths and thus
	# reducing string comparison to a single instruction.
	mv a0, str_size
	mv a1, str_data
	call "mem.Clone"
	mv str_data, a1

	sd str_size, "strintern.node.str_size"(tree)
	sd str_data, "strintern.node.str_data"(tree)

	j .LfindOrInsert.end
	.cfi_endproc

	#undef str_data
	#undef str_size
	#undef tree

	# Undefine shared registers.
	#undef sentinel

# Inputs:
#   a0: node pointer
#
# Outputs:
#   a0: node pointer
#
# Rotation:
#
#   L <---- [T]       [L] ----> T
#  / \       \   =>   /        / \
# A   B       R      A        B   R
"strintern.skew":
	#define t       a0
	#define l       t0
	#define t_level t1
	#define l_level t2
	#define b       t3

	.cfi_startproc
	ld l, "strintern.node.left"(t)
	lw t_level, "strintern.node.level"(t)
	lw l_level, "strintern.node.level"(l)
	beq t_level, l_level, .Lskew.rotate
	ret

.Lskew.rotate:
	ld b, "strintern.node.right"(l)
	sd b, "strintern.node.left"(t)
	sd t, "strintern.node.right"(l)
	mv t, l
	ret
	.cfi_endproc

	#undef t
	#undef l
	#undef t_level
	#undef l_level
	#undef b


# Inputs:
#   a0: node pointer
#
# Outputs:
#   a0: node pointer
#
# Rotation:
#
#  [T] ---> R ---> X           [R]
#  /       /            =>    /  \
# L       B                  T    X
#                           / \
#                          L   B
"strintern.split":
	#define t       a0
	#define r       t0
	#define x       t1
	#define t_level t2
	#define x_level t3
	#define b       t4
	#define r_level t5

	.cfi_startproc
	ld r, "strintern.node.right"(t)
	ld x, "strintern.node.right"(r)

	lw t_level, "strintern.node.level"(t)
	lw x_level, "strintern.node.level"(x)
	beq t_level, x_level, .Lsplit.rotate

	ret

.Lsplit.rotate:
	ld b, "strintern.node.left"(r)
	sd b, "strintern.node.right"(t)
	sd t, "strintern.node.left"(r)

	lw r_level, "strintern.node.level"(r)
	addi r_level, r_level, 1
	sw r_level, "strintern.node.level"(r)

	ret
	.cfi_endproc

	#undef t
	#undef r
	#undef x
	#undef t_level
	#undef x_level
	#undef b
	#undef r_level
