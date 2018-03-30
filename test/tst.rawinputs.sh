#
# This test exercises each of the inputs found in the same directory, starting
# with "input.{success,failure}.*".  Note that we only check the exit status
# directly in this file.  The test runner will check that stdout matches what
# we'd expect, which is most of what matters.
#

cmd="$(dirname ${BASH_SOURCE[0]})/../bin/httpmd5"
shopt -s nullglob

for file in input.success.*; do
	echo "test case: raw input file $file"
	if ! $cmd < $file 2>&1; then
		echo "unexpected failure: \"$file\""
		exit 1
	fi
	echo
done

for file in input.failure.*; do
	echo "test case: raw input file $file"
	if $cmd < $file 2>&1; then
		echo "unexpected success: \"$file\""
		exit 1
	fi
	echo
done

#
# Test a case with unexpected arguments passed.
#
echo "test case: unexpected arguments"
if "$cmd" boom 2>&1; then
	echo "unexpected success with extra arguments"
	exit 1
fi
echo

echo "all test cases run"
