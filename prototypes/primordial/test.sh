#!/bin/sh
set -eu

cd "$(dirname "$0")/../.."

# Read custom configuration from file.
if [ -f .env ]; then
	. ./.env
fi

BUILD_ROOT="${BUILD_ROOT:-build}"
build_dir="${BUILD_ROOT}/prototypes/primordial"
mkdir -p "${build_dir}"

# Build.
src_dir="prototypes/primordial"

flex\
	--header-file="${build_dir}/scanner.h"\
	-o "${build_dir}/scanner.c"\
	"${src_dir}/primordial.l"

bison -d -o "${build_dir}/parser.c" "${src_dir}/primordial.y"
gcc -o "${build_dir}/parser" "${build_dir}/parser.c" "${build_dir}/scanner.c"

# Run acceptance tests.
build_testdata_dir="${build_dir}/testdata"
mkdir -p "${build_testdata_dir}"

exit_code=0
src_testdata_dir="${src_dir}/testdata"
for input_file in "${src_testdata_dir}"/*.p; do
	name="$(basename "${input_file}" .p)"

	approved_output="${src_testdata_dir}/${name}.out"
	if ! [ -e "${approved_output}" ]; then
		touch "${approved_output}"
	fi

	actual_output="${build_testdata_dir}/${name}.out"
	diff="${build_testdata_dir}/${name}.diff"
	"${build_dir}/parser" < "${input_file}" > "${actual_output}"
	if ! diff "${approved_output}" "${actual_output}" >"${diff}" 2>&1; then
		exit_code=1
		echo "[FAIL: ${name}]"
		echo "Approved: ${approved_output}"
		echo "Actual:   ${actual_output}"
		echo "Diff:"
		cat "${diff}"
		echo
	fi
done

exit "${exit_code}"
