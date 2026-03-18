#!/bin/sh
set -eu

echo "Installing KernelDex CLI..."

if ! command -v cargo >/dev/null 2>&1; then
  echo "Error: Rust toolchain not found. Install from https://rustup.rs"
  exit 1
fi

cargo install --git https://github.com/ipnon/kerneldex kerneldex
echo "Done. Run 'kerneldex --help' to get started."
