#!/bin/bash
#

set -e
export PATH=/usr/local/cuda-13.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64:$LD_LIBRARY_PATH


# Dependencies
apt-get update
apt-get -y install cargo cmake lsb-release wget software-properties-common gnupg git-lfs
apt-get -y install python3.12-venv python3-pip
apt-get -y install libcurl4-openssl-dev
python3 -m venv env
source env/bin/activate
pip3 install Cython numpy psutil typing_extensions openai
pip3 install pydantic shortuuid fastapi requests tqdm
pip3 install uvicorn openai safetensors ml_dtypes
pip3 install pillow


# llama.cpp
cd /opt && git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp && cmake -B build \
	-DGGML_CUDA=ON \
	-DGGML_CUDA_F16=on \
	-DLLAMA_CURL=on \
	-DGGML_CUDA_FA_ALL_QUANTS=ON  \
	-DCMAKE_CUDA_ARCHITECTURES="110"
cmake --build build --config Release --parallel 12


echo "** Install llama.cpp successfully"
echo "** Bye :)"
