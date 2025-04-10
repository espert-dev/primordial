# =============================================================================
# Configuration
# =============================================================================

BUILD_DIR ?= build
AS = riscv64-unknown-elf-gcc
ASFLAGS ?= -ggdb3 \
	-Wa,--fatal-warnings \
        -Wl,-Tlinker.ld \
        -Iinc \
        -mcmodel=medlow \
        -nostdlib \
        -static


# =============================================================================
# Targets
# =============================================================================

.PHONY: all
all: build

.PHONY: build
build: \
	$(BUILD_DIR)/lib/libentrypoint.a \
	$(BUILD_DIR)/cmd/true/true

$(BUILD_DIR)/lib/libentrypoint.a: lib/entrypoint/entrypoint.S
	mkdir -p $(BUILD_DIR)/lib
	$(AS) $(ASFLAGS) -c -o $@ $^


$(BUILD_DIR)/cmd/true/true: \
 		cmd/true/true.S \
		$(BUILD_DIR)/lib/libentrypoint.a
	mkdir -p $(BUILD_DIR)/cmd/true
	$(AS) $(ASFLAGS) -o $@ $^

.PHONY: clean
clean:
	@-rm -rfv build
