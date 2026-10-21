#!/usr/bin/env bash
# Build the x64 client on Linux into bin/Win/. Extra arguments go to the CMake configure step.
# Usage: Tools/CloudBuild/build.sh [-DWOWDECOMP_DISABLE_SIGNATURE_CHECKS=ON ...]
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
build=$root/build/x64

cmake -S "$root" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE="$here/clang-cl-x64.cmake" "$@"
ninja -C "$build" WowClient Wow XvidDecoder
