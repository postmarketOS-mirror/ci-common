# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-2.0-only

DISTFILETREE ?= /tmp/distfiletree
FINDOPTS ?=
SOURCE := $(shell find . -name APKBUILD $(FINDOPTS))
SOURCE := $(SOURCE:=.distfiletree)

default: info collisions

info:
	$(info :: Building distfiletree...)

%/APKBUILD.distfiletree: %/APKBUILD
	@./distfiletree.sh "$(DISTFILETREE)" "$<"

collisions: $(SOURCE)
	$(info :: Checking for collisions...)
	@./collisions.sh "$(DISTFILETREE)"

.PHONY: default info
