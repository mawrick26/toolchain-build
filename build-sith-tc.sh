#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2019 mawrick26
# Script to build a toolchain for Sith Kernel development v1

# Exit on error
set -e

# Function to show an informational message
function msg() {
    echo -e "\e[1;32m$@\e[0m"
}

# Configure LLVM build based on environment or arguments
	msg "Configuring  LLVM build..."
	llvm_args=(--targets "ARM;AArch64" --march "native" --lto thin)
	binutils_args=(--targets arm aarch64 x86_64 --march "native")

# Build LLVM
msg "Building LLVM..."
./build-llvm.py \
	 -I "${HOME}/toolchains/LLVM" \
	--clang-vendor "maw26" \
	--projects "clang;compiler-rt;lld;polly" \
	--pgo \
	"${llvm_args[@]}"

# Build binutils
msg "Building binutils..."
./build-binutils.py \
	 -I "${HOME}/toolchains/LLVM" \
	"${binutils_args[@]}"

# Remove unused products
msg "Removing unused products..."
rm -fr "${HOME}/toolchains/LLVM/include"
rm -f "${HOME}/toolchains/LLVM/lib/*.a"
rm -f "${HOME}/toolchains/LLVM/lib/*.la"

# Strip remaining products
msg "Stripping remaining products..."
for f in $(find "${HOME}/toolchains/LLVM" -type f -exec file {} \; | grep 'not stripped' | awk '{print $1}'); do
	strip ${f: : -1}
done
