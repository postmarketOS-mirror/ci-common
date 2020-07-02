#!/bin/sh -e
# shellcheck disable=SC2039
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-2.0-only

tree="$1"
apkbuild_path="$2"

# abuild_functions stub
arch_to_hostspec() {
	:
}

# Source APKBUILD / stubs for shellcheck
pkgname=""
source=""
sha512sums=""
# shellcheck disable=SC1090
. "$apkbuild_path"

distfile_hash() {
	local distfile="$1"

	IFS=$'\n'
	for line in $sha512sums; do
		case "$line" in
			*"  $distfile")
				echo "$line" | cut -d" " -f 1
				break
				;;
		esac
	done
	unset IFS
}

# from abuild.in
is_remote() {
	case "${1#*::}" in
		http://*|ftp://*|https://*)
			return 0;;
	esac
	return 1
}
filename_from_uri() {
	local uri="$1"
	local filename="${uri##*/}"  # $(basename $uri)
	case "$uri" in
	*::*) filename=${uri%%::*};;
	esac
	echo "$filename"
}

# Build distfiletree
for s in $source; do
	is_remote "$s" || continue

	distfile="$(filename_from_uri "$s")"
	urihash="$(distfile_hash "$distfile")"
	if [ -z "$urihash" ]; then
		echo "ERROR: pkgname=$pkgname, distfile=$distfile:" \
			"failed to find urihash!"
		exit 1
	fi

	mkdir -p \
		"$tree/distfile-urihash/$distfile" \
		"$tree/urihash-pkgname/$urihash"

	touch "$tree/distfile-urihash/$distfile/$urihash"
	echo "$2" > "$tree/urihash-pkgname/$urihash/$pkgname"
done
