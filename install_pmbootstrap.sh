#!/bin/sh -e
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later
# usage: install_pmbootstrap.sh [ADDITIONAL_PACKAGE, ...]

: "${PMBOOTSTRAP_TAG:="master"}"
: "${PMBOOTSTRAP_URL:="https://gitlab.com/postmarketOS/pmbootstrap.git"}"

# pmaports: either checked out in current dir, or let pmbootstrap download it
pmaports="$(cd "$(dirname "$0")"; pwd -P)"
pmaports_arg=""
if [ -e "$pmaports/pmaports.cfg" ]; then
	echo "Found pmaports.cfg in current dir"
	pmaports_arg="--aports '$pmaports'"
fi

# Set up depends and binfmt_misc
depends="coreutils
	git
	openssl
	procps
	python3
	sudo
	$*"
printf "Installing dependencies:"
for i in $depends; do
	printf "%s" " $i"
done
printf "\n"
# shellcheck disable=SC2086
apk -q add $depends
mount -t binfmt_misc none /proc/sys/fs/binfmt_misc

# Create pmos user
echo "Creating pmos user"
adduser -D pmos
chown -R pmos:pmos .
echo 'pmos ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Download pmbootstrap (to /tmp/pmbootstrap)
echo "Downloading pmbootstrap ($PMBOOTSTRAP_TAG): $PMBOOTSTRAP_URL"
cd /tmp
git clone -q "$PMBOOTSTRAP_URL"
git -C pmbootstrap checkout -q "$PMBOOTSTRAP_TAG"

# Install to $PATH and init
ln -s /tmp/pmbootstrap/pmbootstrap.py /usr/local/bin/pmbootstrap
echo "Initializing pmbootstrap"
if ! su pmos -c "yes '' | pmbootstrap \
		$pmaports_arg \
		--details-to-stdout \
		init \
		>/tmp/pmb_init 2>&1"; then
	cat /tmp/pmb_init
	echo
	echo "ERROR: pmbootstrap init failed!"
	echo
	echo "Most likely, this gets fixed by rebasing on master (or whatever"
	echo "branch yours is based on). Please do this and try again."
	echo
	echo "Let us know in the chat or issues if you have trouble with that"
	echo "and we will be happy to help. Sorry for the inconvenience."
	exit 1
fi
echo ""
