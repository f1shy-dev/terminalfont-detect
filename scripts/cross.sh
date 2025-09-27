#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p dist

# Help Zig find macOS SDK frameworks when cross-targeting
if [[ "${OSTYPE:-}" == darwin* ]]; then
	if command -v xcrun >/dev/null 2>&1; then
		export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
	fi
fi

function build() {
	local target="$1"; shift
	local out_name="$1"; shift
	local extra=("$@")
	bunx --yes zig build -Dtarget="$target" -Doptimize=ReleaseFast "${extra[@]}"
	# Copy artifact
	local bin="zig-out/bin/terminalfont-detect"
	if [[ "$target" == *windows* ]]; then
		bin+=".exe"
	fi
	cp -f "$bin" "dist/${out_name}"
}

echo "Building macOS aarch64..."
if [[ -n "${SDKROOT:-}" ]]; then
	build aarch64-macos terminalfont-detect-macos-aarch64 -Dsysroot="$SDKROOT"
else
	build aarch64-macos terminalfont-detect-macos-aarch64
fi

echo "Building macOS x86_64..."
if [[ -n "${SDKROOT:-}" ]]; then
	build x86_64-macos terminalfont-detect-macos-x86_64 -Dsysroot="$SDKROOT"
else
	build x86_64-macos terminalfont-detect-macos-x86_64
fi

if command -v lipo >/dev/null 2>&1; then
	 echo "Creating macOS universal (fat)..."
	 lipo -create \
	   -output dist/terminalfont-detect-macos-universal \
	   dist/terminalfont-detect-macos-aarch64 \
	   dist/terminalfont-detect-macos-x86_64
fi

echo "Building Linux x86_64..."
build x86_64-linux-gnu terminalfont-detect-linux-x86_64

echo "Building Linux aarch64..."
build aarch64-linux-gnu terminalfont-detect-linux-aarch64

echo "Building Windows x86_64..."
build x86_64-windows-gnu terminalfont-detect-windows-x86_64.exe

echo "Building Windows aarch64..."
build aarch64-windows-gnu terminalfont-detect-windows-aarch64.exe

echo "Done. Artifacts in dist/"


