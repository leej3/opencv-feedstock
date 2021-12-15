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

declare -a CMAKE_EXTRA_ARGS
export CXXFLAGS="$CXXFLAGS -D__STDC_CONSTANT_MACROS"
export CPPFLAGS="${CPPFLAGS//-std=c++17/-std=c++11}"
export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

if [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
fi

mkdir build
cd build


#-DWITH_VA_INTEL=OFF -DWITH_VA=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_GTK=OFF -DWITH_GSTREAMER=OFF -DWITH_1394=OFF -DWITH_JASPER=ON -GNinja ..
#export PKG_CONFIG_LIBDIR=$PREFIX/lib
#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig
export CMAKE_SYSTEM_PREFIX_PATH=${SYS_PREFIX}
  cmake .. -LAH                                                             \
    -GNinja                                                                 \
    -DCMAKE_BUILD_TYPE="Release"                                            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                        \
    -DCMAKE_INSTALL_LIBDIR=lib                                              \
    -DOpenCV_INSTALL_BINARIES_PREFIX=""                                     \
    -DCMAKE_SKIP_RPATH=ON                                                   \
    -DCMAKE_STRIP="${STRIP}"                                                \
    -DOPENCV_DOWNLOAD_PATH="${SYS_PREFIX}"/conda-bld/src_cache              \
    -DWITH_OPENMP=1                                                         \
    -DBUILD_opencv_dnn=0                                                    \
    -DWITH_EIGEN=1                                                          \
    -DBUILD_TESTS=0                                                         \
    -DBUILD_DOCS=0                                                          \
    -DBUILD_PERF_TESTS=0                                                    \
    -DBUILD_ZLIB=0                                                          \
    -DBUILD_LIBPROTOBUF_FROM_SOURCES=0                                      \
    -DBUILD_PROTOBUF=0                                                      \
    -DBUILD_TIFF=0                                                          \
    -DBUILD_PNG=0                                                           \
    -DBUILD_OPENEXR=ON                                                      \
    -DBUILD_JASPER=0                                                        \
    -DBUILD_JPEG=0                                                          \
    -DWITH_CUDA=OFF                                                         \
    -DWITH_OPENCL=OFF                                                       \
    -DWITH_OPENNI=OFF                                                       \
    -DWITH_FFMPEG=ON                                                        \
    -DWITH_MATLAB=OFF                                                       \
    -DWITH_VTK=OFF                                                          \
    -DWITH_GTK=OFF                                                          \
    -DWITH_LAPACK=OFF                                                       \
    -DWITH_1394=OFF                                                         \
    -DWITH_JASPER=OFF                                                       \
    -DWITH_OPENCLAMDFFT=OFF                                                 \
    -DWITH_OPENCLAMDBLAS=OFF                                                \
    -DWITH_VA=OFF                                                           \
    -DWITH_VA_INTEL=OFF                                                     \
    -DWITH_PROTOBUF=OFF                                                     \
    -DWITH_TESSERACT=OFF                                                    \
    -DINSTALL_C_EXAMPLES=OFF                                                \
    -DENABLE_CONFIG_VERIFICATION=ON                                         \
    "${PYTHON_CMAKE_ARGS[@]}"                                               \
    -DINSTALL_PYTHON_EXAMPLES=ON                                            \
    -DENABLE_PYLINT=1                                                       \
    -DENABLE_FLAKE8=1                                                       \
    -DOPENCV_EXTRA_MODULES_PATH="../opencv_contrib-${PKG_VERSION}/modules"  \
    "${CMAKE_EXTRA_ARGS[@]}"                                                \
    "${CMAKE_DEBUG_ARGS[@]}"

  if [[ ! $? ]]; then
    echo "configure failed with $?"
    exit 1
  fi

  cmake --build . && cmake --install .

