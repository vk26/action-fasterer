#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running fasterer with reviewdog 🐶 ...'

fasterer | sed "s/\x1b\[[0-9;]*m//g" \
  | reviewdog -efm="%f:%l %m" -efm="%-G%.%#" -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
  
exit_code=$?
echo '::endgroup::'

exit $exit_code
