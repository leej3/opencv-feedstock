#!/bin/bash

pushd build

set -x
SCRIPT_CONTINUE_DIR=/c/Users/builder

  if [[ ${target_platform} =~ win* ]]; then
    VS140=$(pushd "${VS140COMNTOOLS}/../../" 2>&1 > /dev/null; pwd)
    WindowsSdkDir="/c/Program Files (x86)/Windows Kits/10/"
    WindowsSDKLibVersion="10.0.16299.0/"
    WindowsSDKVersion="10.0.16299.0/"
    NETFXSDK="/c/Program Files (x86)/Windows Kits/NETFXSDK/4.6.1"
    if [[ ${ARCH} == 64 ]]; then
      A1=amd64
      A2=/x64
    else
      A1=x86
      A2=
    fi
    export INCLUDE="${VS140}/VC/INCLUDE:${VS140}/VC/ATLMFC/INCLUDE:${VS140}:${WindowsSdkDir}include/${WindowsSDKLibVersion}ucrt:${NETFXSDK}/include/um:${WindowsSdkDir}include/${WindowsSDKLibVersion}shared:${WindowsSdkDir}include/${WindowsSDKLibVersion}um:${WindowsSdkDir}include/${WindowsSDKLibVersion}winrt:${PREFIX}/Library/include"
    export LIB="${VS140}/VC/LIB/${A1}:${VS140}/VC/ATLMFC/LIB/${A1}:${WindowsSdkDir}Lib/${WindowsSDKLibVersion}ucrt${A2}:${NETFXSDK}/Lib/um${A2}:${WindowsSdkDir}Lib/${WindowsSDKLibVersion}/um${A2}:${WindowsSdkDir}Lib/${WindowsSDKLibVersion}shared:${WindowsSdkDir}um${A2}:${PREFIX}/Library/lib"
    # VC does not like / in INCLUDE or LIB.
    export INCLUDE=$(cygpath -wp "${INCLUDE}" | sed 's#\\#\\\\#g')
    export LIB=$(cygpath -wp "${LIB}" | sed 's#\\#\\\\#g')
    # ENDOF :: Yes I am very very sorry about this. We need shell activate scripts in our VC compilers
    cmake --build . --target all --config Release -- VERBOSE=1 -j${CPU_COUNT}
    BLD_TMP_ART=/c/Users/builder/opencv-temps/${PY_VER}
    env > ${BLD_TMP_ART}/env.install-libopencv.sh
    echo "find ${LIBRARY_PREFIX}/${OPENCV_ARCH}/vc${vc}"
    while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-1 ]]; do
      echo "${PWD} Sleeping for debug, to continue, please"
      echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-1"
      sleep 20
    done
    rm ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-1
    cmake --build . --target INSTALL --config Release -- VERBOSE=1 -j${CPU_COUNT}
    if [[ ${ARCH} == 32 ]]; then
      OPENCV_ARCH=x86
    else
      OPENCV_ARCH=x64
    fi
    echo "find ${LIBRARY_PREFIX}/${OPENCV_ARCH}/vc${vc}"
    while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-2 ]]; do
      echo "${PWD} Sleeping for debug, to continue, please"
      echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-2"
      sleep 20
    done
    rm ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-2
    [[ -d "${LIBRARY_PREFIX}"/bin ]] || mkdir "${LIBRARY_PREFIX}"/bin
    [[ -d "${LIBRARY_PREFIX}"/lib ]] || mkdir "${LIBRARY_PREFIX}"/lib
    if [[ -d ${LIBRARY_PREFIX}/${OPENCV_ARCH}/vc${vc} ]]; then
      cp -rf "${LIBRARY_PREFIX}"/${OPENCV_ARCH}/vc${vc}/bin/* "${LIBRARY_PREFIX}"/bin/
      cp -rf "${LIBRARY_PREFIX}"/${OPENCV_ARCH}/vc${vc}/lib/* "${LIBRARY_PREFIX}"/lib/
    fi
    while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-3 ]]; do
      echo "${PWD} Sleeping for debug, to continue, please"
      echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-3"
      sleep 20
    done
    rm ${SCRIPT_CONTINUE_DIR}/continue-script-install-libopencv-3
    # Remove files installed in the wrong locations
    rm -rf "${LIBRARY_BIN}"/Release
    rm -rf "${LIBRARY_PREFIX}"/${OPENCV_ARCH}
  else
    make install ${VERBOSE_CM}
  fi

popd
