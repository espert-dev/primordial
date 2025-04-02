# ===========================================================================
# String formatting tests - Unsigned
# ===========================================================================

#include <millicode.S>
#include <safe_str.S>
#include <testing.S>


# ===========================================================================
# Test data
# ===========================================================================

# An attempt to write here will fault.
.equiv nil_data, 0
.equiv nil_size, 0

.section bss
.p2align 4

.equiv buffer_size, 16
.lcomm buffer_data, buffer_size


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Unsigned_does_not_write_to_nil_output
    save_0

    li a0, nil_size
    li a1, nil_data
    li a2, 0
    li a3, 0

    # May fault on failure.
    call "format.Unsigned"
    expect_eqi nil_size, a0
    expect_eqi nil_data, a1
    expect_eqi 0, a2

    restore_0
end_test

test_case Unsigned_0
    save_0

    la a0, buffer_size
    la a1, buffer_data
    li a2, 0
    li a3, 0

    call "format.Unsigned"

    expect_eqi buffer_size, a0
    expect_eqa buffer_data, a1
    expect_eqi 1, a2

    la t0, buffer_data
    lbu t1, 0(t0)
    expect_eqi '0', t1

    restore_0
end_test

test_case Unsigned_1
    save_0

    la a0, buffer_size
    la a1, buffer_data
    li a2, 0
    li a3, 1

    call "format.Unsigned"

    expect_eqi buffer_size, a0
    expect_eqa buffer_data, a1
    expect_eqi 1, a2

    la t0, buffer_data
    lbu t1, 0(t0)
    expect_eqi '1', t1

    restore_0
end_test

test_case Unsigned_2
    save_0

    la a0, buffer_size
    la a1, buffer_data
    li a2, 0
    li a3, 2

    call "format.Unsigned"

    expect_eqi buffer_size, a0
    expect_eqa buffer_data, a1
    expect_eqi 1, a2

    la t0, buffer_data
    lbu t1, 0(t0)
    expect_eqi '2', t1

    restore_0
end_test

test_case Unsigned_9
    save_0

    la a0, buffer_size
    la a1, buffer_data
    li a2, 0
    li a3, 9

    call "format.Unsigned"

    expect_eqi buffer_size, a0
    expect_eqa buffer_data, a1
    expect_eqi 1, a2

    la t0, buffer_data
    lbu t1, 0(t0)
    expect_eqi '9', t1

    restore_0
end_test
