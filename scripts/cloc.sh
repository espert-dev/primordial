#!/bin/sh
# Counts the number of lines of code (LoCs).
set -eu

cd "$(dirname "$0")/.."

cloc --exclude-dir=.git,.idea,build,toolchain .
