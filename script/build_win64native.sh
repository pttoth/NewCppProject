#!/bin/bash

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

rootdir="${scriptdir}/.."
rootdir="$(pushd -- "$rootdir" > /dev/null && pwd && popd > /dev/null)" 	# remove '..' components

pushd "${scriptdir}"
. ./win64/set_env.sh
popd


# config
#compiler=$1
compiler=mingw
buildtarget=release
platform=win64
platformFull=${platform}_${compiler}
#platformFull=${platform}

if [ "$1" = "debug" ]; then
    buildtarget=debug
    platformFull=${platformFull}_debug
fi


if [[ "$compiler" == "msvc" ]]; then
	echo "MSVC not yet supported!"
	# TODO: need to figure out cmake generator...
	# 	Visual Studio 17 2022
	# 	Visual Studio 16 2019
	# 	Visual Studio 15 2017
	# 	Visual Studio 14 2015
	exit 1
fi



echo "Target platform: '${platformFull}'"

fname_executable=$(cat "$rootdir/script/data/common/__CFG_TARGET_EXECUTABLE_NAME__").exe
path_target_binary="${rootdir}/bin/${platformFull}/${fname_executable}"
builddir="${rootdir}/build/${platformFull}"


#get available core count
cores=$(nproc)


#move to project root directory
pushd "$rootdir"


if [ "$buildtarget" = "debug" ]; then
    echo "Building debug target"
    cmake -B$builddir -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug .
    pushd "${builddir}"
    mingw32-make -j $cores
    popd #from $builddir

else
    echo "Building release target"
    cmake -B$builddir -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release .
    pushd "${builddir}"
    mingw32-make -j $cores
    popd #from $builddir

    echo "Stripping binary '${path_target_binary}'"
    strip -v "${path_target_binary}"
fi

popd
