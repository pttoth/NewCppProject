#!/bin/bash

set -euo pipefail

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

platform=debian

project_root="$scriptdir"/../..

echo "Obtaining ptlib"

#-------------------------
# read and validate architeture param
cfg_arch=${1:-}
arch=""
if [ -z "$cfg_arch" ]; then
    cfg_arch=$( "${project_root}"/script/debian/detect_arch.sh )
    echo "No architecture defined, '$cfg_arch' detected"
fi

if ! "${project_root}"/script/debian/validate_arch.sh $cfg_arch; then
    echo "Unknown architecture: '$cfg_arch'"
    exit 1
fi

arch=$cfg_arch

platformFull=${platform}_${arch}

#-------------------------
echo "Architecture: '$arch'"

pushd "$project_root" > /dev/null
    #set up temp install directory
    tmp_dir_install="/tmp/pt_install/$arch"
    mkdir -vp "$tmp_dir_install"

    pushd "$tmp_dir_install" > /dev/null
        # cfg: dependency source and version
        repo_version=$(cat "$project_root"/script/data/cfg/PTLIB_VERSION )
        download_link=https://github.com/pttoth/ptlib

        # acquire dependency
        echo "Cloning repo '$download_link'"
        git clone $download_link ptlib  || true
        cd ptlib
        git pull
        git checkout $repo_version

        #call the lib's build script
        ./script/$platformFull/bootstrap_$platform.sh $arch

    popd > /dev/null

    # backup existing 'lib/' contents, if needed
    time_now=$(date "+%y-%m-%d_%H%M%S")
    mv -v ./lib/$platformFull/libptlib.a    ./lib/$platformFull/libptlib.a.bak_${time_now}   2> /dev/null || true
    mv -v ./lib/$platformFull/ptlib         ./lib/$platformFull/ptlib.bak_${time_now}        2> /dev/null || true

    #create 'lib' directory
    mkdir -vp ./lib/$platformFull/ptlib
    mkdir -vp ./lib/$platformFull/ptlib/{include,src}

    #move built libs into 'lib' directory
    cp -v ${tmp_dir_install}/ptlib/bin/$platformFull/libptlib.a ./lib/$platformFull/

    cp -vr ${tmp_dir_install}/ptlib/include/* ./lib/$platformFull/ptlib/include/
    cp -vr ${tmp_dir_install}/ptlib/src/*     ./lib/$platformFull/ptlib/src/

popd > /dev/null
