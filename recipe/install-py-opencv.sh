#!/bin/bash

pushd build
  cmake --install . --config Release
popd
