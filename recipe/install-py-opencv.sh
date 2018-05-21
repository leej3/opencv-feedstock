#!/bin/bash

set -x

SCRIPT_CONTINUE_DIR=/c/Users/builder
BLD_TMP_ART=/c/Users/builder/opencv-temps/${PY_VER}

if [[ ${PY3K} == 1 ]]; then
  mkdir -p ${BLD_TMP_ART}
  env > ${BLD_TMP_ART}/env.txt
  pushd build/modules
    cp -rf python3 ${BLD_TMP_ART}/
  popd
fi

# site-packages dir relative to PREFIX with no a leading but no trailing slash
SP_REL=${SP_DIR/${PREFIX}/}

if [[ ${target_platform}} =~ win* ]]; then
  function make_clean() {
    cmake --build . --target clean --config Release -- VERBOSE=1
    find . -name "*includecache*" -exec rm -f {} \;
  }
  MAKE_BUILD="cmake --build . --target all --config Release -- VERBOSE=1"
  MAKE_INSTALL="cmake --build . --target install --config Release -- VERBOSE=1"
  PY36_SED1="cp36-win"
  PYXX_SED1="cp${PY_VER//./}-win"
  PY36_SED2="python36"
  PYXX_SED2="python${PY_VER//./}"
  # STARTOF :: Yes I am very very sorry about this. We need shell activate scripts in our VC compilers
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
else
  # Because clean does not really mean clean in CMake-land:
  function make_clean() {
    make clean ${VERBOSE_CM}
    find . -name "*includecache*" -exec rm -f {} \;
    make depend ${VERBOSE_CM}
  }
  MAKE_BUILD="make all ${VERBOSE_CM}"
  MAKE_INSTALL="make install ${VERBOSE_CM}"
  PY36_SED1="python3.6"
  PYXX_SED1="python${PY_VER}"
  PY36_SED2="36m"
  PYXX_SED2="${PY_VER//./}m"
fi

if [[ ${PY3K} == 1 ]]; then
  if [[ ${PY_VER} == 3.6 ]]; then
    cp -f py3${SP_REL}/cv2* ${SP_DIR}
    # Rebuild, run procmon here to figure out wtf is going on with cl.exe not finding io.h
    pushd build/modules/python3
      while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-retry-py36 ]]; do
        rm py3${SP_REL}/cv2*
        while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-start-py36 ]]; do
          echo "${PWD} Sleeping for debug, to continue, please"
          echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-start-py36"
          sleep 20
        done
        rm ${SCRIPT_CONTINUE_DIR}/continue-script-start-py36
        ${MAKE_BUILD}
      done
      echo "${PWD} Sleeping to allow re-running original cl.exe debug, to continue, please"
      echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-retry-py36"
      sleep 20
    popd
  else
    REAL_SP_DIR=${SP_DIR}
    conda install -p ${SRC_DIR}/py3 -y python=${PY_VER} numpy=1.11 --override-channels -c https://repo.continuum.io/pkgs/main
    pushd build/modules/python3
      while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-start ]]; do
        echo "${PWD} Sleeping for debug, to continue, please"
        echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-start"
        sleep 20
      done
      rm ${SCRIPT_CONTINUE_DIR}/continue-script-start
      make_clean
      cp -rf ../python3 ${BLD_TMP_ART}/python3.post-clean
      while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-cleaned ]]; do
        echo "${PWD} Sleeping for debug, to continue, please"
        echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-cleaned"
        sleep 20
      done
      rm ${SCRIPT_CONTINUE_DIR}/continue-script-cleaned
      find . -type f -exec sed -i'' -e "s/${PY36_SED1}/${PYXX_SED1}/g" {} \;
      find . -type f -exec sed -i'' -e "s/${PY36_SED2}/${PYXX_SED2}/g" {} \;
      cp -rf ../python3 ${BLD_TMP_ART}/python3.post-sed
      ${MAKE_BUILD}
      cp -rf ../python3 ${BLD_TMP_ART}/python3.post-make-build
      ${MAKE_INSTALL}
      cp -rf ../python3 ${BLD_TMP_ART}/python3.post-make-install
      while [[ ! -f ${SCRIPT_CONTINUE_DIR}/continue-script-built ]]; do
        echo "${PWD} Sleeping for debug, to continue, please"
        echo "touch ${SCRIPT_CONTINUE_DIR}/continue-script-built"
        sleep 20
      done
      rm ${SCRIPT_CONTINUE_DIR}/continue-script-built
      echo "Does this matter? are they even different? REAL_SP_DIR=${REAL_SP_DIR} SP_DIR=${SP_DIR}"
      cp -rf ${SRC_DIR}/py3${SP_REL}/cv2* ${REAL_SP_DIR}
      # Un-sed in case there are other non-3.6 python 3 versions to be built for:
      find . -type f -exec sed -i'' -e "s/${PYXX_SED1}/${PY36_SED1}/g" {} \;
      find . -type f -exec sed -i'' -e "s/${PYXX_SED2}/${PY36_SED2}/g" {} \;
      cp -rf ../python3 ${BLD_TMP_ART}/python3.post-sed-undo
    popd
  fi
else
  cp -f py2${SP_REL}/cv2* ${SP_DIR}
fi
