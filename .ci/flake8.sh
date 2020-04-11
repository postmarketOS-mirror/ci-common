#!/bin/sh -e
topdir="$(realpath "$(dirname "$0")/..")"
cd "$topdir"

# shellcheck disable=SC2046
flake8 $(find . -name '*.py')

echo "flake8 check passed"
