#!/bin/sh
# Build system for Primordial.
#
# Note that assembly source files must use the .S extension, not .s, and must
# be compiled with GCC, not GNU AS. Otherwise the preprocessor, which we need
# to assign aliases to registers, wouldn't work.
set -eu

# Ensure that the script always runs at the top of the repository.
cd "$(realpath $(dirname "$0"))"

# ===========================================================================
# Build configuration (via environment variables or .env)
# ===========================================================================

# Read custom configuration from file.
if [ -f .env ]; then
	. ./.env
fi

# A good alternative location for this is something like /tmp/primordial.
# If it's on tmpfs, you will hammer your drive a bit less.
BUILD_ROOT="${BUILD_ROOT:-build}"
COLORIZE=${COLORIZE:-}

# Even if we only use assembler, it still needs a compiler (gcc).
# -T enhances, rather than replaces, the linker script.
AS="${AS:-riscv64-unknown-elf-gcc}"
ASFLAGS="${ASFLAGS:--ggdb3 -Wl,-Tlinker.ld -Iinc -mcmodel=medlow -nostdlib -static}"

# ===========================================================================
# Helpers
# ===========================================================================

if [ -z "$COLORIZE" -a -t 1 ]; then
	COLORIZE=1
fi

die() {
	if [ -n "$COLORIZE" -a "$COLORIZE" != 0 ]; then
		echo "\e[0;31m$*\e[0m" >&2
	else
		echo "$*" >&2
	fi

	exit 1
}

info() {
	echo "$*" >&2
}

section() {
	if [ -n "$COLORIZE" -a "$COLORIZE" != 0 ]; then
		echo "\n\e[1;35m$*\e[0m" >&2
	else
		echo "\n$*" >&2
	fi
}

# ===========================================================================
# Build rules
# ===========================================================================

clean() {
	info "Cleaning build..."
	rm -fr "$BUILD_ROOT"
}

assemble() {
	source="$1"

	info "Assembling $source ..."

	source_dir="$(dirname "$source")"
	target_dir="$BUILD_ROOT/$source_dir"
	mkdir -p "$target_dir"

	target_name="$(basename -s .S "$source").o"
	target="$target_dir/$target_name"
	"$AS" $ASFLAGS -c -o "$target" "$source"
}

build_library() {
	target="$BUILD_ROOT/$1"
	shift

	info "Building library $target ..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	ar rcs "$target" "$@"
}

build_executable() {
	target="$BUILD_ROOT/$1"
	shift

	info "Building executable $target ..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	"$AS" $ASFLAGS -o "$target" \
		"$@" \
		"$BUILD_ROOT/lib/libentrypoint.a" \
		"$BUILD_ROOT/lib/libmillicode.a"
}

with_test() {
	target="$BUILD_ROOT/$1"
	source="$1.S"
	shift

	# Build test.
	info "Building test $target ..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	"$AS" $ASFLAGS -o "$target" \
		"$source" \
		"$@" \
		"$BUILD_ROOT/lib/libentrypoint.a" \
		"$BUILD_ROOT/lib/libtesting.a" \
		"$BUILD_ROOT/lib/libmillicode.a"

	# Run test.
	info "Running test $target..."
	if ! "$target" >"$target.out" 2>&1; then
		cat "$target.out"
		die "Test $target failed!"
	fi
}

sanity_check() {
	target="$1"
	shift

	info "Running sanity check $target ..."
	"$target" "$@"
}

# ===========================================================================
# Build instructions
# ===========================================================================

clean

section Build the millicode library.
assemble lib/millicode/frame_0.S
assemble lib/millicode/frame_1.S
assemble lib/millicode/frame_2.S
assemble lib/millicode/frame_3.S
assemble lib/millicode/frame_4.S
assemble lib/millicode/frame_5.S
assemble lib/millicode/frame_6.S
assemble lib/millicode/frame_7.S
assemble lib/millicode/frame_8.S
assemble lib/millicode/frame_9.S
assemble lib/millicode/frame_10.S
assemble lib/millicode/frame_11.S

build_library lib/libmillicode.a \
	"$BUILD_ROOT/lib/millicode/frame_0.o" \
	"$BUILD_ROOT/lib/millicode/frame_1.o" \
	"$BUILD_ROOT/lib/millicode/frame_2.o" \
	"$BUILD_ROOT/lib/millicode/frame_3.o" \
	"$BUILD_ROOT/lib/millicode/frame_4.o" \
	"$BUILD_ROOT/lib/millicode/frame_5.o" \
	"$BUILD_ROOT/lib/millicode/frame_6.o" \
	"$BUILD_ROOT/lib/millicode/frame_7.o" \
	"$BUILD_ROOT/lib/millicode/frame_8.o" \
	"$BUILD_ROOT/lib/millicode/frame_9.o" \
	"$BUILD_ROOT/lib/millicode/frame_10.o" \
	"$BUILD_ROOT/lib/millicode/frame_11.o"

section Build the entrypoint library.
assemble lib/entrypoint/entrypoint.S

build_library lib/libentrypoint.a \
	"$BUILD_ROOT/lib/entrypoint/entrypoint.o"

section Build a simple program that uses libentrypoint.
assemble cmd/true/true.S

build_executable cmd/true/true \
	"$BUILD_ROOT/cmd/true/true.o"

sanity_check "$BUILD_ROOT/cmd/true/true"

section Build the testing library.
assemble lib/testing/testing.S

build_library lib/libtesting.a \
	"$BUILD_ROOT/lib/testing/testing.o"

section Build the core library.
assemble lib/p0/ascii/ascii.S
assemble lib/p0/os/exit.S
assemble lib/p0/io/write.S

build_library lib/libp0.a \
	"$BUILD_ROOT/lib/p0/ascii/ascii.o" \
	"$BUILD_ROOT/lib/p0/os/exit.o" \
	"$BUILD_ROOT/lib/p0/io/write.o"

section Test the core library.
with_test lib/p0/ascii/ascii_test \
	"$BUILD_ROOT/lib/libp0.a"

with_test lib/p0/io/write_test \
	"$BUILD_ROOT/lib/libp0.a"

section Build a simple program that uses libp0.
assemble cmd/hello/hello.S

build_executable cmd/hello/hello \
	"$BUILD_ROOT/cmd/hello/hello.o" \
	"$BUILD_ROOT/lib/libp0.a"

sanity_check "$BUILD_ROOT/cmd/hello/hello"

# If the execution reached here, the build completed successfully.
echo
if [ -t 1 ]; then
	echo "\e[1;32mDone.\e[0m"
else
	echo "Done."
fi
