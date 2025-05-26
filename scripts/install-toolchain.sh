#!/bin/sh
set -eu

os="ubuntu-24.04"

# Go to the top directory of the repo.
cd "$(dirname "$0")/.."

# Load toolchain version (shared between scripts).
version="$(cat .toolchain_version)"

# Read custom configuration from file.
if [ -f .env ]; then
	. ./.env
fi

TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-toolchain}"

install_toolchain() {
	xlen="$1"

	url="https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/${version}/riscv${xlen}-elf-${os}-gcc-nightly-${version}-nightly.tar.xz"
	archive="${TOOLCHAIN_ROOT}/rv${xlen}-${version}.tar.xz"
	dest="${TOOLCHAIN_ROOT}/rv${xlen}-${version}"

	if [ -d "${dest}" ]; then
		echo "The rv${xlen} toolchain is already installed."
		return
	fi

	echo "Toolchain rv${xlen} not found. Installing..."
	mkdir -p "${dest}"
	wget -O "${archive}" "${url}"
	tar -C "${dest}" --xz -xvf "${archive}"
	rm "${archive}"
}

install_toolchain 32
install_toolchain 64
