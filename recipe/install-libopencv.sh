#!/bin/bash

pushd build
  cmake --install . ${VERBOSE_CM}
popd
