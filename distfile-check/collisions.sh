#!/bin/sh -e
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-2.0-only

tree="$1"
cd "$tree/distfile-urihash"

# Find all directories with more than one file
# Note: busybox find doesn't have -printf
collisions="$(find . -type f -printf '%h\n' | sort | uniq -d)"

if [ -z "$collisions" ]; then
	echo ":: Check passed, no collisions found"
	exit 0
fi

for collision in $collisions; do
	# collision looks like "./somefile.tar.gz"
	distfile="$(basename "$collision")"

	echo
	echo "'$distfile' has different hashes in:"

	for urihash_path in "$distfile"/*; do
		urihash="$(basename "$urihash_path")"
		for pkgname_path in "$tree/urihash-pkgname/$urihash/"*; do
			# print the path to the APKBUILD
			echo "  - $(cat "$pkgname_path")"
		done
	done
done

echo
echo "Add a target filename prefix to the source of your APKBUILD:"
echo "https://wiki.alpinelinux.org/wiki/APKBUILD_Reference#source"
echo
echo ":: Check failed"
exit 1
