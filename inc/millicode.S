# ===========================================================================
# Millicode for procedure prologue and epilogue (save and restore macros)
# ===========================================================================

# Avoid using .equ or #define for the frame size to avoid polluting the
# namespace of user code.

.section .text

.macro save_0
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_0
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x10
	.cfi_offset fp, 0x00 - 0x10
	.cfi_offset ra, 0x08 - 0x10
.endm

.macro save_1
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_1
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x20
	.cfi_offset fp, 0x00 - 0x20
	.cfi_offset ra, 0x08 - 0x20
	.cfi_offset s1, 0x10 - 0x20
.endm

.macro save_2
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_2
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x20
	.cfi_offset fp, 0x00 - 0x20
	.cfi_offset ra, 0x08 - 0x20
	.cfi_offset s1, 0x10 - 0x20
	.cfi_offset s2, 0x18 - 0x20
.endm

.macro save_3
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_3
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x30
	.cfi_offset fp, 0x00 - 0x30
	.cfi_offset ra, 0x08 - 0x30
	.cfi_offset s1, 0x10 - 0x30
	.cfi_offset s2, 0x18 - 0x30
	.cfi_offset s3, 0x20 - 0x30
.endm

.macro save_4
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_4
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x30
	.cfi_offset fp, 0x00 - 0x30
	.cfi_offset ra, 0x08 - 0x30
	.cfi_offset s1, 0x10 - 0x30
	.cfi_offset s2, 0x18 - 0x30
	.cfi_offset s3, 0x20 - 0x30
	.cfi_offset s4, 0x28 - 0x30
.endm

.macro save_5
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_5
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x40
	.cfi_offset fp, 0x00 - 0x40
	.cfi_offset ra, 0x08 - 0x40
	.cfi_offset s1, 0x10 - 0x40
	.cfi_offset s2, 0x18 - 0x40
	.cfi_offset s3, 0x20 - 0x40
	.cfi_offset s4, 0x28 - 0x40
	.cfi_offset s5, 0x30 - 0x40
.endm

.macro save_6
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_6
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x40
	.cfi_offset fp, 0x00 - 0x40
	.cfi_offset ra, 0x08 - 0x40
	.cfi_offset s1, 0x10 - 0x40
	.cfi_offset s2, 0x18 - 0x40
	.cfi_offset s3, 0x20 - 0x40
	.cfi_offset s4, 0x28 - 0x40
	.cfi_offset s5, 0x30 - 0x40
	.cfi_offset s6, 0x38 - 0x40
.endm

.macro save_7
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_7
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x50
	.cfi_offset fp, 0x00 - 0x50
	.cfi_offset ra, 0x08 - 0x50
	.cfi_offset s1, 0x10 - 0x50
	.cfi_offset s2, 0x18 - 0x50
	.cfi_offset s3, 0x20 - 0x50
	.cfi_offset s4, 0x28 - 0x50
	.cfi_offset s5, 0x30 - 0x50
	.cfi_offset s6, 0x38 - 0x50
	.cfi_offset s7, 0x40 - 0x50
.endm

.macro save_8
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_8
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x50
	.cfi_offset fp, 0x00 - 0x50
	.cfi_offset ra, 0x08 - 0x50
	.cfi_offset s1, 0x10 - 0x50
	.cfi_offset s2, 0x18 - 0x50
	.cfi_offset s3, 0x20 - 0x50
	.cfi_offset s4, 0x28 - 0x50
	.cfi_offset s5, 0x30 - 0x50
	.cfi_offset s6, 0x38 - 0x50
	.cfi_offset s7, 0x40 - 0x50
	.cfi_offset s8, 0x48 - 0x50
.endm

.macro save_9
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_9
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x60
	.cfi_offset fp, 0x00 - 0x60
	.cfi_offset ra, 0x08 - 0x60
	.cfi_offset s1, 0x10 - 0x60
	.cfi_offset s2, 0x18 - 0x60
	.cfi_offset s3, 0x20 - 0x60
	.cfi_offset s4, 0x28 - 0x60
	.cfi_offset s5, 0x30 - 0x60
	.cfi_offset s6, 0x38 - 0x60
	.cfi_offset s7, 0x40 - 0x60
	.cfi_offset s8, 0x48 - 0x60
	.cfi_offset s9, 0x50 - 0x60
.endm

.macro save_10
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_10
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x60
	.cfi_offset fp, 0x00 - 0x60
	.cfi_offset ra, 0x08 - 0x60
	.cfi_offset s1, 0x10 - 0x60
	.cfi_offset s2, 0x18 - 0x60
	.cfi_offset s3, 0x20 - 0x60
	.cfi_offset s4, 0x28 - 0x60
	.cfi_offset s5, 0x30 - 0x60
	.cfi_offset s6, 0x38 - 0x60
	.cfi_offset s7, 0x40 - 0x60
	.cfi_offset s8, 0x48 - 0x60
	.cfi_offset s9, 0x50 - 0x60
	.cfi_offset s10, 0x58 - 0x60
.endm

.macro save_11
	# Use alternate calling convention using t0 to avoid clobbering ra.
	jal t0, prologue_11
	.cfi_return_column ra
	.cfi_def_cfa_offset 0x70
	.cfi_offset fp, 0x00 - 0x70
	.cfi_offset ra, 0x08 - 0x70
	.cfi_offset s1, 0x10 - 0x70
	.cfi_offset s2, 0x18 - 0x70
	.cfi_offset s3, 0x20 - 0x70
	.cfi_offset s4, 0x28 - 0x70
	.cfi_offset s5, 0x30 - 0x70
	.cfi_offset s6, 0x38 - 0x70
	.cfi_offset s7, 0x40 - 0x70
	.cfi_offset s8, 0x48 - 0x70
	.cfi_offset s9, 0x50 - 0x70
	.cfi_offset s10, 0x58 - 0x70
	.cfi_offset s10, 0x60 - 0x70
.endm

.macro restore_0
	tail epilogue_0
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_1
	tail epilogue_1
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_2
	tail epilogue_2
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_3
	tail epilogue_3
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_4
	tail epilogue_4
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_5
	tail epilogue_5
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_6
	tail epilogue_6
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_7
	tail epilogue_7
	.cfi_restore s7
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_8
	tail epilogue_8
	.cfi_restore s8
	.cfi_restore s7
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_9
	tail epilogue_9
	.cfi_restore s9
	.cfi_restore s8
	.cfi_restore s7
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_10
	tail epilogue_10
	.cfi_restore s10
	.cfi_restore s9
	.cfi_restore s8
	.cfi_restore s7
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

.macro restore_11
	tail epilogue_11
	.cfi_restore s11
	.cfi_restore s10
	.cfi_restore s9
	.cfi_restore s8
	.cfi_restore s7
	.cfi_restore s6
	.cfi_restore s5
	.cfi_restore s4
	.cfi_restore s3
	.cfi_restore s2
	.cfi_restore s1
	.cfi_restore ra
	.cfi_restore fp
	.cfi_def_cfa_offset 0
.endm

