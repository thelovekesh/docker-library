#!/bin/bash

set -e

if [[ -z "$LANDO_MOUNT" ]]; then
  echo "Error: Must be run from within a Lando environment."
  exit 1
fi

export WP_CORE_DIR=${WP_CORE_DIR:-$LANDO_MOUNT/wp}
export WP_TESTS_DIR=${WP_TESTS_DIR:-$LANDO_MOUNT/tests/wp-phpunit}

install_wp() {
  if [[ ! -d "$WP_CORE_DIR" || ! -d "$WP_TESTS_DIR" ]]; then
    if [[ -z "$WP_VERSION" ]]; then
      WP_VERSIONS=$(curl -s https://raw.githubusercontent.com/wp-cli/wp-cli-tests/artifacts/wp-versions.json)
      export WP_VERSION=$(echo $WP_VERSIONS | jq -r 'to_entries|map(select(.value == "latest"))[0].key')
    fi

    local GIT_BRANCH=$WP_VERSION

    if grep -isqE 'trunk|alpha|beta|rc' <<< "$WP_VERSION"; then
      local GIT_BRANCH=trunk
      local SVN_URL=https://develop.svn.wordpress.org/trunk/
    elif [ "$WP_VERSION" == 'latest' ]; then
      local SVN_URL="https://develop.svn.wordpress.org/tags/$WP_VERSION/"
    elif [[ "$WP_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
      local SVN_URL="https://develop.svn.wordpress.org/branches/$WP_VERSION/"
    else
      local SVN_URL="https://develop.svn.wordpress.org/tags/$WP_VERSION/"
    fi
  fi

  if [[ ! -d "$WP_CORE_DIR" ]]; then
    echo "Downloading WordPress Core to $WP_CORE_DIR"
    git clone https://github.com/WordPress/WordPress.git --depth 1 --branch $GIT_BRANCH "$WP_CORE_DIR"
    rm -rf "$WP_CORE_DIR/.git"
  else
    echo "WordPress Core already downloaded to $WP_CORE_DIR"
    echo "To download a fresh copy, delete the wp directory and re-run \`lando setup-wordpress\`"
  fi

  if [[ ! -d "$WP_TESTS_DIR" ]]; then
    echo "Downloading WordPress Test Suite to $WP_TESTS_DIR"
    mkdir -p "$WP_TESTS_DIR"
    svn export -q "${SVN_URL}"/tests/phpunit/includes/ "$WP_TESTS_DIR/includes"
    svn export -q "${SVN_URL}"/tests/phpunit/data/ "$WP_TESTS_DIR/data"
  else
    echo "WordPress Test Suite already downloaded to $WP_TESTS_DIR"
    echo "To download a fresh copy, delete the tests/wp-phpunit directory and re-run \`lando setup-wordpress\`"
  fi
}

install_wp
