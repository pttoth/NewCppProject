#!/bin/bash

set -Eeuo pipefail

echo "Setting up toolchain..."

#-------------------------
# Resolve paths relative to this script.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"

TOOLSET_NAME="win64_mingw"
TOOLSET_DIR="$ROOT_DIR/build_toolset/$TOOLSET_NAME"

# Tool versions and download URLs
GIT_LINK="https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.2/PortableGit-2.47.1.2-64-bit.7z.exe"
GIT_ARCHIVE="PortableGit-2.47.1.2-64-bit.7z.exe"

CMAKE_LINK="https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-windows-x86_64.zip"
CMAKE_ARCHIVE="cmake-3.31.4-windows-x86_64.zip"
CMAKE_DIR=cmake-3.31.4-windows-x86_64

MINGW_LINK="https://downloads.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z"
MINGW_ARCHIVE="x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z"

SEVENZIP_LINK="https://7-zip.org/a/7zr.exe"

TIMESTAMP="$(date +%y%m%d_%H%M%S)"

# Download helper. Use Windows curl explicitly.
download() {
    local url="$2"
    local name="$1"

    echo "-----"
    echo Downloading "'$name'"
    echo   from "'$url'"
    curl.exe --fail --location --retry 3 -O "$url"
    echo
}

# Extract a 7z archive using the downloaded 7zr.exe.
extract_7z() {
    local archive="$1"
    local destination="$2"

    mkdir -vp "$destination"

    "$TOOLSET_DIR/7zr.exe" x "$archive" "-o$destination" -y
}


. "$SCRIPT_DIR/set_env.sh"


# Check whether the toolchain is already available.
if "$SCRIPT_DIR/detect_toolset.sh"; then
    echo "Toolset is already available, skipping acquire step."
    exit 0
fi

echo "Detected missing tools! The script will set up the toolset."
echo "Windows Defender may interfere with automatic downloads."
echo "If acquisition fails, manually download the tools from:"
echo "  Git:   $GIT_LINK"
echo "  CMake: $CMAKE_LINK"
echo "  MinGW: $MINGW_LINK"
echo
echo "Acquiring toolset in 10 seconds..."
sleep 10



# Back up any existing toolset.
if [[ -e "$TOOLSET_DIR" ]]; then
    BACKUP_DIR="${TOOLSET_DIR}_bak_${TIMESTAMP}"

    echo "Backing up existing toolset to:"
    echo "  $BACKUP_DIR"

    mv -v -- "$TOOLSET_DIR" "$BACKUP_DIR"
fi

#-------------------------
# Create the build directory.
mkdir -vp "$TOOLSET_DIR"
cd "$TOOLSET_DIR"

download "7-Zip" $SEVENZIP_LINK
download "Git"   $GIT_LINK
download "CMake" $CMAKE_LINK
download "MinGW" $MINGW_LINK

#-------------------------
# Extract archives
echo "-------------------------"
echo "Extracting git..."
extract_7z "$GIT_ARCHIVE" "$TOOLSET_DIR/PortableGit"

echo "-------------------------"
echo "Extracting CMake (powershell is terribly slow) ..."
powershell -command "(Expand-Archive -Force '$CMAKE_ARCHIVE' .)"

echo "-------------------------"
echo "Extracting MinGW..."
extract_7z "$MINGW_ARCHIVE" "$TOOLSET_DIR/mingw"

#-------------------------
# Remove archives
rm -vf -- "$GIT_ARCHIVE"

mv -v -- "$CMAKE_DIR" "$TOOLSET_DIR/cmake"
rm -vf -- "$CMAKE_ARCHIVE"

rm -vf -- "$MINGW_ARCHIVE"

rm -vf -- "$TOOLSET_DIR/7zr.exe"
