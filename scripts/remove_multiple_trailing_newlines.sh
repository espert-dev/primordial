#!/bin/sh
set -eu

find -not -wholename './.*' -not -wholename './build' -type f -exec \
	sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' '{}' \;
