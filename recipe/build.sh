#!/bin/bash

DEBUG_CMAKE_BUILD_SYSTEM=yes
declare -a CMAKE_DEBUG_ARGS
if [[ ${DEBUG_CMAKE_BUILD_SYSTEM} == yes ]]; then
#  CMAKE_DEBUG_ARGS+=("--debug-trycompile")
#  CMAKE_DEBUG_ARGS+=("-Wdev")
#  CMAKE_DEBUG_ARGS+=("--debug-output")
#  CMAKE_DEBUG_ARGS+=("--trace")
  CMAKE_DEBUG_ARGS+=("-DOPENCV_CMAKE_DEBUG_MESSAGES=1")
fi

declare -a PYTHON_CMAKE_ARGS
echo "PYTHON_CMAKE_ARGS="
echo "${PYTHON_CMAKE_ARGS[@]}"

# Set defaults for dependencies that change across OSes
IFS=" " read -r WITH_PROTOBUF WITH_GSTREAMER WITH_QT <<< "0 0 0"

# Capture cmake_args from build config yaml
CBC_CMAKE_ARGS="${CMAKE_ARGS}"

# Set some OS-specific vars
declare -a CMAKE_EXTRA_ARGS
# TODO: add if for architectures. ppc needs cmake_args to be set.
if [[ ${target_platform} == osx-* ]]; then
  CMAKE_EXTRA_ARGS+=("-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}")
elif [[ ${target_platform} == x86_64 ]];then
  WITH_QT=1
  WITH_GSTREAMER=1
  WITH_PROTOBUF=1
elif [[ ${target_platform} == ppc64le ]];then
    CMAKE_EXTRA_ARGS+=("${CMAKE_ARGS}")
else
# TODO: check if this is required
export CXXFLAGS="$CXXFLAGS -D__STDC_CONSTANT_MACROS"

export CPPFLAGS="${CPPFLAGS//-std=c++17/-std=c++11}"
export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"
fi

# append dependencies to CMAKE_EXTRA_ARGS
for dep in GSTREAMER PROTOBUF QT;do
    varname=WITH_${dep}
    CMAKE_EXTRA_ARGS+=("-D${varname}=${!varname}")
done
# append debug args
CMAKE_EXTRA_ARGS+=("${CMAKE_DEBUG_ARGS[@]}")
echo "CMake_EXTRA_ARGS : ${CMAKE_EXTRA_ARGS[@]}"

#TODO: check that libpng is found or use conda forge hack

#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig
#export PKG_CONFIG_LIBDIR=$PREFIX/lib
mkdir build
cd build
cmake .. -LAH -GNinja                                                     \
  "${CMAKE_EXTRA_ARGS[@]}" `#includes platform specific deps and options` \
  "${PYTHON_CMAKE_ARGS[@]}"                                               \
  -DBUILD_DOCS=0                                                          \
  -DBUILD_JASPER=0                                                        \
  -DBUILD_JPEG=0                                                          \
  -DBUILD_LIBPROTOBUF_FROM_SOURCES=0                                      \
  -DBUILD_OPENEXR=ON                                                      \
  -DBUILD_PERF_TESTS=0                                                    \
  -DBUILD_PNG=0                                                           \
  -DBUILD_PROTOBUF=0                                                      \
  -DBUILD_TESTS=0                                                         \
  -DBUILD_TIFF=0                                                          \
  -DBUILD_ZLIB=0                                                          \
  -DBUILD_opencv_apps=OFF `# issue linking with opencv_model_diagnostics` \
  -DCMAKE_BUILD_TYPE="Release"                                            \
  -DCMAKE_CROSSCOMPILING=ON         `# may not need`                      \
  -DCMAKE_FIND_ROOT_PATH="${PREFIX};${BUILD_PREFIX};${CONDA_BUILD_SYSROOT}"\
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=ONLY                                \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}                                        \
  -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON                             \
  -DENABLE_CONFIG_VERIFICATION=ON                                         \
  -DENABLE_FLAKE8=0                                                       \
  -DENABLE_PYLINT=0      `# used for docs and examples`                   \
  -DINSTALL_C_EXAMPLES=OFF                                                \
  -DINSTALL_PYTHON_EXAMPLES=ON                                            \
  -DOPENCV_DOWNLOAD_PATH="${SYS_PREFIX}"/conda-bld/src_cache              \
  -DOPENCV_EXTRA_MODULES_PATH="../opencv_contrib-${PKG_VERSION}/modules"  \
  -DOpenCV_INSTALL_BINARIES_PREFIX=""                                     \
  -DPROTOBUF_UPDATE_FILES=ON  `# should be used if using protobuf`        \
  -DWITH_1394=OFF                                                         \
  -DWITH_CUDA=OFF                                                         \
  -DWITH_EIGEN=1                                                          \
  -DWITH_FFMPEG=ON                                                        \
  -DWITH_GTK=OFF                                                          \
  -DWITH_ITT=OFF                                                          \
  -DWITH_JASPER=OFF                                                       \
  -DWITH_LAPACK=OFF                                                       \
  -DWITH_MATLAB=OFF                                                       \
  -DWITH_OPENCL=OFF                                                       \
  -DWITH_OPENCLAMDBLAS=OFF                                                \
  -DWITH_OPENCLAMDFFT=OFF                                                 \
  -DWITH_OPENMP=1                                                         \
  -DWITH_OPENNI=OFF                                                       \
  -DWITH_TESSERACT=OFF                                                    \
  -DWITH_VA=OFF                                                           \
  -DWITH_VA_INTEL=OFF                                                     \
  -DWITH_VTK=OFF

if [[ ! $? ]]; then
  echo "configure failed with $?"
  exit 1
fi

cmake --build . && cmake --install .

