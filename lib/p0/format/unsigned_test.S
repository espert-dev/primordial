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


# ===========================================================================
# Test cases
# ===========================================================================

.section .text

test_case Unsigned_does_not_write_to_nil_output
    save_0

    li a0, nil_size
    li a1, nil_data
    li a2, 0

    # May fault on failure.
    call "format.Unsigned"
    expect_eqi nil_size, a0
    expect_eqi nil_data, a1
    expect_eqi 0, a2

    restore_0
end_test
