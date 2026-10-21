#!/usr/bin/env bash
# One-time setup for building and running the client on Linux (cloud sessions): clang-cl + lld-link against the
# MSVC/Windows SDK NuGet packages, Wine to run it, Xvfb + ffmpeg to record it.
# Env: MSVC_ROOT (default /opt/msvc)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
msvc=${MSVC_ROOT:-/opt/msvc}
sdk_version=10.0.26100.4188
vc_version=14.11.25547

packages=(wine64 xvfb x11-utils xdotool imagemagick ffmpeg mesa-utils libgl1-mesa-dri clang lld llvm cmake ninja-build unzip python3)
missing=()
for pkg in "${packages[@]}"; do
    dpkg -s "$pkg" > /dev/null 2>&1 || missing+=("$pkg")
done
if ((${#missing[@]})); then
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
fi

# The Visual Studio download hosts xwin uses are not reachable from every network, so the toolset comes from NuGet:
# the Windows SDK (headers, import libs, UCRT) and the VS2017 MSVC 14.11 layout (STL, vcruntime, CRT libs).
fetch() {
    local id=$1 version=$2 dir=$3
    [[ -d $msvc/$dir ]] && return
    mkdir -p "$msvc/pkgs" "$msvc/$dir"
    local file=$msvc/pkgs/$id.$version.nupkg
    [[ -f $file ]] || curl -sSfL --retry 4 -o "$file" "https://api.nuget.org/v3-flatcontainer/$id/$version/$id.$version.nupkg"
    unzip -q -o "$file" -d "$msvc/$dir"
}

fetch microsoft.windows.sdk.cpp $sdk_version sdk
fetch microsoft.windows.sdk.cpp.x64 $sdk_version sdkx64
fetch visualcpptools.community.vs2017layout $vc_version vc

# Windows headers and libs include each other with inconsistent casing; give clang and lld a case-insensitive view.
vc=$msvc/vc/lib/native
inc=$msvc/sdk/c/Include/${sdk_version%.*}.0
lib=$msvc/sdkx64/c
python3 "$here/mkoverlay.py" "$msvc/overlay.json" \
    "$vc/include=$vc/include" "$vc/lib/x64=$vc/lib/x64" \
    "$inc/ucrt=$inc/ucrt" "$inc/um=$inc/um" "$inc/shared=$inc/shared" "$inc/winrt=$inc/winrt" \
    "$lib/um/x64=$lib/um/x64" "$lib/ucrt/x64=$lib/ucrt/x64"

echo "MSVC toolset and Windows SDK ready in $msvc"
