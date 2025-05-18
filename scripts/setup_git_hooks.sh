#!/bin/sh
set -eu

cd "$(dirname "$(realpath "$0")")/.."
ln -sf ../../scripts/pre-commit_hook.sh .git/hooks/pre-commit
exit 0
