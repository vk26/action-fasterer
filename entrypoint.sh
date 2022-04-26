#!/bin/sh

cd "$GITHUB_WORKSPACE"

git config --global --add safe.directory $GITHUB_WORKSPACE || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

fasterer | sed "s/\x1b\[[0-9;]*m//g" \
  | reviewdog -efm="%f:%l %m" -efm="%-G%.%#" -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
