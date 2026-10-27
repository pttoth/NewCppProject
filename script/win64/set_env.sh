#!/bin/bash

scriptdir_restore=""

if [ -v scriptdir ]; then
	scriptdir_restore="$scriptdir"
fi

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null


if [[ ! -v pt_env_set ]]; then
    pt_env_set=0
fi


f () {
	if [ "${pt_env_set}" -ne 0 ]; then
		echo "Environment is already set. Skipping."
		return 0
	fi

	scriptdir="$(cd -- "$scriptdir" && pwd)"
	root_directory="${scriptdir}/../.."
	root_directory="$(pushd -- "$root_directory" > /dev/null && pwd && popd > /dev/null)"	# remove ".." components

	win_scriptdir="${scriptdir}"

	toolset_name="win64_mingw"
	build_platform="win64_mingw"

	temp_dir="/tmp/pt_install/${toolset_name}"

	# --------------------------------------------------
	# NOTE: These DLLs are present in both MinGW 8.1.0
	# and Git's own MinGW environment:
	#   libgcc_s_seh-1.dll
	#   libssp-0.dll
	#   libstdc++-6.dll
	#   libwinpthread-1.dll
	#
	# Paths:
	#   C:/tools/mingw/x86_64-8.1.0-posix-seh/mingw64/bin
	#   C:/Program Files/Git/mingw64/bin
	#
	# Git's MinGW environment is currently only used by
	# the project to access curl.
	# --------------------------------------------------

	# Windows system paths
	pathSysToolset="/c/tools/mingw/x86_64-8.1.0-posix-seh/mingw64/bin:/c/Program Files/Git/bin:/c/tools/CMake/bin:/c/Program Files/7-Zip"

	# Local toolset paths
	pathLocalToolset=""
    pathLocalToolset="${pathLocalToolset}:${root_directory}/build_toolset/${toolset_name}/mingw/mingw64/bin"
    pathLocalToolset="${pathLocalToolset}:${root_directory}/build_toolset/${toolset_name}/cmake/bin"
    pathLocalToolset="${pathLocalToolset}:${root_directory}/build_toolset/${toolset_name}/PortableGit/bin"
    

	PATH="${pathLocalToolset}:${PATH}"

	pt_env_set=1

	# Print configuration
	echo "scriptdir        = ${scriptdir}"
	echo "win_scriptdir    = ${win_scriptdir}"
	echo "root_directory   = ${root_directory}"
	echo "temp_dir         = ${temp_dir}"
	echo "toolset_name     = ${toolset_name}"
	echo "build_platform   = ${build_platform}"
	echo "PATH             = ${PATH}"

	# Create temporary directory
	mkdir -p -- "$temp_dir" 2>/dev/null

	# Return success regardless of mkdir's exit status
	return 0

}

f

scriptdir="$scriptdir_restore"
