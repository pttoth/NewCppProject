#!/bin/bash

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

rootdir="$scriptdir/.."

platform=$1
arch=mingw

pushd "$rootdir" > /dev/null
rootdir=$(pwd)

# check platform parameter
if [ -z $platform ] ; then
    echo "No platform defined!"
    echo "  Choosing default: 'debian_amd64'"
    platform=debian
    arch=amd64
    #exit 1
fi

if [[ "$platform" == "win64native" ]]; then
    platform=win64
fi

echo "Creating startup script for platform '$platform'"

# enforce stricter platform def
if [[ "$platform" == "debian_amd64" \
   || "$platform" == "win64" || "$platform" == "win64native" ]] ;
then
    platform=$platform
else
    echo "Platform unsupported! '$platform'"
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

if [[ "$platform" == "debian_amd64" ]] ; then
    pathTemplate=./script/data/start.sh.template
    pathStartupScriptName="./bin/$platformFull/start_$fname.sh"

elif [[ "$platform" == "win64native" || "$platform" == "win64" ]] ; then
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
