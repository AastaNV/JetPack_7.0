#!/bin/bash
#

set -e

pip install datasets --isolated
export VLLM_DISABLED_KERNELS=MacheteLinearKernel

sync && echo 3 | tee /proc/sys/vm/drop_caches && VLLM_ATTENTION_BACKEND=FLASH_ATTN python -m vllm.entrypoints.openai.api_server --model RedHatAI/Qwen2.5-VL-3B-Instruct-quantized.w4a16 --swap-space 16 --max-seq-len 4000 --max-model-len 4000 --tensor-parallel-size 1 --max-num-seqs 1024 --dtype auto --limit-mm-per-prompt image=4 --trust-remote-code --gpu-memory-utilization 0.80 --mm-processor-kwargs '{"use_fast": true}'
