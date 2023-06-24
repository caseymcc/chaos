#/bin/bash

git clone https://github.com/SlyEcho/llama.cpp.git llama_rocm
cd llama_rocm
git remote add upstream https://github.com/ggerganov/llama.cpp.git
git fetch upstream
#git diff origin/hipblas...upstream/master > ../llama_rocm.patch
git diff upstream/master...origin/hipblas > ../llama_rocm.patch