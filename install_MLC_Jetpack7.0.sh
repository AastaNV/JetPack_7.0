#!/bin/bash
#

set -e
export PATH=/usr/local/cuda-13.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64:$LD_LIBRARY_PATH


# Dependencies
apt-get update
apt-get -y install cargo cmake lsb-release wget software-properties-common gnupg git-lfs
apt-get -y install python3.12-venv python3-pip
python3 -m venv env
source env/bin/activate
pip3 install Cython numpy psutil typing_extensions openai
pip3 install pydantic shortuuid fastapi requests tqdm
pip3 install uvicorn openai safetensors ml_dtypes
curl https://sh.rustup.rs -sSf | sh -s -- -y


# PyTorch
wget https://developer.download.nvidia.com/compute/nvpl/25.5/local_installers/nvpl-local-repo-ubuntu2404-25.5_1.0-1_arm64.deb
sudo dpkg -i nvpl-local-repo-ubuntu2404-25.5_1.0-1_arm64.deb
sudo cp /var/nvpl-local-repo-ubuntu2404-25.5/nvpl-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install nvpl
rm nvpl-local-repo-ubuntu2404-25.5_1.0-1_arm64.deb

wget https://pypi.jetson-ai-lab.io/sbsa/cu130/+f/a96/474a2e6e0f0a3/torch-2.9.0.dev20250827+cu130.g378edb0-cp312-cp312-linux_aarch64.whl#sha256=a96474a2e6e0f0a3659e1598d1b25663ed71cb8df2ee9abd6881a9f959d268de
pip3 install torch-2.9.0.dev20250827+cu130.g378edb0-cp312-cp312-linux_aarch64.whl
rm torch-2.9.0.dev20250827+cu130.g378edb0-cp312-cp312-linux_aarch64.whl


# LLVM
cd /opt && wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 17 all
rm llvm.sh


# TVM
cd /opt && git clone https://github.com/apache/tvm.git && cd tvm 
git submodule sync && git submodule update --init --recursive
mkdir -p ./build && cd build
cp ../cmake/config.cmake . && \
    echo "set(USE_LLVM ON)" >> config.cmake && \
    echo "set(USE_CUBLAS ON)" >> config.cmake && \
    echo "set(USE_CUDNN ON)" >> config.cmake && \
    echo "set(USE_CUDA ON)" >> config.cmake && \
    echo "set(USE_CUTLASS ON)" >> config.cmake && \
    echo "set(USE_THRUST ON)" >> config.cmake && \
    echo "set(USE_NCCL OFF)" >> config.cmake && \
    echo "set(CMAKE_CUDA_ARCHITECTURES 110)" >> config.cmake && \
    echo "set(USE_FLASHINFER ON)" >> config.cmake && \
    echo "set(FLASHINFER_ENABLE_FP8 ON)" >> config.cmake && \
    echo "set(FLASHINFER_ENABLE_BF16 ON)" >> config.cmake && \
    echo "set(FLASHINFER_CUDA_ARCHITECTURES 101)" >> config.cmake
cmake .. && make -j12
cd /opt/tvm/ffi && pip install .
export TVM_HOME=/opt/tvm
export PYTHONPATH=/opt/tvm/python:${PYTHONPATH}


# MLC
cd /opt && git clone https://github.com/mlc-ai/mlc-llm.git && cd mlc-llm
git submodule sync && git submodule update --init --recursive
mkdir -p build && cd build
touch config.cmake && \
    echo "set(TVM_SOURCE_DIR /opt/tvm)" >> config.cmake && \
    echo "set(CMAKE_BUILD_TYPE RelWithDebInfo)" >> config.cmake && \
    echo "set(USE_CUDA ON)" >> config.cmake && \
    echo "set(USE_CUTLASS ON)" >> config.cmake && \
    echo "set(USE_CUBLAS ON)" >> config.cmake && \
    echo "set(USE_ROCM OFF)" >> config.cmake && \
    echo "set(USE_VULKAN OFF)" >> config.cmake && \
    echo "set(USE_METAL OFF)" >> config.cmake && \
    echo "set(USE_OPENCL OFF)" >> config.cmake && \
    echo "set(USE_OPENCL_ENABLE_HOST_PTR OFF)" >> config.cmake && \
    echo "set(USE_THRUST ON)" >> config.cmake && \
    echo "set(USE_FLASHINFER ON)" >> config.cmake && \
    echo "set(FLASHINFER_ENABLE_FP8 OFF)" >> config.cmake && \
    echo "set(FLASHINFER_ENABLE_BF16 OFF)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_GROUP_SIZES 1 4 6 8)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_PAGE_SIZES 16)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_HEAD_DIMS 128)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_KV_LAYOUTS 0 1)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_POS_ENCODING_MODES 0 1)" >> config.cmake && \
    echo "set(FLASHINFER_GEN_ALLOW_FP16_QK_REDUCTIONS "false")" >> config.cmake && \
    echo "set(FLASHINFER_GEN_CASUALS "false" "true")" >> config.cmake && \
    echo "set(FLASHINFER_CUDA_ARCHITECTURES 110)" >> config.cmake && \
    echo "set(CMAKE_CUDA_ARCHITECTURES 110)" >> config.cmake
cmake .. && make -j12


echo "** Install MLC successfully"
echo "** Bye :)"
