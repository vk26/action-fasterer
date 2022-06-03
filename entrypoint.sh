#!/bin/sh

version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "$GITHUB_WORKSPACE"

git config --global --add safe.directory $GITHUB_WORKSPACE || exit 1

echo '::group:: Installing fasterer ... https://github.com/DamirSvrtan/fasterer'
# if 'gemfile' fasterer version selected
if [ "$INPUT_FASTERER_VERSION" = "gemfile" ]; then
  # if Gemfile.lock is here
  if [ -f 'Gemfile.lock' ]; then
    # grep for fasterer version
    FASTERER_GEMFILE_VERSION=$(grep -oP '^\s{4}fasterer\s\(\K.*(?=\))' Gemfile.lock)

    # if fasterer version found, then pass it to the gem install
    # left it empty otherwise, so no version will be passed
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

# shellcheck disable=SC2046,SC2086
gem install -N fasterer $(version $FASTERER_VERSION)
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running fasterer with reviewdog 🐶 ...'

fasterer | sed "s/\x1b\[[0-9;]*m//g" \
  | reviewdog -efm="%f:%l %m" -efm="%-G%.%#" -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
  
exit_code=$?
echo '::endgroup::'

exit $exit_code
