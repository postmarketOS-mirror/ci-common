#!/bin/sh -e
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-2.0-only

# Prepare testdir
TESTDIR="/tmp/test"
rm -rf "$TESTDIR"
mkdir -p "$TESTDIR"
cp ./*.sh Makefile "$TESTDIR"
cd "$TESTDIR"

# 1. Two packages with same hash in remote file
mkdir -p "device/testing/device-asdf-first"
cat << EOF > "device/testing/device-asdf-first/APKBUILD"
pkgname="device-asdf-first"
source="deviceinfo https://localhost/file.txt"
sha512sums="
ffffff  file.txt
aaaaaa  deviceinfo
"
EOF

mkdir -p "device/testing/device-asdf-second"
cat << EOF > "device/testing/device-asdf-second/APKBUILD"
pkgname="device-asdf-second"
source="deviceinfo https://localhost/file.txt"
sha512sums="
ffffff  file.txt
bbbbbb  deviceinfo
"
EOF

# Expect OK
rm -rf /tmp/distfiletree
if ! make -j999; then
	echo "ERROR in $LINENO"
	exit 1
fi

# 2. One package has a different hash for the remote file
mkdir -p "main/randompkg"
cat << EOF > "main/randompkg/APKBUILD"
pkgname="randompkg"
source="https://localhost/file.txt"
sha512sums="
000000  file.txt
"
EOF

# Expect NOK
rm -rf /tmp/distfiletree
if make -j999; then
	echo "ERROR in $LINENO"
	exit 1
fi
