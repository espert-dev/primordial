#!/bin/sh
set -eu

script_base="$(dirname "$(realpath "$0")")"
"$script_base/remove_multiple_trailing_newlines.sh"
exit 0
