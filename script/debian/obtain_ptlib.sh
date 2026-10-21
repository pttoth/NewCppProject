#!/bin/bash


#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

# read and validate architeture param
cfg_arch=$1
arch=""
echo "Obtaining ptlib (arch: '$cfg_arch')"
if [[ "$cfg_arch" == "amd64" || "$cfg_arch" == "arm64" ]]; then
    arch="$cfg_arch"
else
    echo "Unknown architecture: '$cfg_arch'"
    exit 1
fi


#move to project root directory
project_root="$scriptdir/../.."
pushd "$project_root" > /dev/null
    #set up temp install directory
    tmp_dir_install="/tmp/pt_install/$arch"
    mkdir -vp "$tmp_dir_install"

    pushd "$tmp_dir_install" > /dev/null
        # cfg: dependency source and version
        repo_version=$(cat "$project_root/script/data/cfg/PTLIB_VERSION")
        download_link=https://github.com/pttoth/ptlib

        # acquire dependency
        echo "Cloning repo '$download_link'"
        git clone $download_link ptlib
        cd ptlib
        git pull
        git checkout $repo_version

        #call the lib's build script
        #./script/debian_$arch/bootstrap_debian_$arch.sh
        ./script/debian_$arch/bootstrap_debian.sh
    popd > /dev/null

    # backup existing 'lib/' contents, if needed
    time_now=$(date "+%y-%m-%d_%H%M%S")
    mv -v ./lib/$arch/libptlib.a    "./lib/$arch/libptlib.a.bak_${time_now}"   2> /dev/null
    mv -v ./lib/$arch/ptlib         "./lib/$arch/ptlib.bak_${time_now}"        2> /dev/null

    #create 'lib' directory
    mkdir -vp ./lib/$arch/ptlib
    mkdir -vp ./lib/$arch/ptlib/{include,src}

    #move built libs into 'lib' directory
    cp -v ${tmp_dir_install}/ptlib/bin/debian_$arch/libptlib.a ./lib/$arch/

    cp -vr ${tmp_dir_install}/ptlib/include/* ./lib/$arch/ptlib/include/
    cp -vr ${tmp_dir_install}/ptlib/src/*     ./lib/$arch/ptlib/src/

popd > /dev/null
