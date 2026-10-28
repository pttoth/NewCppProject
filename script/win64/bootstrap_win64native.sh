#!/bin/bash
set -euo pipefail

#find out script directory
pushd $(dirname "${BASH_SOURCE[0]}") > /dev/null
scriptdir=$(pwd)
popd > /dev/null

project_root="$scriptdir/../.."

pushd "$scriptdir" > /dev/null

# set up toolchain
./setup_toolchain.sh


# set up dependencies
#cmd //c 'call .\fetch_and_build_all.bat'

cmd //c 'call .\fetch_and_build_glew.bat'
cmd //c 'call .\fetch_and_build_libpng.bat'
cmd //c 'call .\fetch_and_build_SDL.bat'
cmd //c 'call .\fetch_and_build_assimp.bat'
cmd //c 'call .\fetch_and_build_ptlib.bat'
cmd //c 'call .\fetch_and_build_math3d.bat'


# generate and build project
"${project_root}"/script/generate_project.sh win64native
"${project_root}"/script/build_win64native.sh
"${project_root}"/script/copy_startup_script.sh

echo "Finished"

popd > /dev/null
