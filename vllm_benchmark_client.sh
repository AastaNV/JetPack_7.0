#!/bin/bash
#

set -e

git clone --branch v0.9.2 https://github.com/vllm-project/vllm.git
cd vllm/benchmarks/

echo ">> Warm up"
python3 benchmark_serving.py --backend openai-chat --base-url http://0.0.0.0:8000 --endpoint /v1/chat/completions --dataset-name hf --dataset-path lmarena-ai/vision-arena-bench-v0.1 --model RedHatAI/Qwen2.5-VL-3B-Instruct-quantized.w4a16 --num-prompts 50 --random-input-len 2048 --random-output-len 128 --percentile-metrics ttft,tpot,itl,e2el --max-concurrency 1
echo ""

echo ">> Max conc = 1"
python3 benchmark_serving.py --backend openai-chat --base-url http://0.0.0.0:8000 --endpoint /v1/chat/completions --dataset-name hf --dataset-path lmarena-ai/vision-arena-bench-v0.1 --model RedHatAI/Qwen2.5-VL-3B-Instruct-quantized.w4a16 --num-prompts 50 --random-input-len 2048 --random-output-len 128 --percentile-metrics ttft,tpot,itl,e2el --max-concurrency 1
echo ""

echo ">> Max conc = 8"
python3 benchmark_serving.py --backend openai-chat --base-url http://0.0.0.0:8000 --endpoint /v1/chat/completions --dataset-name hf --dataset-path lmarena-ai/vision-arena-bench-v0.1 --model RedHatAI/Qwen2.5-VL-3B-Instruct-quantized.w4a16 --num-prompts 50 --random-input-len 2048 --random-output-len 128 --percentile-metrics ttft,tpot,itl,e2el --max-concurrency 8
