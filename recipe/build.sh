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

#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig
#export PKG_CONFIG_LIBDIR=$PREFIX/lib
# export CMAKE_SYSTEM_PREFIX_PATH=${SYS_PREFIX}
  cmake .. -LAH                                                             \
    -GNinja                                                                 \
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
    -DUPDATE_PROTO_FILES=ON                                                 \
    -DWITH_1394=OFF                                                         \
    -DWITH_CUDA=OFF                                                         \
    -DWITH_EIGEN=1                                                          \
    -DWITH_FFMPEG=ON                                                        \
    -DWITH_GTK=OFF                                                          \
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
    -DWITH_VTK=OFF                                                          \
    -DPYTHON_DEFAULT_EXECUTABLE=$(which python)                             \
    -DCMAKE_CROSSCOMPILING=ON                                               \
    -DCMAKE_BUILD_TYPE="Release"                                            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                        \
    -DCMAKE_INSTALL_LIBDIR=lib                                              \
    -DOpenCV_INSTALL_BINARIES_PREFIX=""                                     \
    -DCMAKE_SKIP_RPATH=ON                                                   \
    -DCMAKE_STRIP="${STRIP}"                                                \
    -DOPENCV_DOWNLOAD_PATH="${SYS_PREFIX}"/conda-bld/src_cache              \
    -DINSTALL_C_EXAMPLES=OFF                                                \
    -DENABLE_CONFIG_VERIFICATION=ON                                         \
    "${PYTHON_CMAKE_ARGS[@]}"                                               \
    -DINSTALL_PYTHON_EXAMPLES=ON                                            \
    -DENABLE_PYLINT=0      `# used for docs and examples`                   \
    -DENABLE_FLAKE8=0                                                       \
    -DOPENCV_EXTRA_MODULES_PATH="../opencv_contrib-${PKG_VERSION}/modules"  \
    "${CMAKE_EXTRA_ARGS[@]}"                                                \
    "${CMAKE_DEBUG_ARGS[@]}"

  if [[ ! $? ]]; then
    echo "configure failed with $?"
    exit 1
  fi

  cmake --build . && cmake --install .

