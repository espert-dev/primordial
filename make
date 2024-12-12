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

# Apply defaults.
AS="${AS:-riscv64-unknown-elf-gcc}"
ASFLAGS="${ASFLAGS:--ggdb3 -mcmodel=medlow -nostdlib -static}"
BUILD_ROOT="${BUILD_ROOT:-build}"

# ===========================================================================
# Helpers
# ===========================================================================

info() {
	echo "$*" >&2
}

die() {
	if [ -t 1 ]; then
		echo "\e[0;31m$*\e[0m" >&2
	else
		echo "$*" >&2
	fi

	exit 1
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

	info "Assembling $source..."

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

	info "Building library $target..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	ar rcs "$target" "$@"
}

build_executable() {
	target="$BUILD_ROOT/$1"
	shift

	info "Building executable $target..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	"$AS" $ASFLAGS -o "$target" "$@" "$BUILD_ROOT/lib/libentrypoint.a"
}

with_test() {
	target="$BUILD_ROOT/$1"
	source="$1.S"
	shift

	# Build test.
	info "Building test $target..."

	target_dir="$(dirname "$target")"
	mkdir -p "$target_dir"

	"$AS" $ASFLAGS -o "$target" \
		"$source" \
		"$@" \
		"$BUILD_ROOT/lib/libtesting.a" \
		"$BUILD_ROOT/lib/libentrypoint.a"

	# Run test.
	info "Running test $target..."
	if ! "$target" >"$target.out" 2>&1; then
		cat "$target.out"
		die "Test $target failed!"
	fi
}

# ===========================================================================
# Build instructions
# ===========================================================================

clean

# Build the core library.
assemble lib/entrypoint/entrypoint.S

build_library lib/libentrypoint.a \
	"$BUILD_ROOT/lib/entrypoint/entrypoint.o"

assemble lib/p0/os.S

build_library lib/libp0.a \
	"$BUILD_ROOT/lib/p0/os.o"

# Build a very simple program that uses libp0 and terminates successfully.
assemble cmd/true/true.S

build_executable cmd/true/true \
	"$BUILD_ROOT/cmd/true/true.o" \
	"$BUILD_ROOT/lib/libp0.a"

# Sanity check: must execute and terminates successfully.
"$BUILD_ROOT/cmd/true/true"

info "Done."
