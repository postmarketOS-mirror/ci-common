#!/bin/sh -ex
# Run various code paths of install_pmbootstrap.sh

# Install pmbootstrap, with random dependencies
sh -ex ./install_pmbootstrap.sh tmux neovim

# Check if dependencies were installed
if ! apk info -vv | grep -q neovim; then
	echo "ERROR: dependency was not installed with install_pmbootstrap.sh!"
	exit 1
fi

# Run code with pmbootstrap
su pmos -c "pmbootstrap chroot -- echo 'hello world'"

# Make sure binfmt_misc works
su pmos -c "pmbootstrap chroot -baarch64 -- echo 'hello world'"

# Simulate running in already cloned pmaports.git dir
cp -r "$(su pmos -c 'pmbootstrap -q config aports')" /tmp/pmaports
cp install_pmbootstrap.sh /tmp/pmaports
cd /tmp/pmaports

# Run twice from pmaports.git, to trigger both code paths of
# add_remote_origin_original()
for _ in $(seq 1 2); do
	sh -ex ./install_pmbootstrap.sh
	su pmos -c "pmbootstrap chroot -- echo 'hello world'"
done

echo "done"
