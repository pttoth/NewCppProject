#!/bin/bash

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

rootdir="$scriptdir/.."

platform=$1
arch=$2
compiler=mingw

pushd "$rootdir" > /dev/null
rootdir=$(pwd)

# check platform parameter
if [ -z $platform ] ; then
    echo "No platform defined! Running detection..."

    if [ -z $platform ] ; then
        platform=$( ./script/detect_platform.sh )
    fi

    if [ -z $arch ] ; then
        arch=$( ./script/detect_arch.sh )
    fi

    echo "  Platform:       ${platform}"
    echo "  Architecture:   ${arch}"
    echo "  Compiler:       ${compiler}"
fi


# TODO: figure out, when adding WSL container
if [[ "$platform" == "win64native" ]]; then
    platform=win
fi

echo "Creating startup script for platform '$platform'"

# enforce stricter platform def
if [[ "$platform" != "debian"
   && "$platform" != "win" ]] ;
then
    echo "Platform not supported: '$( ./script/detect_platform.sh )'!"
    exit 1
fi

# enforce stricter platform def
if [[ "$arch" != "amd64" ]] ;
then
    echo "Architecture not supported: '$( ./script/detect_arch.sh --force )'!"
    exit 1
fi


platformFull="${platform}_${arch}"


# verify that project was built for target platform
if [ ! -d "$rootdir/bin/$platformFull" ] ; then
    echo "Directory does not exist: '$rootdir/bin/$platformFull/'"
    echo "  Build project first!"
    exit 1
fi


fname=$(cat "$rootdir/script/data/common/__CFG_TARGET_EXECUTABLE_NAME__")

pathTemplate=""
pathStartupScriptName=""

if [[ "$platform" == "debian" ]] ; then
    pathTemplate=./script/data/start.sh.template
    pathStartupScriptName="./bin/$platformFull/start_$fname.sh"

elif [[ "$platform" == "win" || "$platform" == "win64native" || "$platform" == "win64" ]] ; then
    pathTemplate=./script/data/start.bat.template
    pathStartupScriptName="./bin/$platformFull/start_$fname.bat"

else
    echo "Platform unsupported! '$platformFull'"
    exit 1
fi

pwd
cat "$pathTemplate" \
    | tr '\n' '\r' \
    | sed "s/__CFG_TARGET_EXECUTABLE_NAME__/$fname/g" \
    | tr '\r' '\n' \
    > "$pathStartupScriptName"

chmod -v +x "$pathStartupScriptName"

popd > /dev/null
