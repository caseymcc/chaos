#/bin/bash

cmake -Sllama.cpp/ -Bllama.cpp/build_debug -DCMAKE_TOOLCHAIN_FILE=$(pwd)/clang_toolchain.cmake