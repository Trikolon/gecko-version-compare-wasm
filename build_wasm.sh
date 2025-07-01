#!/usr/bin/env bash

# Build script for nsVersionComparator ➜ WebAssembly
# --------------------------------------------------
# On each run this script pulls the latest *upstream* versions of
#   xpcom/base/nsVersionComparator.h and nsVersionComparator.cpp
# from Mozilla's source tree (GitHub mirror) and then compiles them
# to WebAssembly via Emscripten, producing `dist/version_compare.{js,wasm}`.
#
# Remote source (default branch):
#   https://raw.githubusercontent.com/mozilla-firefox/firefox/main/xpcom/base/
#
# If you need to pin to a specific revision, set GECKO_REF before
# invoking the script, e.g. `GECKO_REF=firefox121 ./build_wasm.sh`.
# ---------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
mkdir -p dist

# Ensure native directory exists (holds upstream sources + local stubs)
NATIVE_DIR="$SCRIPT_DIR/native"
mkdir -p "$NATIVE_DIR"

# Fetch upstream sources before compilation
REMOTE_REPO="https://raw.githubusercontent.com/mozilla-firefox/firefox"
GECKO_REF="${GECKO_REF:-main}"
REMOTE_BASE="$REMOTE_REPO/$GECKO_REF/xpcom/base"

printf "[build-wasm] Fetching upstream nsVersionComparator sources (%s) …\n" "$GECKO_REF"

curl -sSfL "$REMOTE_BASE/nsVersionComparator.h" -o "$NATIVE_DIR/nsVersionComparator.h"
curl -sSfL "$REMOTE_BASE/nsVersionComparator.cpp" -o "$NATIVE_DIR/nsVersionComparator.cpp"

# ---------------------------------------------------------------------------

cd "$NATIVE_DIR"

# Build

echo "[build-wasm] Compiling nsVersionComparator …"

emcc \
  nsVersionComparator.cpp \
  "$SCRIPT_DIR/version_compare.cpp" \
  -I. -I"$SCRIPT_DIR" \
  -O3 -std=c++20 \
  -sEXPORT_ES6=1 \
  -sMODULARIZE=1 \
  -sENVIRONMENT=web \
  -sALLOW_MEMORY_GROWTH \
  -lembind \
  -o "$SCRIPT_DIR/dist/version_compare.js"

echo "[build-wasm] Done. Artifacts: version_compare.js + version_compare.wasm"