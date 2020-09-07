#!/bin/sh

clang-format --version

# shellcheck disable=SC2046
clang-format -i $(find . -regex '.*\.\(c\|cpp\|h\)')

git diff > differences.patch

if [ -s differences.patch ]; then
    echo "C-Code formatting check failed!"
    echo "Please make sure, the code is formatted properly!"
    echo "Run:"
    # shellcheck disable=SC2016
    echo '    clang-format -i $(find . -regex '\''.*\.\(c\|cpp\|h\)'\'')'
    echo
    cat differences.patch
    echo
    rm differences.patch
    exit 1
else
    echo "C-Code formatting check is sucessful!"
    exit 0
fi
