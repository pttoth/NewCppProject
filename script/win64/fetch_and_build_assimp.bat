@echo off
pushd %~dp0
call .\set_env.bat
::gets the following variables
::  win_script_dir
::  root_directory
::  toolset_name
::  build_platform
::  temp_dir

@echo off

@echo --------------------------------------------------
@echo                       assimp
@echo --------------------------------------------------

set assimp_repo_url=https://github.com/assimp/assimp
set repo_version=v5.4.2

set target_dir_debug=%root_directory%\bin\%build_platform%_debug
set target_dir_release=%root_directory%\bin\%build_platform%

set target_lib_dir=%root_directory%\lib\%build_platform%

mkdir "%temp_dir%" >nul 2>&1
pushd "%temp_dir%"

@echo ------------------------------
@echo downloading from
@echo   %assimp_repo_url%
@echo ------------------------------
git clone %assimp_repo_url% assimp

set assimp_repo_path=%temp_dir%\assimp
cd "%assimp_repo_path%"

git pull
@echo checking out version: '%repo_version%'
git checkout %repo_version%

@echo ------------------------------
@echo building assimp
@echo ------------------------------
mkdir "%assimp_repo_path%\build" >nul 2>&1
cd "%assimp_repo_path%\build"
cmake -B"%assimp_repo_path%\build" -G"MinGW Makefiles" -D"ASSIMP_BUILD_ASSIMP_TOOLS=OFF" -D"ASSIMP_BUILD_TESTS=OFF" -D"ASSIMP_BUILD_ASSIMP_TOOLS=OFF" -D"ASSIMP_BUILD_NO_EXPORT=ON" "%assimp_repo_path%"

@echo ------------------------------
@echo building with %NUMBER_OF_PROCESSORS% threads
@echo ------------------------------
mingw32-make -j %NUMBER_OF_PROCESSORS% --output-sync

::@echo ------------------------------
::@echo stripping assimp binaries
::@echo   (reducing binary file size)
::@echo ------------------------------
::strip "%assimp_repo_path%\build\code\libassimp.dll"
::strip "%assimp_repo_path%\build\code\libassimp.dll.a"

::strip "%assimp_repo_path%\build\contrib\irrXML\libIrrXML.dll"
::strip "%assimp_repo_path%\build\contrib\zlib\libzlib.dll"

popd

@echo ------------------------------
@echo copying assimp libraries to
@echo   "%target_lib_dir%\assimp"
@echo ------------------------------

mkdir "%target_lib_dir%" >nul 2>&1

::NOTE: careful with directory deletion because Batch is abhorrently unpredictable with quotes and spaces in variables

::delete the old contents
::@echo DELETING FOLDER: "%target_lib_dir%\assimp" ...
::rmdir /s "%target_lib_dir%\assimp" /q

mkdir "%target_lib_dir%\assimp" >nul 2>&1
mkdir "%target_lib_dir%\assimp\bin" >nul 2>&1
mkdir "%target_dir_debug%" >nul 2>&1
mkdir "%target_dir_release%" >nul 2>&1
mkdir "%target_lib_dir%\assimp\include" >nul 2>&1
mkdir "%target_lib_dir%\assimp\include\assimp" >nul 2>&1

::copy to ./lib/assimp
copy "%assimp_repo_path%\build\bin\libassimp-5.dll"             "%target_lib_dir%\assimp\bin\libassimp-5.dll" /y
::copy "%assimp_repo_path%\build\contrib\irrXML\libIrrXML.dll"    "%target_lib_dir%\assimp\bin\libIrrXML.dll" /y
::copy "%assimp_repo_path%\build\contrib\zlib\libzlib.dll"        "%target_lib_dir%\assimp\bin\libzlib.dll" /y


@echo "stripping built binaries..."
strip "%target_lib_dir%\assimp\bin\libassimp-5.dll"
@echo "done"


xcopy "%assimp_repo_path%\include\*"                            "%target_lib_dir%\assimp\include\" /e /y
copy "%assimp_repo_path%\build\include\assimp\config.h"         "%target_lib_dir%\assimp\include\assimp\config.h" /y

::copy from ./lib/assimp to ./bin
copy "%target_lib_dir%\assimp\bin\libassimp-5.dll"              "%target_dir_debug%\libassimp-5.dll" /y
::copy "%assimp_repo_path%\build\contrib\irrXML\libIrrXML.dll"    "%target_dir_debug%\libIrrXML.dll" /y
::libzlib.dll

copy "%target_lib_dir%\assimp\bin\libassimp-5.dll"              "%target_dir_release%\libassimp-5.dll" /y
::copy "%assimp_repo_path%\build\contrib\irrXML\libIrrXML.dll"    "%target_dir_release%\libIrrXML.dll" /y
::libzlib.dll

popd

@echo --------------------------------------------------

@echo on
::pause
