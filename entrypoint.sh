#!/bin/sh

set -e

cd "$GITHUB_WORKSPACE"

git config --global --add safe.directory $GITHUB_WORKSPACE || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
REVIEWDOG_VERSION=v0.21.3
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing fasterer with extensions ... https://github.com/presidentbeef/fasterer'
if [ "$INPUT_FASTERER_VERSION" = "gemfile" ]; then
  if [ -f 'Gemfile.lock' ]; then
    FASTERER_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}fasterer\s\(\K.*(?=\))/' Gemfile.lock)
    if [ -n "$FASTERER_GEMFILE_VERSION" ]; then
      FASTERER_VERSION=$FASTERER_GEMFILE_VERSION
    else
      printf "Cannot get the fasterer's version from Gemfile.lock. The latest version will be installed."
    fi
  else
    printf 'Gemfile.lock not found. The latest version will be installed.'
  fi
else
  # set desired fasterer version
  FASTERER_VERSION=$INPUT_FASTERER_VERSION
fi

if [ -n "$FASTERER_VERSION" ]; then
  gem install -N fasterer --version "${FASTERER_VERSION}"
else
  gem install -N fasterer
fi
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running fasterer with reviewdog 🐶 ...'

# shellcheck disable=SC2086
fasterer 2>&1 | sed "s/\x1b\[[0-9;]*m//g" \
  | reviewdog \
  -efm="%f:%l %m" \
  -efm="%-G%.%#" \
  -name="${INPUT_TOOL_NAME:-fasterer}" \
  -reporter="${INPUT_REPORTER:-github-pr-check}" \
  -level="${INPUT_LEVEL:-error}" \
  -filter-mode="${INPUT_FILTER_MODE:-nofilter}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
  ${INPUT_REVIEWDOG_FLAGS}

exit_code=$?
echo '::endgroup::'

exit $exit_code
