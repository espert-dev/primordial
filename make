#!/bin/sh
# Build system for Primordial (all supported XLEN values)
set -eu

# Go to the top directory of the repo.
cd "$(dirname "$0")"
pwd

# Toolchain configuration.
toolchain_version="$(cat .toolchain_version)"

# Read custom configuration from file.
if [ -f .env ]; then
	. ./.env
fi

# Ensure that the toolchain is installed.
scripts/install-toolchain.sh
echo

TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-toolchain}"

XLEN=32 \
  AS="${AS32:-$(realpath "${TOOLCHAIN_ROOT}/rv32-${toolchain_version}/riscv/bin/riscv32-unknown-elf-gcc")}" \
  scripts/make-xlen.sh

XLEN=64 \
  AS="${AS64:-$(realpath "${TOOLCHAIN_ROOT}/rv64-${toolchain_version}/riscv/bin/riscv64-unknown-elf-gcc")}" \
  scripts/make-xlen.sh

exit 0
