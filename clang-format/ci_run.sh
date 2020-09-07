#!/bin/sh -e

apk -q add clang

script_dir="$(cd "$(dirname "$0")"; pwd -P)"
"$script_dir"/clang-format.sh
