#!/bin/sh
set -eu

all_test_cases() {
	find prototypes/primordial/testdata/ -type f -name '*.p' -printf '%P\n'
}

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
src_testdata_dir="${src_dir}/testdata"
exit_code=0

all_test_cases | while IFS= read -r test_case; do
	input_file="${src_testdata_dir}/${test_case}"
	base="$(dirname "${test_case}")/$(basename "${test_case}" .p)"
	actual_output="${build_testdata_dir}/${base}.out"
	diff="${build_testdata_dir}/${base}.diff"
	approved_output="${src_testdata_dir}/${base}.out"

	if ! [ -e "${approved_output}" ]; then
		touch "${approved_output}"
	fi

	mkdir -p "$(dirname "${actual_output}")"

	"${build_dir}/parser" < "${input_file}" > "${actual_output}"
	if ! diff "${approved_output}" "${actual_output}" >"${diff}" 2>&1; then
		exit_code=1
		echo "[FAIL: ${base}]"
		echo "Approved: ${approved_output}"
		echo "Actual:   ${actual_output}"
		echo "Diff:"
		cat "${diff}"
		echo
	fi
done

exit "${exit_code}"
